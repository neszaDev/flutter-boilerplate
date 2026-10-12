import 'dart:math' as math;
import 'dart:ui';

/// The side of its trigger a popover or tooltip opens on.
enum PlacementSide {
  top,
  bottom,
  right,
  left;

  /// The side across the trigger, where a box flips to when this one has no room.
  PlacementSide get opposite => switch (this) {
    top => bottom,
    bottom => top,
    right => left,
    left => right,
  };

  bool get isVertical => this == top || this == bottom;
}

/// Where the box lines up along its side: the trigger's start edge, its centre or its end edge.
enum PlacementAlign { start, center, end }

/// A side and an alignment around a trigger (the web app's `{ side, align }`).
typedef Placement = ({PlacementSide side, PlacementAlign align});

/// Above the trigger, centred: where a tooltip opens by default.
const Placement placementTop = (side: PlacementSide.top, align: PlacementAlign.center);

/// Below the trigger, centred: where a popover opens by default.
const Placement placementBottom = (side: PlacementSide.bottom, align: PlacementAlign.center);

/// Every placement, in the order the Vue demos list them.
const List<Placement> placements = [
  (side: PlacementSide.top, align: PlacementAlign.start),
  (side: PlacementSide.top, align: PlacementAlign.center),
  (side: PlacementSide.top, align: PlacementAlign.end),
  (side: PlacementSide.bottom, align: PlacementAlign.start),
  (side: PlacementSide.bottom, align: PlacementAlign.center),
  (side: PlacementSide.bottom, align: PlacementAlign.end),
  (side: PlacementSide.right, align: PlacementAlign.start),
  (side: PlacementSide.right, align: PlacementAlign.center),
  (side: PlacementSide.right, align: PlacementAlign.end),
  (side: PlacementSide.left, align: PlacementAlign.start),
  (side: PlacementSide.left, align: PlacementAlign.center),
  (side: PlacementSide.left, align: PlacementAlign.end),
];

/// Room on [side] of [target] inside [bounds], keeping [margin] from the edges.
double _room(PlacementSide side, Rect target, Size bounds, double margin) => switch (side) {
  PlacementSide.top => target.top - margin,
  PlacementSide.bottom => bounds.height - margin - target.bottom,
  PlacementSide.left => target.left - margin,
  PlacementSide.right => bounds.width - margin - target.right,
};

/// The side a box of [size] goes on: the asked side when it fits, else the opposite one when
/// that fits, else whichever has more room (like Radix's `flip`).
PlacementSide resolveSide({
  required Rect target,
  required Size size,
  required Size bounds,
  required PlacementSide side,
  double gap = 4,
  double margin = 8,
}) {
  double needed(PlacementSide side) => (side.isVertical ? size.height : size.width) + gap;
  final room = _room(side, target, bounds, margin);
  if (room >= needed(side)) {
    return side;
  }
  final oppositeRoom = _room(side.opposite, target, bounds, margin);
  if (oppositeRoom >= needed(side.opposite) || oppositeRoom > room) {
    return side.opposite;
  }
  return side;
}

/// The width for a box that would like to be [preferred] wide: on the left or right of
/// [target] it narrows to the room on that side (or on the opposite one, where it will flip to),
/// but never below [min]; above or below it narrows to the screen.
double fitWidth({
  required Rect target,
  required Size bounds,
  required Placement placement,
  required double preferred,
  double min = 160,
  double gap = 4,
  double margin = 8,
}) {
  final screen = math.max(0.0, bounds.width - 2 * margin);
  if (placement.side.isVertical) {
    return math.min(preferred, screen);
  }
  for (final side in [placement.side, placement.side.opposite]) {
    final room = _room(side, target, bounds, margin) - gap;
    if (room >= min) {
      return math.min(preferred, room);
    }
  }
  return math.min(preferred, screen);
}

/// The top-left corner of a box of [size] placed by [placement] next to [target], [gap] away
/// from it (Radix's `sideOffset`), inside [bounds]: it flips to the opposite side when it has no room (see
/// [resolveSide]), then shifts to stay [margin] inside the edges (like Radix's `shift`).
Offset placeBox({
  required Rect target,
  required Size size,
  required Size bounds,
  required Placement placement,
  double gap = 4,
  double margin = 8,
}) {
  final side = resolveSide(
    target: target,
    size: size,
    bounds: bounds,
    side: placement.side,
    gap: gap,
    margin: margin,
  );
  double along(double start, double end, double extent) => switch (placement.align) {
    PlacementAlign.start => start,
    PlacementAlign.center => (start + end - extent) / 2,
    PlacementAlign.end => end - extent,
  };
  final (x, y) = switch (side) {
    PlacementSide.top => (
      along(target.left, target.right, size.width),
      target.top - gap - size.height,
    ),
    PlacementSide.bottom => (along(target.left, target.right, size.width), target.bottom + gap),
    PlacementSide.left => (
      target.left - gap - size.width,
      along(target.top, target.bottom, size.height),
    ),
    PlacementSide.right => (target.right + gap, along(target.top, target.bottom, size.height)),
  };
  double clampInto(double value, double extent, double limit) =>
      math.max(margin, math.min(value, limit - margin - extent));
  return Offset(clampInto(x, size.width, bounds.width), clampInto(y, size.height, bounds.height));
}
