import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/device/device_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `/dashboard/device/haptics`: every kind of haptic feedback the app uses.
class HapticsScreen extends ConsumerWidget {
  const HapticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final enabled = ref.watch(settingsProvider.select((settings) => settings.haptics));

    Widget buttons(List<(String, VoidCallback)> actions) => Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        for (final (label, play) in actions)
          OutlinedButton(onPressed: enabled ? play : null, child: Text(label)),
      ],
    );

    return AppPage(
      title: l10n.hapticsPageTitle,
      description: Text(l10n.hapticsPageDescription),
      children: [
        if (!enabled) DeviceNotice(message: l10n.hapticsPageDisabled, error: true),
        DemoCard(
          title: l10n.hapticsPageImpactsTitle,
          child: buttons([
            (l10n.hapticsPageLight, Haptics.light),
            (l10n.hapticsPageMedium, Haptics.medium),
            (l10n.hapticsPageHeavy, Haptics.heavy),
          ]),
        ),
        DemoCard(
          title: l10n.hapticsPagePatternsTitle,
          child: buttons([
            (l10n.hapticsPageSelection, Haptics.selection),
            (l10n.hapticsPageSuccess, Haptics.success),
            (l10n.hapticsPageError, Haptics.error),
            (l10n.hapticsPageVibrate, Haptics.vibrate),
          ]),
        ),
        Text(l10n.hapticsPageHint, style: context.text.bodySmall),
      ],
    );
  }
}
