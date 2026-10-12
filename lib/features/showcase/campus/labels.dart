/// Text of an app tile's notification badge: nothing for zero, the count up to 99, then "99+".
String? badgeLabel(int count) {
  if (count <= 0) {
    return null;
  }
  return count > 99 ? '99+' : '$count';
}

final _notLetterOrDigit = RegExp(r'[^\p{L}\p{N}]+', unicode: true);
final _edgeDashes = RegExp(r'^-+|-+$');

/// File name of a shared QR code, built from its label: `qr-code-mfu.png`.
///
/// The web app decomposes accents first (NFKD); Dart's core libraries can't, so accented letters
/// are kept as they are (`café` stays `café`), which every file system accepts.
String qrFileName(String label) {
  final slug = label.toLowerCase().replaceAll(_notLetterOrDigit, '-').replaceAll(_edgeDashes, '');
  return slug.isEmpty ? 'qr-code.png' : 'qr-code-$slug.png';
}

/// Up to two initials for an avatar without a photo: "Alex Martin" → "AM".
String initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  return words.take(2).map((word) => String.fromCharCode(word.runes.first)).join().toUpperCase();
}
