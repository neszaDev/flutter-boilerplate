import 'package:flutter_boilerplate/features/showcase/base/base_a_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('carouselSlideOf', () {
    test('wraps any page onto one of the slides', () {
      expect(carouselSlideOf(0, 3), 0);
      expect(carouselSlideOf(4, 3), 1);
      expect(carouselSlideOf(carouselStartPage(3) - 1, 3), 2);
    });
  });

  group('carouselStartPage', () {
    test('starts on the first slide, far enough from zero to go back', () {
      final start = carouselStartPage(3);
      expect(carouselSlideOf(start, 3), 0);
      expect(start, greaterThan(3));
    });
  });

  group('carouselPageFor', () {
    test('moves forward to a later slide', () {
      expect(carouselPageFor(from: 3000, slide: 1, count: 3), 3001);
    });

    test('loops back the short way from the first slide to the last', () {
      expect(carouselPageFor(from: 3000, slide: 2, count: 3), 2999);
    });

    test('loops forward the short way from the last slide to the first', () {
      expect(carouselPageFor(from: 3002, slide: 0, count: 3), 3003);
    });

    test('stays on the page of the current slide', () {
      expect(carouselPageFor(from: 3001, slide: 1, count: 3), 3001);
    });
  });

  group('fillRows', () {
    test('shares the spare room of a row equally', () {
      expect(fillRows([40, 60], 200, gap: 4), [
        [88, 108],
      ]);
    });

    test('starts a new row for an item that does not fit', () {
      expect(fillRows([100, 80, 120], 200, gap: 4), [
        [108, 88],
        [200],
      ]);
    });

    test('gives an item wider than the row the whole row', () {
      expect(fillRows([50, 300], 200), [
        [200],
        [200],
      ]);
    });

    test('lays out nothing for no items', () {
      expect(fillRows([], 200), isEmpty);
    });
  });
}
