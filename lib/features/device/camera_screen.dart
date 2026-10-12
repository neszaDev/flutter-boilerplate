import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/utils/file_size.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/files/file_upload.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/device/camera`: take or pick a photo, look at it, upload it to Files.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  XFile? _photo;
  Uint8List? _bytes;
  bool _uploading = false;

  Future<void> _pick(FileSource source) async {
    try {
      final photo = await pickFile(source);
      if (photo == null) {
        return;
      }
      final bytes = await photo.readAsBytes();
      if (mounted) {
        setState(() {
          _photo = photo;
          _bytes = bytes;
        });
      }
    } on PlatformException {
      if (mounted) {
        showToast(context, context.l10n.commonPermissionDenied, tone: ToastTone.error);
      }
    }
  }

  Future<void> _upload() async {
    final photo = _photo;
    if (photo == null) {
      return;
    }
    setState(() => _uploading = true);
    final stored = await uploadFile(context, ref, photo);
    if (mounted) {
      setState(() {
        _uploading = false;
        if (stored != null) {
          _photo = null;
          _bytes = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canUpload = ref.watch(accessProvider).can(Permission.manageOwnFiles);
    final photo = _photo;
    final bytes = _bytes;

    return AppPage(
      title: l10n.cameraPageTitle,
      description: Text(l10n.cameraPageDescription),
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            FilledButton.icon(
              onPressed: () => _pick(FileSource.camera),
              icon: const Icon(LucideIcons.camera, size: 18),
              label: Text(l10n.cameraPageTake),
            ),
            OutlinedButton.icon(
              onPressed: () => _pick(FileSource.gallery),
              icon: const Icon(LucideIcons.image, size: 18),
              label: Text(l10n.cameraPagePick),
            ),
          ],
        ),
        DemoCard(
          title: l10n.cameraPagePreview,
          action: photo == null
              ? null
              : IconButton(
                  tooltip: l10n.cameraPageRemove,
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _photo = null;
                    _bytes = null;
                  }),
                ),
          child: photo == null || bytes == null
              ? Text(l10n.cameraPageEmpty, style: context.text.bodyMedium)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.md),
                      child: Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                        height: 280,
                        semanticLabel: photo.name,
                        // Decode at display size: a 12 MP photo would cost ~50 MB of memory.
                        cacheHeight: (280 * MediaQuery.devicePixelRatioOf(context)).round(),
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                    Text(
                      l10n.cameraPageDetails(
                        photo.name,
                        formatFileSize(bytes.length, context.localeName),
                      ),
                      style: context.text.bodySmall,
                    ),
                    if (canUpload) ...[
                      const SizedBox(height: Space.page),
                      FilledButton.icon(
                        onPressed: _uploading ? null : _upload,
                        icon: _uploading
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(LucideIcons.upload, size: 18),
                        label: Text(l10n.cameraPageUpload),
                      ),
                    ],
                  ],
                ),
        ),
        Text(l10n.cameraPagePermissionNote, style: context.text.bodySmall),
      ],
    );
  }
}
