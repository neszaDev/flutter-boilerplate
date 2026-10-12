import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/button_group.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/demo_button.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/toggle_demos.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The state each example row shows.
enum _State { normal, active, disabled }

/// The text of [message] without its `<code>` markup: `DemoCard` descriptions are plain text.
String _plain(String message) =>
    TextSpan(children: RichMessage.spans(message, const {})).toPlainText();

/// `/dashboard/buttons/standard-buttons`: every button variant, size and state.
class StandardButtonsScreen extends StatelessWidget {
  const StandardButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    String stateLabel(_State state) => switch (state) {
      _State.normal => l10n.standardButtonsPageStateNormal,
      _State.active => l10n.standardButtonsPageStateActive,
      _State.disabled => l10n.standardButtonsPageStateDisabled,
    };
    String sizeLabel(DemoSize size) => switch (size) {
      DemoSize.xs => l10n.standardButtonsPageSizeXs,
      DemoSize.sm => l10n.standardButtonsPageSizeSm,
      DemoSize.normal => l10n.standardButtonsPageSizeDefault,
      DemoSize.lg => l10n.standardButtonsPageSizeLg,
    };

    // A row per state, each with one example per item.
    Widget stateRows<T>(List<T> items, Widget Function(T item, _State state) build) => DemoRows(
      rows: [
        for (final state in _State.values)
          DemoRow(
            label: stateLabel(state),
            children: [for (final item in items) build(item, state)],
          ),
      ],
    );

    DemoButton stateButton(
      DemoVariant variant,
      _State state, {
      required String label,
      DemoSize size = DemoSize.normal,
      DemoShape shape = DemoShape.rounded,
    }) => DemoButton(
      label: label,
      variant: variant,
      size: size,
      shape: shape,
      active: state == _State.active,
      enabled: state != _State.disabled,
    );

    // The same five buttons, in every size and with an icon.
    List<Widget> mixedButtons(DemoSize size, {Widget? icon}) => [
      DemoButton(label: l10n.standardButtonsPageStandardButton, size: size, icon: icon),
      DemoButton(
        label: l10n.standardButtonsPageOutlineButton,
        variant: DemoVariant.outline,
        size: size,
        icon: icon,
      ),
      DemoButton(
        label: l10n.standardButtonsPageGhostButton,
        variant: DemoVariant.ghost,
        size: size,
        icon: icon,
      ),
      DemoButton(
        label: l10n.standardButtonsPageSquareButton,
        variant: DemoVariant.secondary,
        shape: DemoShape.square,
        size: size,
        icon: icon,
      ),
      DemoButton(
        label: l10n.standardButtonsPagePillButton,
        variant: DemoVariant.destructive,
        shape: DemoShape.pill,
        size: size,
        icon: icon,
      ),
    ];

    return AppPage(
      title: l10n.standardButtonsPageTitle,
      description: Text(l10n.standardButtonsPageDescription),
      children: [
        DemoCard(
          title: l10n.standardButtonsPageStandardTitle,
          description: l10n.standardButtonsPageStandardDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              stateRows(
                cardVariants,
                (variant, state) => stateButton(variant, state, label: variantLabel(l10n, variant)),
              ),
              const Divider(height: Space.xl + 1),
              DemoRow(
                label: l10n.standardButtonsPageStateFolder,
                background: context.colors.folder,
                children: [
                  DemoButton(label: l10n.buttonVariantsInverse, variant: DemoVariant.inverse),
                  DemoButton(
                    label: l10n.buttonVariantsInverseGhost,
                    variant: DemoVariant.inverseGhost,
                  ),
                  DemoButton(
                    label: l10n.buttonVariantsInverse,
                    variant: DemoVariant.inverse,
                    enabled: false,
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final (variant, title, description) in [
          (
            DemoVariant.outline,
            l10n.standardButtonsPageOutlineTitle,
            l10n.standardButtonsPageOutlineDescription,
          ),
          (
            DemoVariant.ghost,
            l10n.standardButtonsPageGhostTitle,
            l10n.standardButtonsPageGhostDescription,
          ),
        ])
          DemoCard(
            title: title,
            description: _plain(description),
            child: stateRows(
              DemoSize.values,
              (size, state) => stateButton(variant, state, label: sizeLabel(size), size: size),
            ),
          ),
        for (final (shape, title, description) in [
          (
            DemoShape.square,
            l10n.standardButtonsPageSquareTitle,
            l10n.standardButtonsPageSquareDescription,
          ),
          (
            DemoShape.pill,
            l10n.standardButtonsPagePillTitle,
            l10n.standardButtonsPagePillDescription,
          ),
        ])
          DemoCard(
            title: title,
            description: _plain(description),
            child: stateRows(
              boxedVariants,
              (variant, state) =>
                  stateButton(variant, state, label: variantLabel(l10n, variant), shape: shape),
            ),
          ),
        DemoCard(
          title: l10n.standardButtonsPageSizesTitle,
          description: l10n.standardButtonsPageSizesDescription,
          child: DemoRows(
            rows: [
              for (final size in DemoSize.values)
                DemoRow(label: sizeLabel(size), children: mixedButtons(size)),
            ],
          ),
        ),
        DemoCard(
          title: l10n.standardButtonsPageIconsTitle,
          description: l10n.standardButtonsPageIconsDescription,
          child: DemoRows(
            rows: [
              DemoRow(
                label: l10n.standardButtonsPageIconsLeading,
                children: mixedButtons(DemoSize.normal, icon: const Icon(LucideIcons.lightbulb)),
              ),
              DemoRow(
                label: l10n.standardButtonsPageIconsOnly,
                children: [
                  for (final size in DemoSize.values)
                    DemoIconButton(
                      icon: const Icon(LucideIcons.settings),
                      tooltip: l10n.standardButtonsPageSettings,
                      size: size,
                    ),
                ],
              ),
              DemoRow(
                label: l10n.standardButtonsPageIconsLoading,
                children: const [LoadingButtonDemo()],
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.standardButtonsPageToggleTitle,
          description: l10n.standardButtonsPageToggleDescription,
          child: const TogglePressedDemo(),
        ),
        for (final (title, variants) in [
          (
            l10n.standardButtonsPageBlockTitle,
            [DemoVariant.secondary, DemoVariant.primary, DemoVariant.destructive, DemoVariant.link],
          ),
          (l10n.standardButtonsPageBlockOutlineTitle, [DemoVariant.outline, DemoVariant.ghost]),
        ])
          DemoCard(
            title: title,
            description: _plain(l10n.standardButtonsPageBlockDescription),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, variant) in variants.indexed) ...[
                  if (index > 0) const SizedBox(height: Space.sm),
                  DemoButton(
                    label: l10n.standardButtonsPageBlockButton,
                    variant: variant,
                    size: DemoSize.lg,
                    expand: true,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
