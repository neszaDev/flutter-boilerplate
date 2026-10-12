import 'package:flutter/services.dart';

/// Haptic feedback that respects the "Haptic feedback" setting. Use these instead of calling
/// [HapticFeedback] directly. `App` keeps [enabled] in step with the setting.
abstract final class Haptics {
  static bool enabled = true;

  static void _play(Future<void> Function() effect) {
    if (enabled) {
      effect().ignore();
    }
  }

  /// An action worked (saved, uploaded, unlocked).
  static void success() => _play(HapticFeedback.lightImpact);

  /// An action failed.
  static void error() => _play(HapticFeedback.mediumImpact);

  /// A choice changed (segmented control, picker wheel).
  static void selection() => _play(HapticFeedback.selectionClick);

  static void light() => _play(HapticFeedback.lightImpact);

  static void medium() => _play(HapticFeedback.mediumImpact);

  static void heavy() => _play(HapticFeedback.heavyImpact);

  /// A longer buzz, for alerts.
  static void vibrate() => _play(HapticFeedback.vibrate);
}
