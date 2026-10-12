import 'package:flutter_boilerplate/features/showcase/base/base_b_page_items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pageItems', () {
    group('with more pages than slots', () {
      test('shows the first pages and a trailing ellipsis near the start', () {
        final result = pageItems(activePage: 3, pages: 10);

        expect(result.items, [1, 2, 3, 4]);
        expect(result.beforeDots, isFalse);
        expect(result.afterDots, isTrue);
      });

      test('centres the active page between two ellipses in the middle', () {
        final result = pageItems(activePage: 6, pages: 10);

        expect(result.items, [5, 6, 7]);
        expect(result.beforeDots, isTrue);
        expect(result.afterDots, isTrue);
      });

      test('shows the last pages and a leading ellipsis near the end', () {
        final result = pageItems(activePage: 10, pages: 10);

        expect(result.items, [7, 8, 9, 10]);
        expect(result.beforeDots, isTrue);
        expect(result.afterDots, isFalse);
      });

      test('uses every slot for pages when dots are off', () {
        expect(pageItems(activePage: 6, pages: 10, dots: false).items, [4, 5, 6, 7, 8]);
      });
    });

    group('with fewer pages than slots', () {
      test('lists every page without ellipses', () {
        final result = pageItems(activePage: 2, pages: 3);

        expect(result.items, [1, 2, 3]);
        expect(result.beforeDots, isFalse);
        expect(result.afterDots, isFalse);
      });
    });
  });
}
