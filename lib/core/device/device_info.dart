import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The phone in one line, for debug info and problem reports: "Pixel 8 · Android 15 (API 35)".
final deviceSummaryProvider = FutureProvider<String>((ref) async {
  try {
    final info = await DeviceInfoPlugin().deviceInfo;
    return switch (info) {
      AndroidDeviceInfo() =>
        '${info.manufacturer} ${info.model} · Android ${info.version.release} '
            '(API ${info.version.sdkInt})${info.isPhysicalDevice ? '' : ' · emulator'}',
      IosDeviceInfo() =>
        '${info.utsname.machine} · ${info.systemName} ${info.systemVersion}'
            '${info.isPhysicalDevice ? '' : ' · simulator'}',
      _ => info.data['model']?.toString() ?? 'unknown device',
    };
  } on Object {
    return 'unknown device';
  }
});
