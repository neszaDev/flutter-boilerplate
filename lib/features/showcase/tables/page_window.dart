import 'dart:math';

/// The page buttons to show, like CoreUI's pagination: at most [limit] pages around [page]
/// (one-based) out of [pages], with a gap (`null`) at either end when pages are hidden there.
List<int?> pageWindow({required int page, required int pages, int limit = 5}) {
  final size = max(limit, 1);
  final count = max(pages, 0);
  if (count <= size) {
    return [for (var index = 1; index <= count; index++) index];
  }
  final start = min(max(page - size ~/ 2, 1), count - size + 1);
  final end = start + size - 1;
  return [
    if (start > 1) null,
    for (var slot = start; slot <= end; slot++) slot,
    if (end < count) null,
  ];
}
