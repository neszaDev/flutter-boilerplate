/// The part of the phone's notification service the toaster demo uses (fake it in tests).
abstract interface class PhoneNotifier {
  /// Asks for permission when the user has not decided yet. True when notifications may show.
  Future<bool> requestPermission();

  /// Shows the notification now, or after [delay]. [channel] is the name Android lists in the
  /// app's notification settings. False when the phone refused it.
  Future<bool> show({
    required String title,
    required String body,
    required String channel,
    Duration? delay,
  });
}

/// What happened to a demo notification.
enum PhoneNotificationResult {
  /// On screen now.
  shown,

  /// Will show after the delay, even if the app is closed by then.
  scheduled,

  /// The user turned notifications off for the app.
  denied,

  /// The phone has no notification service for the app, or refused this one.
  unsupported,
}

/// Shows a notification (now, or after [delay]), asking for permission first when the user
/// has not decided. The phone counterpart of the web demo's desktop notification.
Future<PhoneNotificationResult> sendPhoneNotification(
  PhoneNotifier notifier, {
  required String title,
  required String body,
  required String channel,
  Duration? delay,
}) async {
  if (!await notifier.requestPermission()) {
    return PhoneNotificationResult.denied;
  }
  final shown = await notifier.show(title: title, body: body, channel: channel, delay: delay);
  if (!shown) {
    return PhoneNotificationResult.unsupported;
  }
  return delay == null ? PhoneNotificationResult.shown : PhoneNotificationResult.scheduled;
}
