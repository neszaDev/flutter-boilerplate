import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/features/files/files_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final _log = appLogger('files');

/// Where a new file comes from.
enum FileSource { documents, camera, gallery }

/// Opens the picker for [source]. Null when the user backs out; throws [PlatformException]
/// when the camera or photos permission is denied.
Future<XFile?> pickFile(FileSource source) async {
  switch (source) {
    case FileSource.documents:
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedFileExtensions,
      );
      return files.isEmpty ? null : files.first.xFile;
    case FileSource.camera || FileSource.gallery:
      // A quality below 100 makes the picker re-encode as JPEG (HEIC is not accepted) and keeps
      // phone photos well under the 10 MB limit.
      return ImagePicker().pickImage(
        source: source == FileSource.camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2560,
        maxHeight: 2560,
      );
  }
}

/// Upload progress of the file being sent, for the progress bar. Null when idle.
final uploadProgressProvider = NotifierProvider<UploadProgress, ({String name, double value})?>(
  UploadProgress.new,
);

class UploadProgress extends Notifier<({String name, double value})?> {
  CancelToken? _cancel;

  @override
  ({String name, double value})? build() => null;

  /// Starts tracking an upload; returns its cancel token.
  CancelToken start(String name) {
    state = (name: name, value: 0);
    return _cancel = CancelToken();
  }

  void report(String name, double value) => state = (name: name, value: value);

  void finish() {
    _cancel = null;
    state = null;
  }

  void cancel() => _cancel?.cancel();
}

/// Checks [file] against the backend's limits, uploads it with progress, and tells the user.
/// Resolves to the stored file, or null when refused, canceled or failed.
Future<StoredFile?> uploadFile(BuildContext context, WidgetRef ref, XFile file) async {
  final l10n = context.l10n;
  final bytes = await file.readAsBytes();
  final contentType = contentTypeOf(file, bytes);
  if (!context.mounted) {
    return null;
  }
  final problem = checkFile(size: bytes.length, contentType: contentType);
  if (problem != null) {
    showToast(context, _problemText(l10n, problem), tone: ToastTone.error);
    return null;
  }

  final progress = ref.read(uploadProgressProvider.notifier);
  final cancel = progress.start(file.name);
  try {
    final stored = await ref
        .read(filesRepositoryProvider)
        .upload(
          bytes: bytes,
          name: file.name,
          contentType: contentType!,
          cancelToken: cancel,
          onProgress: (value) => progress.report(file.name, value),
        );
    ref.invalidate(filesListProvider);
    if (context.mounted) {
      showToast(context, l10n.filesPageUploaded(stored.name), tone: ToastTone.success);
    }
    return stored;
  } on ApiException catch (error) {
    if (context.mounted && error.failure != ApiFailure.cancelled) {
      final message = switch (error.status) {
        400 => l10n.filesPageErrorEmpty,
        413 => l10n.filesPageErrorTooLarge,
        415 => l10n.filesPageErrorType,
        _ => errorMessage(context, error, fallback: l10n.filesPageErrorGeneric),
      };
      showToast(context, message, tone: ToastTone.error);
    }
    return null;
  } finally {
    progress.finish();
  }
}

String _problemText(AppLocalizations l10n, FileProblem problem) => switch (problem) {
  FileProblem.empty => l10n.filesPageErrorEmpty,
  FileProblem.tooLarge => l10n.filesPageErrorTooLarge,
  FileProblem.type => l10n.filesPageErrorType,
};

/// Picks from [source] and uploads, explaining a denied permission.
Future<void> pickAndUpload(BuildContext context, WidgetRef ref, FileSource source) async {
  try {
    final file = await pickFile(source);
    if (file != null && context.mounted) {
      await uploadFile(context, ref, file);
    }
  } on PlatformException catch (error) {
    _log.info('Picker failed: ${error.code}');
    if (context.mounted) {
      showToast(context, context.l10n.commonPermissionDenied, tone: ToastTone.error);
    }
  }
}

/// Downloads [file] and hands it to the system share sheet (save to Files, open in an app…).
/// The bytes go to the app's temporary directory only, never to shared storage.
Future<void> openFile(BuildContext context, WidgetRef ref, StoredFile file) async {
  final l10n = context.l10n;
  showToast(context, l10n.filesPageDownloading(file.name));
  try {
    final content = await ref.read(filesRepositoryProvider).download(file);
    final directory = await getTemporaryDirectory();
    final safeName = file.name.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_');
    final local = File('${directory.path}/${file.id}-$safeName');
    await local.writeAsBytes(content.bytes, flush: true);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(local.path, mimeType: content.contentType, name: file.name)],
        sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  } on ApiException catch (error) {
    if (context.mounted) {
      showToast(
        context,
        errorMessage(context, error, fallback: l10n.filesPageErrorDownload),
        tone: ToastTone.error,
      );
    }
  }
}
