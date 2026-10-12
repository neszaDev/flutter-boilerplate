import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/device/biometrics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/sign_out.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/brand.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/lock/app_lock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks, then signs out. Used by the menu and settings.
Future<void> confirmSignOut(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final confirmed = await confirm(
    context,
    title: l10n.settingsPageSignOutConfirmTitle,
    text: l10n.settingsPageSignOutConfirmText,
    confirmLabel: l10n.settingsPageSignOut,
    cancelLabel: l10n.commonCancel,
    destructive: false,
  );
  if (confirmed) {
    await signOutToWelcome(ref);
  }
}

/// `/dashboard/settings`: language, theme, app lock, shake menu, haptics.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final biometrics = ref.watch(biometricStatusProvider).value;
    final method = biometrics?.method ?? UnlockMethod.none;
    final current = Localizations.localeOf(context).languageCode;

    Future<void> toggleLock({required bool enabled}) async {
      if (!enabled) {
        await controller.setAppLock(enabled: false);
        return;
      }
      final outcome = await ref
          .read(appLockProvider.notifier)
          .enable(l10n.settingsPageAppLockReason);
      if (context.mounted && outcome != AuthOutcome.success && outcome != AuthOutcome.canceled) {
        showToast(context, l10n.settingsPageAppLockUnavailable, tone: ToastTone.error);
      }
    }

    return AppPage(
      title: l10n.settingsPageTitle,
      description: Text(l10n.settingsPageDescription),
      children: [
        _Section(
          title: l10n.settingsPageSectionAppearance,
          children: [
            ListTile(
              title: Text(l10n.settingsPageLanguageLabel),
              trailing: DropdownButton<String?>(
                value: settings.locale?.languageCode,
                underline: const SizedBox.shrink(),
                onChanged: (code) => controller.setLocale(code == null ? null : Locale(code)),
                items: [
                  DropdownMenuItem(
                    child: Text('${l10n.settingsPageThemeSystem} (${languageName(current)})'),
                  ),
                  for (final locale in AppConfig.locales)
                    DropdownMenuItem(
                      value: locale.languageCode,
                      child: Text(languageName(locale.languageCode)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.settingsPageThemeLabel, style: context.text.titleSmall),
                  const SizedBox(height: Space.sm),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_outlined, size: 18),
                        label: Text(l10n.settingsPageThemeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_outlined, size: 18),
                        label: Text(l10n.settingsPageThemeDark),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.phone_iphone, size: 18),
                        label: Text(l10n.settingsPageThemeAuto),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (selection) => controller.setThemeMode(selection.first),
                  ),
                ],
              ),
            ),
          ],
        ),
        _Section(
          title: l10n.settingsPageSectionSecurity,
          children: [
            SwitchListTile(
              key: const Key('settings.appLock'),
              value: settings.appLock,
              onChanged: method == UnlockMethod.none
                  ? null
                  : (enabled) => toggleLock(enabled: enabled),
              secondary: Icon(
                method == UnlockMethod.faceId || method == UnlockMethod.face
                    ? Icons.face
                    : Icons.fingerprint,
              ),
              title: Text(
                l10n.settingsPageAppLockLabel(
                  method == UnlockMethod.none
                      ? l10n.biometricsGeneric
                      : unlockMethodName(l10n, method),
                ),
              ),
              subtitle: Text(
                method == UnlockMethod.none
                    ? l10n.settingsPageAppLockUnavailable
                    : l10n.settingsPageAppLockHint(
                        unlockMethodName(l10n, method),
                        '${AppConfig.appLockGrace.inSeconds}',
                      ),
              ),
            ),
          ],
        ),
        _Section(
          title: l10n.settingsPageSectionShortcuts,
          children: [
            SwitchListTile(
              value: settings.shakeMenu,
              onChanged: (enabled) => controller.setShakeMenu(enabled: enabled),
              secondary: const Icon(Icons.vibration),
              title: Text(l10n.settingsPageShakeLabel),
              subtitle: Text(l10n.settingsPageShakeHint),
            ),
            SwitchListTile(
              value: settings.haptics,
              onChanged: (enabled) => controller.setHaptics(enabled: enabled),
              secondary: const Icon(Icons.touch_app_outlined),
              title: Text(l10n.settingsPageHapticsLabel),
              subtitle: Text(l10n.settingsPageHapticsHint),
            ),
          ],
        ),
        _Section(
          title: l10n.settingsPageSectionAccount,
          children: [
            ListTile(
              leading: Icon(Icons.logout, color: context.colors.pen),
              title: Text(
                l10n.settingsPageSignOut,
                style: TextStyle(color: context.colors.pen),
              ),
              onTap: () => confirmSignOut(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: Space.xs, bottom: Space.sm),
        child: FormLabel(title),
      ),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    ],
  );
}
