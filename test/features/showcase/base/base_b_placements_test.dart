import 'dart:ui';

import 'package:flutter_boilerplate/features/showcase/base/base_b_placements.dart';
import 'package:flutter_test/flutter_test.dart';

const _screen = Size(390, 800);
const _box = Size(120, 40);

Placement _at(PlacementSide side, PlacementAlign align) => (side: side, align: align);

void main() {
  group('placements', () {
    test('lists every side and alignment once, in the Vue order', () {
      expect(placements, hasLength(12));
      expect(placements.toSet(), hasLength(12));
      expect(placements.first, _at(PlacementSide.top, PlacementAlign.start));
      expect(placements.last, _at(PlacementSide.left, PlacementAlign.end));
    });
  });

  group('placeBox', () {
    // A 100 × 40 trigger in the middle of the screen.
    const target = Rect.fromLTWH(145, 380, 100, 40);

    test('puts the box above, below or beside the trigger, a gap away', () {
      Offset place(PlacementSide side) => placeBox(
        target: target,
        size: _box,
        bounds: _screen,
        placement: _at(side, PlacementAlign.center),
      );

      expect(place(PlacementSide.top), const Offset(135, 336));
      expect(place(PlacementSide.bottom), const Offset(135, 424));
      expect(place(PlacementSide.left), const Offset(21, 380));
      expect(place(PlacementSide.right), const Offset(249, 380));
    });

    test('lines the box up with the start, centre or end of the trigger', () {
      Offset place(PlacementAlign align) => placeBox(
        target: target,
        size: _box,
        bounds: _screen,
        placement: _at(PlacementSide.bottom, align),
      );

      expect(place(PlacementAlign.start).dx, 145);
      expect(place(PlacementAlign.center).dx, 135);
      expect(place(PlacementAlign.end).dx, 125);
    });

    test('flips to the opposite side when there is no room', () {
      final offset = placeBox(
        target: const Rect.fromLTWH(145, 20, 100, 40),
        size: _box,
        bounds: _screen,
        placement: _at(PlacementSide.top, PlacementAlign.center),
      );

      expect(offset.dy, 64);
    });

    test('shifts along the side to stay inside the screen', () {
      final offset = placeBox(
        target: const Rect.fromLTWH(300, 380, 80, 40),
        size: _box,
        bounds: _screen,
        placement: _at(PlacementSide.bottom, PlacementAlign.start),
      );

      expect(offset.dx, 390 - 8 - 120);
    });
  });

  group('resolveSide', () {
    test('keeps the side with more room when neither fits', () {
      final side = resolveSide(
        target: const Rect.fromLTWH(100, 0, 190, 40),
        size: const Size(200, 40),
        bounds: _screen,
        side: PlacementSide.left,
      );

      expect(side, PlacementSide.left);
    });
  });

  group('fitWidth', () {
    test('narrows a box beside the trigger to the room on that side', () {
      final width = fitWidth(
        target: const Rect.fromLTWH(20, 380, 120, 40),
        bounds: _screen,
        placement: _at(PlacementSide.right, PlacementAlign.center),
        preferred: 240,
      );

      expect(width, 390 - 8 - 140 - 4);
    });

    test('uses the opposite side when the asked one is too narrow', () {
      final width = fitWidth(
        target: const Rect.fromLTWH(250, 380, 120, 40),
        bounds: _screen,
        placement: _at(PlacementSide.right, PlacementAlign.center),
        preferred: 200,
      );

      expect(width, 200);
    });

    test('keeps the preferred width above and below, within the screen', () {
      final width = fitWidth(
        target: const Rect.fromLTWH(20, 380, 120, 40),
        bounds: const Size(200, 800),
        placement: _at(PlacementSide.top, PlacementAlign.start),
        preferred: 240,
      );

      expect(width, 184);
    });
  });
}
