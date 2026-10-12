import 'package:flutter_boilerplate/features/showcase/campus/labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('badgeLabel', () {
    test('hides the badge at zero', () {
      expect(badgeLabel(0), isNull);
    });

    test('shows counts up to 99 and caps larger ones at 99+', () {
      expect(badgeLabel(7), '7');
      expect(badgeLabel(99), '99');
      expect(badgeLabel(100), '99+');
    });
  });

  group('qrFileName', () {
    test('turns the label into a safe file name', () {
      expect(qrFileName('MFU Campus 2026!'), 'qr-code-mfu-campus-2026.png');
    });

    test('keeps letters of other scripts', () {
      expect(qrFileName('มฟล. QR'), 'qr-code-มฟล-qr.png');
    });

    test('falls back to a plain name for an empty label', () {
      expect(qrFileName('  '), 'qr-code.png');
    });
  });

  group('initials', () {
    test('takes the first letters of the first two words', () {
      expect(initials('Alex Martin'), 'AM');
      expect(initials('  ada  '), 'A');
    });

    test('is empty for an empty name', () {
      expect(initials(''), '');
    });
  });
}
