import 'package:intl/intl.dart';

/// A file size the way a person reads it: "512 B", "12.4 KB", "3.2 MB" (localized digits).
/// Same thresholds as the web app's `FileSize.ts`.
String formatFileSize(int bytes, String locale) {
  final number = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 1);
  if (bytes < 1024) {
    return '${NumberFormat.decimalPattern(locale).format(bytes)} B';
  }
  if (bytes < 1024 * 1024) {
    return '${number.format(bytes / 1024)} KB';
  }
  return '${number.format(bytes / (1024 * 1024))} MB';
}
