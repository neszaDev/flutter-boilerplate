import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/device/biometrics_screen.dart';
import 'package:flutter_boilerplate/features/device/camera_screen.dart';
import 'package:flutter_boilerplate/features/device/device_info_screen.dart';
import 'package:flutter_boilerplate/features/device/haptics_screen.dart';
import 'package:flutter_boilerplate/features/device/location_screen.dart';
import 'package:flutter_boilerplate/features/device/motion_screen.dart';
import 'package:flutter_boilerplate/features/device/notifications_screen.dart';
import 'package:flutter_boilerplate/features/device/scanner_screen.dart';
import 'package:flutter_boilerplate/features/device/shake_screen.dart';
import 'package:flutter_boilerplate/features/device/share_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

GoRoute _device(String path, Widget screen) => GoRoute(
  path: path,
  builder: (context, state) =>
      RequirePermission(permission: Permission.useDeviceFeatures, child: screen),
);

/// The phone feature demos, each behind [Permission.useDeviceFeatures].
final deviceRoutes = <RouteBase>[
  _device(Routes.deviceBiometrics, const BiometricsScreen()),
  _device(Routes.deviceShake, const ShakeScreen()),
  _device(Routes.deviceMotion, const MotionScreen()),
  _device(Routes.deviceCamera, const CameraScreen()),
  _device(Routes.deviceScanner, const ScannerScreen()),
  _device(Routes.deviceLocation, const LocationScreen()),
  _device(Routes.deviceHaptics, const HapticsScreen()),
  _device(Routes.deviceNotifications, const DeviceNotificationsScreen()),
  _device(Routes.deviceInfo, const DeviceInfoScreen()),
  _device(Routes.deviceShare, const ShareScreen()),
];

/// `/dashboard/device`: the phone features, one tile each.
class DeviceHubScreen extends StatelessWidget {
  const DeviceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final features = [
      (
        Routes.deviceBiometrics,
        LucideIcons.fingerprint,
        l10n.devicePageBiometricsTitle,
        l10n.devicePageBiometricsText,
      ),
      (
        Routes.deviceShake,
        LucideIcons.vibrate,
        l10n.devicePageShakeTitle,
        l10n.devicePageShakeText,
      ),
      (
        Routes.deviceMotion,
        LucideIcons.compass,
        l10n.devicePageMotionTitle,
        l10n.devicePageMotionText,
      ),
      (
        Routes.deviceCamera,
        LucideIcons.camera,
        l10n.devicePageCameraTitle,
        l10n.devicePageCameraText,
      ),
      (
        Routes.deviceScanner,
        LucideIcons.scanLine,
        l10n.devicePageScannerTitle,
        l10n.devicePageScannerText,
      ),
      (
        Routes.deviceLocation,
        LucideIcons.mapPin,
        l10n.devicePageLocationTitle,
        l10n.devicePageLocationText,
      ),
      (
        Routes.deviceHaptics,
        LucideIcons.activity,
        l10n.devicePageHapticsTitle,
        l10n.devicePageHapticsText,
      ),
      (
        Routes.deviceNotifications,
        LucideIcons.bellRing,
        l10n.devicePageNotificationsTitle,
        l10n.devicePageNotificationsText,
      ),
      (
        Routes.deviceInfo,
        LucideIcons.smartphone,
        l10n.devicePageInfoTitle,
        l10n.devicePageInfoText,
      ),
      (Routes.deviceShare, LucideIcons.share2, l10n.devicePageShareTitle, l10n.devicePageShareText),
    ];

    return AppPage(
      title: l10n.devicePageTitle,
      description: Text(l10n.devicePageDescription),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, (path, icon, title, text)) in features.indexed) ...[
                if (index > 0) Divider(color: context.colors.ink200, indent: 72),
                ListTile(
                  key: Key('device.$path'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Space.page,
                    vertical: Space.xs,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: context.colors.primary.withValues(alpha: 0.12),
                    foregroundColor: context.colors.primary,
                    child: Icon(icon, size: 20),
                  ),
                  title: Text(title),
                  subtitle: Text(text),
                  trailing: const Icon(LucideIcons.chevronRight, size: 18),
                  onTap: () => context.push(path),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
