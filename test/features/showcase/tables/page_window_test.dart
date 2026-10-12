import 'package:flutter_boilerplate/features/showcase/tables/page_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pageWindow', () {
    group('Few pages', () {
      test('lists every page when they fit in the limit', () {
        expect(pageWindow(page: 2, pages: 3), [1, 2, 3]);
      });

      test('lists nothing when there are no pages', () {
        expect(pageWindow(page: 1, pages: 0), isEmpty);
      });
    });

    group('Many pages', () {
      test('centres the window on the current page with gaps on both sides', () {
        expect(pageWindow(page: 5, pages: 10), [null, 3, 4, 5, 6, 7, null]);
      });

      test('pins the window to the start on the first page', () {
        expect(pageWindow(page: 1, pages: 10), [1, 2, 3, 4, 5, null]);
      });

      test('pins the window to the end on the last page', () {
        expect(pageWindow(page: 10, pages: 10, limit: 3), [null, 8, 9, 10]);
      });
    });
  });
}
