import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The installed app: version from pubspec.yaml (`version: 1.0.0+1`) and the platform.
/// Read once at startup in `main.dart` (package_info_plus) and provided to the whole app.
class AppInfo {
  const AppInfo({required this.version, required this.buildNumber, required this.platform});

  final String version;
  final String buildNumber;

  /// `android`, `ios`, …
  final String platform;

  /// Sent as `X-Client` so backend logs show which app build made a request.
  String get clientName => 'marksheet-app/$version+$buildNumber ($platform)';
}

final appInfoProvider = Provider<AppInfo>(
  (ref) => const AppInfo(version: '0.0.0', buildNumber: '0', platform: 'unknown'),
);
