import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/api/api_client.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/json.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/data/paged_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

/// The backend's defaults (`FILES_MAX_SIZE`, `FILES_ALLOWED_TYPES`), checked before uploading.
const maxFileBytes = 10 * 1024 * 1024;

const allowedFileTypes = {
  'image/png',
  'image/jpeg',
  'image/gif',
  'image/webp',
  'application/pdf',
  'text/plain',
  'text/csv',
};

/// For the document picker.
const allowedFileExtensions = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'pdf', 'txt', 'csv'];

/// Why a file was refused before upload; the same reasons the backend gives (400/413/415).
enum FileProblem { empty, tooLarge, type }

/// Checks a file against the backend's limits.
FileProblem? checkFile({required int size, required String? contentType}) {
  if (size == 0) {
    return FileProblem.empty;
  }
  if (size > maxFileBytes) {
    return FileProblem.tooLarge;
  }
  return allowedFileTypes.contains(contentType) ? null : FileProblem.type;
}

/// The content type from the picker, else from the name and first bytes.
String? contentTypeOf(XFile file, Uint8List bytes) =>
    file.mimeType ?? lookupMimeType(file.name, headerBytes: bytes.take(32).toList());

/// A downloaded file.
class FileContent {
  const FileContent({required this.bytes, required this.name, this.contentType});

  final Uint8List bytes;
  final String name;
  final String? contentType;
}

/// The signed-in user's files (`/files`). Owner-scoped by the backend.
class FilesRepository {
  FilesRepository(this._dio);

  final Dio _dio;

  static const _path = '/api/v1/files';

  Future<PageResult<StoredFile>> list({required int page, required int size}) => apiCall(() async {
    final response = await _dio.get<Object?>(_path, queryParameters: {'page': page, 'size': size});
    return PageResult.fromJson(asJson(response.data), StoredFile.fromJson);
  });

  /// Multipart `POST /files` with the file under `file`. [onProgress] gets 0..1.
  Future<StoredFile> upload({
    required Uint8List bytes,
    required String name,
    required String contentType,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) => apiCall(() async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: name,
        contentType: MediaType.parse(contentType),
      ),
    });
    final response = await _dio.post<Object?>(
      _path,
      data: form,
      cancelToken: cancelToken,
      onSendProgress: onProgress == null
          ? null
          : (sent, total) => onProgress(total <= 0 ? 0 : sent / total),
    );
    return StoredFile.fromJson(asJson(response.data));
  });

  /// `GET /files/{id}/content`: the bytes, always served as an attachment.
  Future<FileContent> download(StoredFile file) => apiCall(() async {
    final response = await _dio.get<List<int>>(
      '$_path/${file.id}/content',
      options: Options(responseType: ResponseType.bytes),
    );
    return FileContent(
      bytes: Uint8List.fromList(response.data ?? const []),
      name: file.name,
      contentType: response.headers.value(Headers.contentTypeHeader) ?? file.contentType,
    );
  });

  /// A file that is already gone (404) counts as deleted.
  Future<void> delete(int id) => apiCall(() async {
    await _dio.delete<void>(
      '$_path/$id',
      options: Options(validateStatus: (status) => status == 404 || (status ?? 500) < 300),
    );
  });
}

final filesRepositoryProvider = Provider<FilesRepository>(
  (ref) => FilesRepository(ref.watch(apiDioProvider)),
);

class FilesList extends PagedNotifier<StoredFile> {
  @override
  Future<PageResult<StoredFile>> fetchPage(int page) =>
      ref.read(filesRepositoryProvider).list(page: page, size: AppConfig.filesPageSize);
}

final filesListProvider = AsyncNotifierProvider.autoDispose<FilesList, PagedState<StoredFile>>(
  FilesList.new,
);
