import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/device/biometrics.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/device/device_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

/// `/dashboard/device/biometrics`: what the phone offers, and a live fingerprint / face check.
class BiometricsScreen extends ConsumerStatefulWidget {
  const BiometricsScreen({super.key});

  @override
  ConsumerState<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends ConsumerState<BiometricsScreen> {
  bool _biometricOnly = false;
  bool _busy = false;
  AuthOutcome? _outcome;

  Future<void> _scan() async {
    setState(() => _busy = true);
    final outcome = await ref
        .read(biometricServiceProvider)
        .authenticate(reason: context.l10n.biometricsPageReason, biometricOnly: _biometricOnly);
    if (!mounted) {
      return;
    }
    outcome == AuthOutcome.success ? Haptics.success() : Haptics.error();
    setState(() {
      _busy = false;
      _outcome = outcome;
    });
  }

  String _biometricName(AppLocalizations l10n, BiometricType type) => switch (type) {
    BiometricType.face => l10n.biometricsFace,
    BiometricType.fingerprint => l10n.biometricsFingerprint,
    BiometricType.iris => l10n.biometricsIris,
    _ => l10n.biometricsGeneric,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = ref.watch(biometricStatusProvider);
    final lockOn = ref.watch(settingsProvider.select((settings) => settings.appLock));
    final value = status.value;
    final method = value?.method ?? UnlockMethod.none;

    final result = switch (_outcome) {
      null => null,
      AuthOutcome.success => (TestStatus.passed, l10n.biometricsPageResultSuccess),
      AuthOutcome.failed => (TestStatus.failed, l10n.biometricsPageResultFailed),
      AuthOutcome.canceled => (TestStatus.pending, l10n.biometricsPageResultCanceled),
      AuthOutcome.lockedOut => (TestStatus.failed, l10n.biometricsPageResultLockedOut),
      AuthOutcome.notAvailable => (TestStatus.pending, l10n.biometricsPageResultNotAvailable),
      AuthOutcome.error => (TestStatus.failed, l10n.biometricsPageResultError),
    };

    return AppPage(
      title: l10n.biometricsPageTitle,
      description: Text(l10n.biometricsPageDescription),
      onRefresh: () async => ref.invalidate(biometricStatusProvider),
      children: [
        DemoCard(
          title: l10n.biometricsPageStatusTitle,
          child: value == null
              ? const LinearProgressIndicator()
              : Column(
                  children: [
                    ValueRow(
                      label: l10n.biometricsPageDeviceLock,
                      value: value.deviceSupported
                          ? l10n.biometricsPageAvailable
                          : l10n.biometricsPageUnavailable,
                    ),
                    ValueRow(
                      label: l10n.biometricsPageHardware,
                      value: value.canCheckBiometrics
                          ? l10n.biometricsPageAvailable
                          : l10n.biometricsPageUnavailable,
                    ),
                    ValueRow(
                      label: l10n.biometricsPageEnrolled,
                      value: value.enrolled.isEmpty
                          ? l10n.biometricsPageEnrolledNone
                          : value.enrolled.map((type) => _biometricName(l10n, type)).join(', '),
                    ),
                    ValueRow(
                      label: l10n.biometricsPageMethod,
                      value: method == UnlockMethod.none
                          ? l10n.biometricsPageUnavailable
                          : unlockMethodName(l10n, method),
                    ),
                  ],
                ),
        ),
        DemoCard(
          title: l10n.biometricsPageTryTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _biometricOnly,
                onChanged: (enabled) => setState(() => _biometricOnly = enabled),
                title: Text(l10n.biometricsPageBiometricOnly),
              ),
              const SizedBox(height: Space.sm),
              FilledButton.icon(
                key: const Key('biometrics.scan'),
                onPressed: _busy || method == UnlockMethod.none ? null : _scan,
                icon: Icon(
                  method == UnlockMethod.faceId || method == UnlockMethod.face
                      ? Icons.face
                      : Icons.fingerprint,
                ),
                label: Text(l10n.biometricsPageScanButton),
              ),
              if (result != null) ...[
                const SizedBox(height: Space.page),
                Semantics(
                  liveRegion: true,
                  child: Row(
                    children: [
                      Mark(status: result.$1, size: 28, animate: true),
                      const SizedBox(width: Space.md),
                      Expanded(child: Text(result.$2, style: context.text.titleMedium)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: Space.page),
              Text(l10n.biometricsPageFaceNote, style: context.text.bodySmall),
            ],
          ),
        ),
        DemoCard(
          title: l10n.biometricsPageLockTitle,
          action: Padding(
            padding: const EdgeInsets.only(right: Space.sm),
            child: Text(lockOn ? l10n.commonOn : l10n.commonOff, style: context.text.labelLarge),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.biometricsPageLockText(unlockMethodName(l10n, method)),
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: Space.sm),
              TextButton(
                onPressed: () => context.push(Routes.settings),
                child: Text(l10n.biometricsPageLockLink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
