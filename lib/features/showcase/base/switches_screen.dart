import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_data.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_switch_demos.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_switch.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';

/// `/dashboard/base/switches`: radio switches, the default row, every style of the tone row,
/// and the three sizes.
class SwitchesScreen extends StatelessWidget {
  const SwitchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.switchesPageTitle,
      description: Text(l10n.switchesPageDescription),
      children: [
        const RadioSwitches(),
        const DefaultSwitches(),
        for (final style in SwitchRowStyle.values)
          DemoCard(
            title: _rowTitle(l10n, style),
            child: SwitchRow(style: style),
          ),
        DemoCard(
          title: l10n.switchesPageSizesTitle,
          padding: const EdgeInsets.fromLTRB(Space.sm, Space.sm, Space.sm, Space.md),
          child: const _SizesTable(),
        ),
      ],
    );
  }

  static String _rowTitle(AppLocalizations l10n, SwitchRowStyle style) => switch (style) {
    SwitchRowStyle.pills => l10n.switchesPageRowPills,
    SwitchRowStyle.threeD => l10n.switchesPageRow3d,
    SwitchRowStyle.threeDDisabled => l10n.switchesPageRow3dDisabled,
    SwitchRowStyle.threeDLabel => l10n.switchesPageRow3dLabel,
    SwitchRowStyle.outline => l10n.switchesPageRowOutline,
    SwitchRowStyle.outlinePill => l10n.switchesPageRowOutlinePill,
    SwitchRowStyle.opposite => l10n.switchesPageRowOpposite,
    SwitchRowStyle.oppositePill => l10n.switchesPageRowOppositePill,
    SwitchRowStyle.label => l10n.switchesPageRowLabel,
    SwitchRowStyle.labelPill => l10n.switchesPageRowLabelPill,
    SwitchRowStyle.labelOutline => l10n.switchesPageRowLabelOutline,
    SwitchRowStyle.labelOutlinePill => l10n.switchesPageRowLabelOutlinePill,
    SwitchRowStyle.labelOpposite => l10n.switchesPageRowLabelOpposite,
    SwitchRowStyle.labelOppositePill => l10n.switchesPageRowLabelOppositePill,
  };
}

/// Size, example and the parameter that picks it, one row per size.
class _SizesTable extends StatelessWidget {
  const _SizesTable();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    const cell = EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.sm);
    final code = context.type.code.copyWith(
      fontSize: 13,
      color: colors.ink950,
      backgroundColor: colors.ink100,
    );

    Widget head(String text) => Padding(
      padding: cell,
      child: Semantics(header: true, child: FormLabel(text)),
    );

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.ink200)),
          ),
          children: [
            head(l10n.switchesPageSizesSize),
            head(l10n.switchesPageSizesExample),
            head(l10n.switchesPageSizesProp),
          ],
        ),
        for (final (index, size) in switchSizes.indexed)
          TableRow(
            decoration: BoxDecoration(
              color: index.isOdd ? colors.ink100.withValues(alpha: 0.4) : null,
              border: index < switchSizes.length - 1
                  ? Border(bottom: BorderSide(color: colors.ink200))
                  : null,
            ),
            children: [
              Padding(
                padding: cell,
                child: Text(
                  _sizeLabel(l10n, size),
                  style: context.text.titleSmall?.copyWith(color: colors.ink950),
                ),
              ),
              Padding(
                padding: cell,
                child: ToneSwitch(
                  tone: Tone.folder,
                  variant: ToneSwitchVariant.threeD,
                  size: size,
                  initialValue: true,
                  label: _sizeLabel(l10n, size),
                ),
              ),
              Padding(
                padding: cell,
                child: RichMessage(
                  switch (size) {
                    ToneSwitchSize.lg => l10n.switchesPageSizePropLg,
                    ToneSwitchSize.md => l10n.switchesPageSizePropDefault,
                    ToneSwitchSize.sm => l10n.switchesPageSizePropSm,
                  },
                  style: context.text.bodyMedium?.copyWith(fontSize: 14, color: colors.ink700),
                  tags: {'code': (text) => TextSpan(text: ' $text ', style: code)},
                ),
              ),
            ],
          ),
      ],
    );
  }

  static String _sizeLabel(AppLocalizations l10n, ToneSwitchSize size) => switch (size) {
    ToneSwitchSize.lg => l10n.switchesPageSizeLg,
    ToneSwitchSize.md => l10n.switchesPageSizeDefault,
    ToneSwitchSize.sm => l10n.switchesPageSizeSm,
  };
}
