import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final _log = appLogger('device.notifications');

/// Notifications shown by the app itself (no push server). For push notifications, add FCM /
/// APNs behind this same class; see docs/device-features.md.
class LocalNotifications {
  LocalNotifications._();

  static final instance = LocalNotifications._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// False where the plugin couldn't start (tests, unsupported platforms). Tell this apart from
  /// a refused permission ([requestPermission] returns false for both).
  bool get isAvailable => _ready;

  static const _channelId = 'general';

  /// Called once in `main.dart`. Asks no permission yet: that waits until the user wants one.
  Future<void> initialize() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        ),
      );
      _ready = true;
    } on MissingPluginException {
      // Tests and platforms without the plugin.
    } on PlatformException catch (error) {
      _log.warning('Notifications unavailable', error);
    }
  }

  /// Asks for permission (iOS; Android 13+). True when notifications may be shown.
  Future<bool> requestPermission() async {
    if (!_ready) {
      return false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        true;
  }

  NotificationDetails _details({required String channelName, String? channelDescription}) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        // Show it even while the app is open.
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      );

  /// Shows a notification now. [channelName] is what Android lists in the app's settings.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelName,
    String? channelDescription,
  }) async {
    if (!_ready) {
      return;
    }
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(
        channelName: channelName,
        channelDescription: channelDescription,
      ),
    );
  }

  /// Shows a notification after [delay], even if the app is closed by then.
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    required String channelName,
    String? channelDescription,
  }) async {
    if (!_ready) {
      return;
    }
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      // A relative time needs no time-zone database: UTC is exact for "in 5 seconds".
      scheduledDate: tz.TZDateTime.now(tz.UTC).add(delay),
      notificationDetails: _details(
        channelName: channelName,
        channelDescription: channelDescription,
      ),
      // Inexact needs no SCHEDULE_EXACT_ALARM permission; Android may delay it slightly.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
