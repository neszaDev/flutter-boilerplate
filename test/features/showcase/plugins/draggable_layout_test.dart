import 'package:flutter_boilerplate/features/showcase/plugins/draggable_layout.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _ids(List<GridCard> layout) => [for (final card in layout) card.id];

void main() {
  group('moveCard', () {
    test('moves a card to the place of the card it is dropped on', () {
      expect(_ids(moveCard(baseLayout, '1', '4')), ['3', '2', '4', '1', '5', '6']);
    });

    test('keeps the pinned card in place while the others flow around it', () {
      final moved = moveCard(baseLayout, '6', '1');

      expect(_ids(moved), ['6', '2', '1', '3', '4', '5']);
      expect(moved[1].pinned, isTrue);
    });

    test('leaves the layout alone when the target is pinned or the same card', () {
      expect(moveCard(baseLayout, '1', '2'), same(baseLayout));
      expect(moveCard(baseLayout, '3', '3'), same(baseLayout));
    });
  });

  group('toggleCardSize', () {
    test('flips only the chosen size of the chosen card', () {
      final layout = toggleCardSize(baseLayout, '5', CardSize.wide);

      expect(layout.firstWhere((card) => card.id == '5').wide, isFalse);
      expect(layout.firstWhere((card) => card.id == '5').tall, isFalse);
      expect(layout.first, same(baseLayout.first));
    });
  });

  group('parseStoredLayout', () {
    test('reads back a saved layout', () {
      expect(parseStoredLayout(encodeLayout(baseLayout)), baseLayout);
    });

    test('ignores missing, malformed or foreign data', () {
      expect(parseStoredLayout(null), isNull);
      expect(parseStoredLayout('{not json'), isNull);
      expect(parseStoredLayout('[{"i":"0","x":0,"y":0,"w":4,"h":16}]'), isNull);
      expect(parseStoredLayout('[]'), isNull);
      expect(
        parseStoredLayout('[{"id":"1","accent":"red","wide":false,"tall":false,"pinned":false}]'),
        isNull,
      );
    });

    test('saves the accents under the web app’s names', () {
      expect(encodeLayout(baseLayout), contains('"accent":"ink-950"'));
    });
  });

  group('gridRows', () {
    test('puts every card on its own row in one column', () {
      expect(gridRows(baseLayout, 1).map(_ids), [
        ['1'],
        ['2'],
        ['3'],
        ['4'],
        ['5'],
        ['6'],
      ]);
    });

    test('gives a wide card a row of its own in two columns', () {
      expect(gridRows(baseLayout, 2).map(_ids), [
        ['1', '2'],
        ['3', '4'],
        ['5'],
        ['6'],
      ]);
    });

    test('starts a new row when a wide card does not fit in what is left', () {
      final layout = moveCard(baseLayout, '5', '3');

      expect(gridRows(layout, 2).map(_ids), [
        ['1', '2'],
        ['5'],
        ['3', '4'],
        ['6'],
      ]);
      expect(gridRows(layout, 3).map(_ids), [
        ['1', '2'],
        ['5', '3'],
        ['4', '6'],
      ]);
    });
  });
}
