import 'package:flutter_boilerplate/features/showcase/notifications/phone_notification.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_phone_notifier.dart';

Future<PhoneNotificationResult> _send(PhoneNotifier notifier, {Duration? delay}) =>
    sendPhoneNotification(
      notifier,
      title: 'Report ready',
      body: 'Spring term marks are in.',
      channel: 'Demo notifications',
      delay: delay,
    );

void main() {
  group('sendPhoneNotification', () {
    test('asks first, then shows the notification when the user allows', () async {
      final notifier = FakePhoneNotifier();

      expect(await _send(notifier), PhoneNotificationResult.shown);
      expect(notifier.permissionRequests, 1);
      expect(notifier.shown.single.title, 'Report ready');
      expect(notifier.shown.single.body, 'Spring term marks are in.');
      expect(notifier.shown.single.delay, isNull);
    });

    test('schedules the notification when a delay is given', () async {
      final notifier = FakePhoneNotifier();

      expect(
        await _send(notifier, delay: const Duration(seconds: 5)),
        PhoneNotificationResult.scheduled,
      );
      expect(notifier.shown.single.delay, const Duration(seconds: 5));
    });

    test('reports denied without showing anything when notifications are off', () async {
      final notifier = FakePhoneNotifier(granted: false);

      expect(await _send(notifier), PhoneNotificationResult.denied);
      expect(notifier.shown, isEmpty);
    });

    test('reports unsupported when the phone refuses the notification', () async {
      expect(await _send(FakePhoneNotifier(accepts: false)), PhoneNotificationResult.unsupported);
    });
  });
}
