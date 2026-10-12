import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/brand_buttons_data.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/button_group.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/demo_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum _Kind { both, icon, text }

const _sizes = [DemoSize.sm, DemoSize.normal, DemoSize.lg];

/// `/dashboard/buttons/brand-buttons`: the brand's mark and name on an outline button.
class BrandButtonsScreen extends StatelessWidget {
  const BrandButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    String sizeLabel(DemoSize size) => switch (size) {
      DemoSize.sm => l10n.brandButtonsPageSizeSm,
      DemoSize.lg => l10n.brandButtonsPageSizeLg,
      _ => l10n.brandButtonsPageSizeDefault,
    };
    Widget brandButton(_Kind kind, DemoSize size, Brand brand) => switch (kind) {
      _Kind.icon => DemoIconButton(
        icon: FaIcon(brand.icon),
        tooltip: brand.label,
        size: size,
        iconSize: size.iconSize - 2,
      ),
      _Kind.both => DemoButton(
        label: brand.label,
        variant: DemoVariant.outline,
        size: size,
        icon: FaIcon(brand.icon, size: size.iconSize - 2),
      ),
      _Kind.text => DemoButton(label: brand.label, variant: DemoVariant.outline, size: size),
    };

    return AppPage(
      title: l10n.brandButtonsPageTitle,
      description: Text(l10n.brandButtonsPageDescription),
      children: [
        for (final kind in _Kind.values)
          DemoCard(
            title: switch (kind) {
              _Kind.both => l10n.brandButtonsPageBothTitle,
              _Kind.icon => l10n.brandButtonsPageIconTitle,
              _Kind.text => l10n.brandButtonsPageTextTitle,
            },
            description: l10n.brandButtonsPageBrandColors,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormLabel(l10n.brandButtonsPageUsage),
                const SizedBox(height: Space.sm),
                _CodeSample(switch (kind) {
                  _Kind.both => brandButtonUsage.both,
                  _Kind.icon => brandButtonUsage.icon,
                  _Kind.text => brandButtonUsage.text,
                }),
                const SizedBox(height: Space.card),
                DemoRows(
                  rows: [
                    for (final size in _sizes)
                      DemoRow(
                        label: sizeLabel(size),
                        spacing: Space.sm,
                        children: [for (final brand in brands) brandButton(kind, size, brand)],
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A line of code on the white ply, scrolling sideways when it is longer than the card.
class _CodeSample extends StatelessWidget {
  const _CodeSample(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.ply,
        border: Border.all(color: colors.ink200),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
        child: SelectableText(code, style: context.type.code),
      ),
    );
  }
}
