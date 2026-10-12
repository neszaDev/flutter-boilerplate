import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/device/compass.dart';
import 'package:flutter_boilerplate/features/device/device_widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

typedef _Reading = (double, double, double);

/// `/dashboard/device/motion`: live accelerometer, gyroscope and magnetometer readings, and a
/// compass. Sensors are only listened to while this screen is open.
class MotionScreen extends StatefulWidget {
  const MotionScreen({super.key});

  @override
  State<MotionScreen> createState() => _MotionScreenState();
}

class _MotionScreenState extends State<MotionScreen> {
  final _subscriptions = <StreamSubscription<Object>>[];
  _Reading? _accelerometer;
  _Reading? _movement;
  _Reading? _gyroscope;
  _Reading? _magnetometer;
  final _missing = <String>{};
  Timer? _repaint;

  @override
  void initState() {
    super.initState();
    const period = SensorInterval.uiInterval;
    void listen<T extends Object>(String name, Stream<T> stream, void Function(T event) onEvent) {
      _subscriptions.add(
        stream.listen(
          onEvent,
          onError: (Object _) => setState(() => _missing.add(name)),
          cancelOnError: true,
        ),
      );
    }

    listen(
      'accelerometer',
      accelerometerEventStream(samplingPeriod: period),
      (event) => _accelerometer = (event.x, event.y, event.z),
    );
    listen(
      'movement',
      userAccelerometerEventStream(samplingPeriod: period),
      (event) => _movement = (event.x, event.y, event.z),
    );
    listen(
      'gyroscope',
      gyroscopeEventStream(samplingPeriod: period),
      (event) => _gyroscope = (event.x, event.y, event.z),
    );
    listen(
      'magnetometer',
      magnetometerEventStream(samplingPeriod: period),
      (event) => _magnetometer = (event.x, event.y, event.z),
    );
    // Samples arrive ~60 times a second; ten repaints a second are enough to read them.
    _repaint = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _repaint?.cancel();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget sensor(String key, String title, String hint, _Reading? values, {int digits = 2}) =>
        DemoCard(
          title: title,
          description: hint,
          child: _missing.contains(key)
              ? DeviceNotice(message: l10n.motionPageUnavailable)
              : AxisReadings(values: values, digits: digits),
        );

    final magnetometer = _magnetometer;
    final heading = magnetometer == null
        ? null
        : headingFromMagnetometer(magnetometer.$1, magnetometer.$2);

    return AppPage(
      title: l10n.motionPageTitle,
      description: Text(l10n.motionPageDescription),
      children: [
        DemoCard(
          title: l10n.motionPageCompass,
          description: l10n.motionPageCompassHint,
          child: _missing.contains('magnetometer')
              ? DeviceNotice(message: l10n.motionPageUnavailable)
              : heading == null
              ? Text(l10n.motionPageWaiting)
              : _Compass(heading: heading),
        ),
        sensor(
          'accelerometer',
          l10n.motionPageAccelerometer,
          l10n.motionPageAccelerometerHint,
          _accelerometer,
        ),
        sensor('movement', l10n.motionPageMovement, l10n.motionPageMovementHint, _movement),
        sensor('gyroscope', l10n.motionPageGyroscope, l10n.motionPageGyroscopeHint, _gyroscope),
        sensor(
          'magnetometer',
          l10n.motionPageMagnetometer,
          l10n.motionPageMagnetometerHint,
          _magnetometer,
          digits: 1,
        ),
      ],
    );
  }
}

class _Compass extends StatelessWidget {
  const _Compass({required this.heading});

  final double heading;

  String _pointName(AppLocalizations l10n, CompassPoint point) => switch (point) {
    CompassPoint.n => l10n.motionPageN,
    CompassPoint.ne => l10n.motionPageNe,
    CompassPoint.e => l10n.motionPageE,
    CompassPoint.se => l10n.motionPageSe,
    CompassPoint.s => l10n.motionPageS,
    CompassPoint.sw => l10n.motionPageSw,
    CompassPoint.w => l10n.motionPageW,
    CompassPoint.nw => l10n.motionPageNw,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final label = l10n.motionPageHeading(
      '${heading.round()}',
      _pointName(l10n, compassPoint(heading)),
    );
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 112,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.ply,
                border: Border.all(color: colors.ink300, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 6,
                    child: Text(l10n.motionPageN, style: context.type.formLabel),
                  ),
                  // The needle points north: rotate against the phone's heading.
                  Transform.rotate(
                    angle: -heading * math.pi / 180,
                    child: Icon(Icons.navigation, size: 56, color: colors.pen),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Space.card),
          Expanded(child: Text(label, style: context.type.figure)),
        ],
      ),
    );
  }
}
