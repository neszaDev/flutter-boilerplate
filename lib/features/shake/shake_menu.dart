import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/api/api_client.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/config/app_info.dart';
import 'package:flutter_boilerplate/core/config/env.dart';
import 'package:flutter_boilerplate/core/device/device_info.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/device/shake_detector.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/app_router.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/access_denied_view.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/lock/app_lock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// True while a screen uses shakes itself (the shake demo): the quick menu stays closed.
final shakeMenuPausedProvider = NotifierProvider<ShakeMenuPause, bool>(ShakeMenuPause.new);

class ShakeMenuPause extends Notifier<bool> {
  @override
  bool build() => false;

  void pause() => state = true;

  void resume() => state = false;
}

/// Listens for shakes while the app is in front, unlocked and the setting is on, and opens the
/// quick menu. Wraps the whole app (`App.builder`).
class ShakeListener extends ConsumerStatefulWidget {
  const ShakeListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ShakeListener> createState() => _ShakeListenerState();
}

class _ShakeListenerState extends ConsumerState<ShakeListener> with WidgetsBindingObserver {
  StreamSubscription<DateTime>? _subscription;
  bool _open = false;
  bool _resumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _resumed = state == AppLifecycleState.resumed);
  }

  /// Listening costs battery: only while it can do something.
  void _sync({required bool listen}) {
    if (listen && _subscription == null) {
      _subscription = shakes().listen((_) => _show());
    } else if (!listen && _subscription != null) {
      unawaited(_subscription!.cancel());
      _subscription = null;
    }
  }

  Future<void> _show() async {
    final context = rootNavigatorKey.currentContext;
    if (_open || context == null) {
      return;
    }
    _open = true;
    Haptics.medium();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const ShakeMenuSheet(),
    );
    _open = false;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(settingsProvider.select((settings) => settings.shakeMenu));
    final locked = ref.watch(appLockProvider);
    final paused = ref.watch(shakeMenuPausedProvider);
    _sync(listen: enabled && _resumed && !locked && !paused);
    return widget.child;
  }
}

/// Shortcuts, a problem report and (outside production) debug info.
class ShakeMenuSheet extends ConsumerWidget {
  const ShakeMenuSheet({super.key});

  String _debugText(WidgetRef ref, BuildContext context) {
    final l10n = context.l10n;
    final info = ref.read(appInfoProvider);
    final user = ref.read(currentUserProvider);
    final expires = ref.read(tokenManagerProvider).current?.accessExpiresAt;
    return [
      '${l10n.shakeMenuEnvironment}: ${Env.name}',
      '${l10n.shakeMenuBackend}: ${Env.backendUrl}',
      '${l10n.shakeMenuAppVersion}: ${info.version}+${info.buildNumber}',
      '${l10n.shakeMenuDevice}: ${ref.read(deviceSummaryProvider).value ?? '…'}',
      '${l10n.shakeMenuUser}: ${user?.email ?? l10n.shakeMenuSignedOut}',
      '${l10n.shakeMenuRole}: ${roleLabel(l10n, user?.role)}',
      if (expires != null) '${l10n.shakeMenuTokenExpires}: ${context.formatDateTime(expires)}',
      '${l10n.shakeMenuLanguage}: ${context.localeName}',
    ].join('\n');
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    // A report carries what support needs, never tokens.
    final body = '\n\n---\n${_debugText(ref, context)}';
    final uri = Uri(
      scheme: 'mailto',
      path: Env.supportEmail,
      query: _encodeQuery({'subject': l10n.shakeMenuReportSubject(AppConfig.name), 'body': body}),
    );
    if (!await launchUrl(uri) && context.mounted) {
      showToast(context, l10n.commonNotAvailable, tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final signedIn = ref.watch(currentUserProvider) != null;
    final router = ref.read(routerProvider);
    final settings = ref.watch(settingsProvider);
    final dark = switch (settings.themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    // Keep the device line filled in when the sheet opens.
    ref.watch(deviceSummaryProvider);

    void close() => Navigator.pop(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.shakeMenuTitle, style: context.text.headlineSmall),
                const SizedBox(height: Space.xs),
                Text(l10n.shakeMenuSubtitle, style: context.text.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: Space.page),
          if (Env.supportEmail.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: Text(l10n.shakeMenuReport),
              onTap: () => _report(context, ref),
            ),
          ListTile(
            leading: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            title: Text(l10n.shakeMenuTheme),
            onTap: () {
              unawaited(
                ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(dark ? ThemeMode.light : ThemeMode.dark),
              );
              close();
            },
          ),
          if (signedIn) ...[
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: Text(l10n.shakeMenuOverview),
              onTap: () {
                close();
                router.go(Routes.dashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.shakeMenuSettings),
              onTap: () {
                close();
                unawaited(router.push(Routes.settings));
              },
            ),
          ],
          if (!Env.isProd) ...[
            const SizedBox(height: Space.page),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              child: SheetCard(
                title: l10n.shakeMenuDebugTitle,
                action: IconButton(
                  tooltip: l10n.shakeMenuCopyDebug,
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _debugText(ref, context)));
                    if (context.mounted) {
                      showToast(context, l10n.commonCopied, tone: ToastTone.success);
                    }
                  },
                ),
                child: SelectableText(_debugText(ref, context), style: context.type.code),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _encodeQuery(Map<String, String> params) => params.entries
    .map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
    .join('&');
