import 'dart:math' as math;

/// The page numbers a pagination bar shows, and whether an ellipsis stands before or after them.
typedef PageItems = ({List<int> items, bool beforeDots, bool afterDots});

/// Works out which page numbers a pagination bar shows, the way CoreUI's `CPagination` does
/// (the web app's `pageItems`): at most [limit] slots, ellipses included, with an ellipsis
/// standing in for the hidden pages before or after the window around [activePage] (1-based).
/// [dots] false uses every slot for page numbers.
PageItems pageItems({
  required int activePage,
  required int pages,
  int limit = 5,
  bool dots = true,
}) {
  final showDots = dots && limit > 4 && limit < pages;
  final maxPrev = ((limit - 1) / 2).floor();
  final maxNext = ((limit - 1) / 2).ceil();
  final beforeDots = showDots && activePage > maxPrev + 1;
  final afterDots = showDots && activePage < pages - maxNext;
  final slots = limit - (afterDots ? 1 : 0) - (beforeDots ? 1 : 0);
  final range = activePage + maxNext;
  final lastItem = range >= pages ? pages : range - (afterDots ? 1 : 0);
  final amount = math.min(pages, slots);

  final items = activePage - maxPrev <= 1
      ? List.generate(amount, (index) => index + 1)
      : List.generate(amount, (index) => lastItem - amount + 1 + index);

  return (items: items, beforeDots: beforeDots, afterDots: afterDots);
}
