import 'dart:async';

import 'package:flutter/widgets.dart';

/// Scrolls the enclosing list while something dragged is held near its top or bottom edge,
/// faster the closer it gets (a [Draggable] does not; a `ReorderableListView` does).
///
/// Call [start] when the drag starts, [update] with each pointer position, and [stop] when it
/// ends and in `dispose`.
class EdgeAutoScroll {
  static const _edge = 72.0;
  static const _maxStep = 18.0;
  static const _frame = Duration(milliseconds: 16);

  ScrollableState? _scrollable;
  Offset? _pointer;
  Timer? _timer;

  /// Finds the list around [context] and starts watching the pointer.
  void start(BuildContext context) {
    stop();
    _scrollable = Scrollable.maybeOf(context);
    if (_scrollable != null) {
      _timer = Timer.periodic(_frame, (_) => _tick());
    }
  }

  void update(Offset globalPosition) => _pointer = globalPosition;

  void stop() {
    _timer?.cancel();
    _timer = null;
    _scrollable = null;
    _pointer = null;
  }

  void _tick() {
    final scrollable = _scrollable;
    final pointer = _pointer;
    if (scrollable == null || pointer == null || !scrollable.mounted) {
      return;
    }
    final box = scrollable.context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return;
    }
    final top = box.localToGlobal(Offset.zero).dy;
    final bottom = top + box.size.height;
    final double closeness;
    if (pointer.dy < top + _edge) {
      closeness = -(1 - (pointer.dy - top) / _edge);
    } else if (pointer.dy > bottom - _edge) {
      closeness = 1 - (bottom - pointer.dy) / _edge;
    } else {
      return;
    }
    final position = scrollable.position;
    final target = (position.pixels + _maxStep * closeness.clamp(-1, 1)).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != position.pixels) {
      position.jumpTo(target);
    }
  }
}
