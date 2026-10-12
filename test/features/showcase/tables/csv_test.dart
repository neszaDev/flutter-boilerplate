import 'package:flutter_boilerplate/features/showcase/tables/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toCsv', () {
    test('joins cells with commas and rows with CRLF', () {
      expect(
        toCsv([
          ['Name', 'Score'],
          ['Ada', 36],
        ]),
        'Name,Score\r\nAda,36',
      );
    });

    test('quotes cells holding commas, quotes or line breaks', () {
      expect(
        toCsv([
          ['Smith, Jane', 'say "hi"', 'two\nlines'],
        ]),
        '"Smith, Jane","say ""hi""","two\nlines"',
      );
    });

    test('defuses cells a spreadsheet would run as a formula', () {
      expect(
        toCsv([
          ['=SUM(A1:A2)', '@cmd', -4],
        ]),
        "'=SUM(A1:A2),'@cmd,-4",
      );
    });

    test('prints whole doubles without a decimal part', () {
      expect(
        toCsv([
          [36.0, 2.5],
        ]),
        '36,2.5',
      );
    });
  });
}
