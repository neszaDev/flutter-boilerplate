import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/device/shake_detector.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/device/device_widgets.dart';
import 'package:flutter_boilerplate/features/shake/shake_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// `/dashboard/device/shake`: watch the shake detector work, tune its threshold.
class ShakeScreen extends ConsumerStatefulWidget {
  const ShakeScreen({super.key});

  @override
  ConsumerState<ShakeScreen> createState() => _ShakeScreenState();
}

class _ShakeScreenState extends ConsumerState<ShakeScreen> {
  final _detector = ShakeDetector();
  StreamSubscription<AccelerometerEvent>? _subscription;
  late final ShakeMenuPause _pause;
  int _count = 0;
  DateTime? _last;
  double _force = 1;
  bool _unavailable = false;
  DateTime _lastRepaint = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    // The quick menu would open on every test shake; it resumes when this screen closes.
    _pause = ref.read(shakeMenuPausedProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pause.pause());
    _subscription = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      _onSample,
      onError: (Object _) => setState(() => _unavailable = true),
      cancelOnError: true,
    );
  }

  void _onSample(AccelerometerEvent event) {
    final shaken = _detector.addSample(event.x, event.y, event.z, event.timestamp);
    final now = DateTime.now();
    // The force display updates ~10 times a second, not at the 50 Hz sampling rate.
    if (!shaken && now.difference(_lastRepaint) < const Duration(milliseconds: 100)) {
      return;
    }
    _lastRepaint = now;
    setState(() {
      _force = ShakeDetector.gForce(event.x, event.y, event.z);
      if (shaken) {
        _count++;
        _last = event.timestamp;
        Haptics.medium();
      }
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    // Riverpod refuses state changes while the tree is torn down; resume after this frame.
    Future.microtask(_pause.resume).ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final number = NumberFormat.decimalPatternDigits(locale: context.localeName, decimalDigits: 1);
    final shakeMenu = ref.watch(settingsProvider.select((settings) => settings.shakeMenu));

    return AppPage(
      title: l10n.shakePageTitle,
      description: Text(l10n.shakePageDescription),
      children: [
        DemoCard(
          title: l10n.shakePageTitle,
          action: TextButton(
            onPressed: () => setState(() {
              _count = 0;
              _last = null;
              _detector.reset();
            }),
            child: Text(l10n.shakePageReset),
          ),
          child: _unavailable
              ? DeviceNotice(message: l10n.shakePageUnavailable)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        l10n.shakePageCount(_count),
                        style: context.type.figure,
                      ),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      _last == null
                          ? l10n.shakePageHint
                          : l10n.shakePageLast(context.formatTime(_last!)),
                      style: context.text.bodyMedium?.copyWith(color: context.colors.ink600),
                    ),
                    const SizedBox(height: Space.lg),
                    ValueRow(
                      label: l10n.shakePageForce,
                      value: l10n.shakePageForceValue(number.format(_force)),
                    ),
                    LinearProgressIndicator(
                      value: (_force / 4).clamp(0, 1),
                      color: _force >= _detector.threshold ? context.colors.pen : null,
                      semanticsLabel: l10n.shakePageForce,
                    ),
                    const SizedBox(height: Space.lg),
                    ValueRow(
                      label: l10n.shakePageSensitivity,
                      hint: l10n.shakePageSensitivityHint,
                      value: l10n.shakePageForceValue(number.format(_detector.threshold)),
                    ),
                    Slider(
                      value: _detector.threshold,
                      min: 1.5,
                      max: 4,
                      divisions: 25,
                      label: number.format(_detector.threshold),
                      onChanged: (value) => setState(() => _detector.threshold = value),
                    ),
                  ],
                ),
        ),
        DemoCard(
          title: l10n.shakePageQuickTitle,
          action: Switch(
            value: shakeMenu,
            onChanged: (enabled) =>
                ref.read(settingsProvider.notifier).setShakeMenu(enabled: enabled),
          ),
          child: Text(l10n.shakePageQuickText, style: context.text.bodyMedium),
        ),
      ],
    );
  }
}
