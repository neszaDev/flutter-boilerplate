import 'package:flutter_boilerplate/features/showcase/campus/rows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('multi-language rows', () {
    test('start with empty Thai and English rows', () {
      expect(defaultRows().map((row) => row.key), ['th', 'en']);
    });

    test('appends an empty row', () {
      expect(addRow(defaultRows(), 'new').last, const LanguageRow(id: 'new', key: '', value: ''));
    });

    test('removes only the chosen row, even when keys repeat', () {
      final rows = [...defaultRows(), const LanguageRow(id: 'row-th-2', key: 'th', value: 'ซ้ำ')];

      expect(removeRow(rows, 'row-th').map((row) => row.id), ['row-en', 'row-th-2']);
    });

    test('leaves the list empty without a refill id', () {
      expect(removeRow(const [LanguageRow(id: 'row-th', key: 'th', value: '')], 'row-th'), isEmpty);
    });

    test('puts a Thai row back when the last row is removed with a refill id', () {
      expect(
        removeRow(
          const [LanguageRow(id: 'row-en', key: 'en', value: '')],
          'row-en',
          refillId: 'fresh',
        ),
        [const LanguageRow(id: 'fresh', key: 'th', value: '')],
      );
    });

    test('updates the key and value of one row', () {
      expect(
        updateRow(defaultRows(), 'row-en', value: 'Hello')[1],
        const LanguageRow(id: 'row-en', key: 'en', value: 'Hello'),
      );
      expect(updateRow(defaultRows(), 'row-th', key: 'fr').first.key, 'fr');
    });

    test('serialise as the backend stores them, without the id', () {
      expect(defaultRows().first.toJson(), {'key': 'th', 'value': ''});
    });
  });
}
