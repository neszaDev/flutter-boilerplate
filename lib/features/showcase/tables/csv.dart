// Cells a spreadsheet would run as a formula; prefixed so the export stays plain data.
final _formulaStart = RegExp(r'^[=+\-@\t\r]');
final _needsQuotes = RegExp(r'[",\n\r]');

String _cell(Object value) {
  if (value is num) {
    // `36`, not `36.0`, like JavaScript's String(36).
    return value is double && value == value.truncateToDouble() ? '${value.toInt()}' : '$value';
  }
  final text = '$value';
  final safe = _formulaStart.hasMatch(text) ? "'$text" : text;
  return _needsQuotes.hasMatch(safe) ? '"${safe.replaceAll('"', '""')}"' : safe;
}

/// Serialises [rows] as CSV (RFC 4180 quoting), the first row being the header; cells are
/// `String`s or `num`s. Lines are separated by CRLF.
String toCsv(List<List<Object>> rows) => rows.map((row) => row.map(_cell).join(',')).join('\r\n');
