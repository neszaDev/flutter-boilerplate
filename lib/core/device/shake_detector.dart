import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_boilerplate/core/logging/app_logger.dart';
import 'package:sensors_plus/sensors_plus.dart';

final _log = appLogger('device.shake');

/// Standard gravity, m/s².
const gravity = 9.80665;

/// Turns accelerometer samples into "the phone was shaken" events.
///
/// A shake is [minJolts] jolts above [threshold] g within [window], so a single bump (setting
/// the phone down) doesn't count. After a shake, [cooldown] passes before the next one.
/// Pure logic: feed it samples in tests with [addSample].
class ShakeDetector {
  ShakeDetector({
    this.threshold = 2.7,
    this.minJolts = 2,
    this.window = const Duration(milliseconds: 1000),
    this.cooldown = const Duration(milliseconds: 1500),
    this.joltGap = const Duration(milliseconds: 120),
  });

  /// Total acceleration, in g (1 g at rest), that counts as a jolt.
  double threshold;
  final int minJolts;
  final Duration window;
  final Duration cooldown;

  /// Samples closer than this belong to the same jolt.
  final Duration joltGap;

  final _jolts = <DateTime>[];
  DateTime? _lastShake;

  /// Acceleration in g for a sample (including gravity) in m/s².
  static double gForce(double x, double y, double z) => math.sqrt(x * x + y * y + z * z) / gravity;

  /// Adds one sample; true when it completes a shake.
  bool addSample(double x, double y, double z, DateTime at) {
    if (gForce(x, y, z) < threshold) {
      return false;
    }
    final last = _lastShake;
    if (last != null && at.difference(last) < cooldown) {
      return false;
    }
    if (_jolts.isNotEmpty && at.difference(_jolts.last) < joltGap) {
      return false;
    }
    _jolts
      ..add(at)
      ..removeWhere((jolt) => at.difference(jolt) > window);
    if (_jolts.length >= minJolts) {
      _jolts.clear();
      _lastShake = at;
      return true;
    }
    return false;
  }

  void reset() {
    _jolts.clear();
    _lastShake = null;
  }
}

/// Shake events from the accelerometer. Empty on devices without one.
Stream<DateTime> shakes({ShakeDetector? detector}) {
  final shake = detector ?? ShakeDetector();
  return accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
      .handleError((Object error) => _log.info('No accelerometer: $error'))
      .where((event) => shake.addSample(event.x, event.y, event.z, event.timestamp))
      .map((event) => event.timestamp);
}
