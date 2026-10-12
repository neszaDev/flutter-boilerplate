import 'package:flutter_boilerplate/features/showcase/notifications/phone_notification.dart';

/// A stand-in for the phone's notification service.
class FakePhoneNotifier implements PhoneNotifier {
  FakePhoneNotifier({this.granted = true, this.accepts = true});

  /// What the permission prompt answers.
  final bool granted;

  /// Whether the phone takes the notification.
  final bool accepts;

  var permissionRequests = 0;
  final shown = <({String title, String body, String channel, Duration? delay})>[];

  @override
  Future<bool> requestPermission() async {
    permissionRequests += 1;
    return granted;
  }

  @override
  Future<bool> show({
    required String title,
    required String body,
    required String channel,
    Duration? delay,
  }) async {
    if (accepts) {
      shown.add((title: title, body: body, channel: channel, delay: delay));
    }
    return accepts;
  }
}
