import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/button_group.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/demo_button.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/menu_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/buttons/dropdowns`: menus opened from a button.
class DropdownsScreen extends StatelessWidget {
  const DropdownsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    List<Widget> actions() => [
      menuItem(l10n.dropdownsPageAction),
      menuItem(l10n.dropdownsPageAnotherAction),
      menuItem(l10n.dropdownsPageSomethingElse),
    ];
    List<Widget> numbered() => [
      menuItem(l10n.dropdownsPageFirstAction),
      menuItem(l10n.dropdownsPageSecondAction),
      menuItem(l10n.dropdownsPageThirdAction),
    ];
    Widget splitButton(String label, DemoSize size) => ButtonGroup(
      label: label,
      children: [
        DemoButton(label: label, variant: DemoVariant.outline, size: size),
        MenuCaretButton(size: size, menuChildren: actions()),
      ],
    );
    Widget column(List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const SizedBox(height: Space.page),
          child,
        ],
      ],
    );
    Widget row(List<Widget> children) => Wrap(
      spacing: Space.md,
      runSpacing: Space.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );

    return AppPage(
      title: l10n.dropdownsPageTitle,
      description: Text(l10n.dropdownsPageDescription),
      children: [
        DemoCard(
          title: l10n.dropdownsPageBasicTitle,
          child: column([
            MenuButton(
              label: l10n.dropdownsPageDropdownButton,
              menuChildren: [
                ...numbered(),
                const MenuSeparator(),
                menuItem(l10n.dropdownsPageSomethingElse),
                menuItem(l10n.dropdownsPageDisabledAction, enabled: false),
              ],
            ),
            MenuButton(
              label: l10n.dropdownsPageWithDivider,
              menuChildren: [
                menuItem(l10n.dropdownsPageFirstItem),
                menuItem(l10n.dropdownsPageSecondItem),
                const MenuSeparator(),
                menuItem(l10n.dropdownsPageSeparatedItem),
              ],
            ),
            MenuButton(
              label: l10n.dropdownsPageWithHeader,
              menuChildren: [
                MenuLabel(l10n.dropdownsPageHeader),
                menuItem(l10n.dropdownsPageFirstItem),
                menuItem(l10n.dropdownsPageSecondItem),
              ],
            ),
          ]),
        ),
        DemoCard(
          title: l10n.dropdownsPagePositioningTitle,
          description: l10n.dropdownsPagePositioningDescription,
          child: column([
            row([
              MenuButton(
                label: l10n.dropdownsPageLeftAlign,
                variant: DemoVariant.primary,
                menuChildren: actions(),
              ),
              MenuButton(
                label: l10n.dropdownsPageRightAlign,
                variant: DemoVariant.primary,
                placement: const MenuPlacement(align: MenuAlign.end),
                menuChildren: actions(),
              ),
            ]),
            MenuButton(
              label: l10n.dropdownsPageDropUp,
              variant: DemoVariant.secondary,
              placement: const MenuPlacement(above: true),
              menuChildren: actions(),
            ),
            MenuButton(
              label: l10n.dropdownsPageOffset,
              placement: const MenuPlacement(sideOffset: 5, alignOffset: 10),
              menuChildren: actions(),
            ),
            splitButton(l10n.dropdownsPageSplit, DemoSize.normal),
          ]),
        ),
        DemoCard(
          title: l10n.dropdownsPageCaretTitle,
          description: l10n.dropdownsPageCaretDescription,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: MenuIconButton(
              icon: const Icon(LucideIcons.search),
              tooltip: l10n.dropdownsPageSearch,
              size: DemoSize.lg,
              menuChildren: actions(),
            ),
          ),
        ),
        DemoCard(
          title: l10n.dropdownsPageSizingTitle,
          child: column([
            row([
              MenuButton(
                label: l10n.dropdownsPageLarge,
                size: DemoSize.lg,
                menuChildren: actions(),
              ),
              splitButton(l10n.dropdownsPageLargeSplit, DemoSize.lg),
            ]),
            row([
              MenuButton(
                label: l10n.dropdownsPageSmall,
                size: DemoSize.sm,
                menuChildren: actions(),
              ),
              splitButton(l10n.dropdownsPageSmallSplit, DemoSize.sm),
            ]),
          ]),
        ),
        DemoCard(
          title: l10n.dropdownsPageAriaTitle,
          description: l10n.dropdownsPageAriaDescription,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: MenuButton(
              label: l10n.dropdownsPageAriaButton,
              variant: DemoVariant.primary,
              menuChildren: [
                MenuGroup(
                  label: l10n.dropdownsPageGroups,
                  children: [
                    menuItem(l10n.dropdownsPageAddGroup),
                    DestructiveMenuItem(l10n.dropdownsPageDeleteGroup),
                  ],
                ),
                MenuGroup(
                  label: l10n.dropdownsPageUsers,
                  children: [
                    menuItem(l10n.dropdownsPageAddUser),
                    DestructiveMenuItem(l10n.dropdownsPageDeleteUser),
                  ],
                ),
                const MenuSeparator(),
                menuItem(
                  l10n.dropdownsPageNotAssociated,
                  child: RichMessage(
                    l10n.dropdownsPageNotAssociated,
                    tags: {
                      'strong': (text) => TextSpan(
                        text: text,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        DemoCard(
          title: l10n.dropdownsPageVariantsTitle,
          description: l10n.dropdownsPageVariantsDescription,
          child: Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final variant in cardVariants)
                MenuButton(
                  label: variantLabel(l10n, variant),
                  variant: variant,
                  size: DemoSize.sm,
                  menuChildren: numbered(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
