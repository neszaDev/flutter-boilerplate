import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Hands CSV text to the system share sheet as a file (save to Files, open in a spreadsheet,
/// send…): the phone's counterpart of the web's download link. The file goes to the app's
/// temporary directory only.
class CsvExport {
  const CsvExport();

  /// Writes [csv] as [filename] and opens the share sheet. [origin] anchors the sheet on
  /// tablets (the button that asked for it).
  Future<void> share({required String filename, required String csv, Rect? origin}) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    // The byte order mark lets spreadsheet apps read accented names as UTF-8.
    await file.writeAsString('﻿$csv', flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv', name: filename)],
        sharePositionOrigin: origin,
      ),
    );
  }
}

/// The CSV exporter; tests override it to capture what would be shared.
final csvExportProvider = Provider<CsvExport>((ref) => const CsvExport());
