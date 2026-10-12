import 'package:flutter_boilerplate/core/device/shake_detector.dart';
import 'package:flutter_boilerplate/features/device/compass.dart';
import 'package:flutter_boilerplate/features/device/scanner_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShakeDetector', () {
    final start = DateTime(2026, 10, 7, 12);
    DateTime at(int ms) => start.add(Duration(milliseconds: ms));
    // 3.5 g along x, at rest otherwise.
    const jolt = 3.5 * gravity;

    test('ignores the phone at rest', () {
      final detector = ShakeDetector();

      expect(detector.addSample(0, 0, gravity, at(0)), isFalse);
      expect(ShakeDetector.gForce(0, 0, gravity), closeTo(1, 0.001));
    });

    test('needs two jolts within the window', () {
      final detector = ShakeDetector();

      expect(detector.addSample(jolt, 0, 0, at(0)), isFalse);
      expect(detector.addSample(jolt, 0, 0, at(300)), isTrue);
    });

    test('does not count a single bump twice', () {
      final detector = ShakeDetector();

      expect(detector.addSample(jolt, 0, 0, at(0)), isFalse);
      // Samples 20 ms apart belong to the same jolt.
      expect(detector.addSample(jolt, 0, 0, at(20)), isFalse);
    });

    test('forgets jolts older than the window', () {
      final detector = ShakeDetector();

      detector.addSample(jolt, 0, 0, at(0));
      expect(detector.addSample(jolt, 0, 0, at(1500)), isFalse);
    });

    test('waits for the cooldown before the next shake', () {
      final detector = ShakeDetector();
      detector
        ..addSample(jolt, 0, 0, at(0))
        ..addSample(jolt, 0, 0, at(300));

      expect(detector.addSample(jolt, 0, 0, at(600)), isFalse);
      expect(detector.addSample(jolt, 0, 0, at(2000)), isFalse);
      expect(detector.addSample(jolt, 0, 0, at(2300)), isTrue);
    });

    test('follows a lower threshold', () {
      final detector = ShakeDetector(threshold: 1.5);
      const gentle = 2 * gravity;

      detector.addSample(gentle, 0, 0, at(0));
      expect(detector.addSample(gentle, 0, 0, at(300)), isTrue);
    });
  });

  group('compass', () {
    test('points north when the field runs along +y', () {
      expect(headingFromMagnetometer(0, 30), closeTo(0, 0.001));
      expect(compassPoint(0), CompassPoint.n);
    });

    test('turns clockwise', () {
      expect(headingFromMagnetometer(-30, 0), closeTo(90, 0.001));
      expect(compassPoint(90), CompassPoint.e);
      expect(compassPoint(225), CompassPoint.sw);
      expect(compassPoint(350), CompassPoint.n);
    });
  });

  group('linkIn (scanner)', () {
    test('offers web links only', () {
      expect(linkIn('https://example.com/a'), Uri.parse('https://example.com/a'));
      expect(linkIn('javascript:alert(1)'), isNull);
      expect(linkIn('intent://scan/#Intent;scheme=zxing;end'), isNull);
      expect(linkIn('plain text'), isNull);
    });
  });
}
