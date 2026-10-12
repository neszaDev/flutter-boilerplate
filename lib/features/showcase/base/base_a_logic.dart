import 'dart:math' as math;

// Pure helpers of the base demos: the endless carousel's paging and the nav "fill" layout.

/// The slide that [page] of an endless carousel of [count] slides shows.
int carouselSlideOf(int page, int count) => page % count;

/// The page nearest [from] that shows [slide], so an indicator moves the short way round.
int carouselPageFor({required int from, required int slide, required int count}) {
  var delta = slide - carouselSlideOf(from, count);
  if (delta > count / 2) {
    delta -= count;
  } else if (delta < -count / 2) {
    delta += count;
  }
  return from + delta;
}

/// The page an endless carousel starts on: far enough from zero that "previous" can loop from
/// the first slide back to the last.
int carouselStartPage(int count) => count * 1000;

/// Lays items of natural [widths] out in rows of at most [maxWidth], [gap] apart, like CSS
/// `flex-wrap: wrap` with `flex: auto`: an item that does not fit starts a new row, and each
/// row's spare room is shared equally among its items. An item wider than [maxWidth] gets a
/// row of its own at [maxWidth].
///
/// Returns the final widths, row by row.
List<List<double>> fillRows(List<double> widths, double maxWidth, {double gap = 0}) {
  final rows = <List<double>>[];
  var row = <double>[];
  var used = 0.0;
  for (final width in widths) {
    final needed = row.isEmpty ? width : used + gap + width;
    if (row.isNotEmpty && needed > maxWidth) {
      rows.add(_grow(row, maxWidth, gap));
      row = [];
      used = 0;
    }
    used = row.isEmpty ? width : used + gap + width;
    row.add(width);
  }
  if (row.isNotEmpty) {
    rows.add(_grow(row, maxWidth, gap));
  }
  return rows;
}

List<double> _grow(List<double> row, double maxWidth, double gap) {
  final total = row.fold<double>(0, (sum, width) => sum + width) + gap * (row.length - 1);
  final share = math.max(0, maxWidth - total) / row.length;
  return [for (final width in row) math.min(maxWidth, width + share)];
}
