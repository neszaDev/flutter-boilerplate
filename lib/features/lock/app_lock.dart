import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/device/biometrics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/sign_out.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/brand.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the app is locked right now, when the user turned the lock on:
///
/// - a session restored at launch starts locked;
/// - a session started with the password in this run doesn't (the user just proved it);
/// - coming back after more than [AppConfig.appLockGrace] in the background locks again.
class AppLockController extends Notifier<bool> {
  DateTime? _backgroundedAt;

  /// Unlocked since the last lock event (launch or a long background).
  bool _unlocked = false;

  bool get _active => ref.read(settingsProvider).appLock && ref.read(sessionProvider) is SignedIn;

  @override
  bool build() {
    final enabled = ref.watch(settingsProvider.select((settings) => settings.appLock));
    final session = ref.watch(sessionProvider);
    if (session is SignedOut) {
      // The next session starts with the password, not from storage.
      _unlocked = true;
    }
    return enabled && session is SignedIn && !_unlocked;
  }

  void onLifecycle(AppLifecycleState lifecycle) {
    switch (lifecycle) {
      case AppLifecycleState.hidden || AppLifecycleState.paused:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final since = _backgroundedAt;
        _backgroundedAt = null;
        if (_active && since != null && DateTime.now().difference(since) > AppConfig.appLockGrace) {
          _unlocked = false;
          state = true;
        }
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  /// Shows the system prompt; unlocks on success.
  Future<AuthOutcome> unlock(String reason) async {
    final outcome = await ref.read(biometricServiceProvider).authenticate(reason: reason);
    if (outcome == AuthOutcome.success) {
      _unlocked = true;
      state = false;
    }
    return outcome;
  }

  /// Turns the lock on after the user proved they can unlock (no lock-out by accident).
  Future<AuthOutcome> enable(String reason) async {
    final outcome = await ref.read(biometricServiceProvider).authenticate(reason: reason);
    if (outcome == AuthOutcome.success) {
      _unlocked = true;
      await ref.read(settingsProvider.notifier).setAppLock(enabled: true);
    }
    return outcome;
  }
}

final appLockProvider = NotifierProvider<AppLockController, bool>(AppLockController.new);

/// Covers the app with the lock screen while locked, and hides content in the app switcher.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _lifecycle = state);
    ref.read(appLockProvider.notifier).onLifecycle(state);
    if (state == AppLifecycleState.resumed) {
      // A role changed by an admin shows up when the user comes back.
      unawaited(ref.read(sessionProvider.notifier).refreshProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockProvider);
    final lockEnabled = ref.watch(settingsProvider.select((settings) => settings.appLock));
    // In the app switcher, a locked-down app shows the cover instead of the last screen.
    final obscured = lockEnabled && _lifecycle != AppLifecycleState.resumed;
    return Stack(
      children: [
        widget.child,
        if (locked) const Positioned.fill(child: LockScreen()),
        if (!locked && obscured) Positioned.fill(child: ColoredBox(color: context.colors.folder)),
      ],
    );
  }
}

/// The cover shown while locked: unlock with biometrics or the passcode, or sign out.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Ask right away, like banking apps do.
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy || !mounted) {
      return;
    }
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _message = null;
    });
    final outcome = await ref.read(appLockProvider.notifier).unlock(l10n.appLockReason);
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _message = switch (outcome) {
        AuthOutcome.success || AuthOutcome.canceled => null,
        AuthOutcome.lockedOut => l10n.appLockLockedOut,
        _ => l10n.appLockFailed,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final method = ref.watch(biometricStatusProvider).value?.method ?? UnlockMethod.passcode;
    return Material(
      color: colors.folder,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wordmark(onFolder: true),
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.paperCard,
                  borderRadius: BorderRadius.circular(Radii.xl),
                ),
                child: const Mark(status: TestStatus.pending, size: 44),
              ),
              const SizedBox(height: Space.lg),
              Text(
                l10n.appLockTitle,
                style: context.text.headlineMedium?.copyWith(color: colors.folderInk),
              ),
              const SizedBox(height: Space.sm),
              Text(
                l10n.appLockText(unlockMethodName(l10n, method)),
                style: context.text.bodyLarge?.copyWith(color: colors.folderInkSoft),
              ),
              if (_message != null) ...[
                const SizedBox(height: Space.page),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _message!,
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.folderInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('lock.unlock'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.folderInk,
                    foregroundColor: colors.folder,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _busy ? null : _unlock,
                  icon: Icon(
                    method == UnlockMethod.faceId || method == UnlockMethod.face
                        ? Icons.face
                        : Icons.fingerprint,
                  ),
                  label: Text(l10n.appLockUnlock),
                ),
              ),
              const SizedBox(height: Space.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: colors.folderInk),
                  onPressed: _busy ? null : () => signOutToWelcome(ref),
                  child: Text(l10n.appLockSignOut),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
