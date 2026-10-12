import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_nav_demo.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/base/navs`: navigation items as plain links, tabs or pills, filled, justified,
/// with a dropdown and stacked. Tapping an item makes it current.
class NavsScreen extends StatelessWidget {
  const NavsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final basic = [
      NavDemoItem(id: 'active', label: l10n.navsPageItemActive),
      NavDemoItem(id: 'link', label: l10n.navsPageItemLink),
      NavDemoItem(id: 'another', label: l10n.navsPageItemAnother),
      NavDemoItem(id: 'disabled', label: l10n.navsPageItemDisabled, disabled: true),
    ];
    final long = [
      NavDemoItem(id: 'active', label: l10n.navsPageItemActive),
      NavDemoItem(id: 'link', label: l10n.navsPageItemLink),
      NavDemoItem(id: 'long', label: l10n.navsPageItemLong),
      NavDemoItem(id: 'disabled', label: l10n.navsPageItemDisabled, disabled: true),
    ];
    final icons = [
      NavDemoItem(id: 'basket', label: l10n.navsPageIconBasket, icon: LucideIcons.shoppingBasket),
      NavDemoItem(id: 'settings', label: l10n.navsPageIconSettings, icon: LucideIcons.settings),
      NavDemoItem(id: 'bell', label: l10n.navsPageIconBell, icon: LucideIcons.bell),
      NavDemoItem(
        id: 'mail',
        label: l10n.navsPageIconMail,
        icon: LucideIcons.mail,
        disabled: true,
      ),
    ];

    return AppPage(
      title: l10n.navsPageTitle,
      description: Text(l10n.navsPageDescription),
      children: [
        DemoCard(
          title: l10n.navsPageBasicTitle,
          description: l10n.navsPageBasicDescription,
          child: NavDemo(label: l10n.navsPageBasicTitle, items: basic, initialActive: 'active'),
        ),
        DemoCard(
          title: l10n.navsPageIconsTitle,
          child: NavDemo(
            label: l10n.navsPageIconsTitle,
            items: icons,
            variant: NavDemoVariant.pills,
            initialActive: 'basket',
          ),
        ),
        DemoCard(
          title: l10n.navsPageTabsTitle,
          child: NavDemo(
            label: l10n.navsPageTabsTitle,
            items: basic,
            variant: NavDemoVariant.tabs,
            initialActive: 'active',
          ),
        ),
        DemoCard(
          title: l10n.navsPagePillsTitle,
          child: NavDemo(
            label: l10n.navsPagePillsTitle,
            items: basic,
            variant: NavDemoVariant.pills,
            initialActive: 'active',
          ),
        ),
        DemoCard(
          title: l10n.navsPageFillTitle,
          description: l10n.navsPageFillDescription,
          child: NavDemo(
            label: l10n.navsPageFillTitle,
            items: long,
            variant: NavDemoVariant.tabs,
            initialActive: 'active',
            fill: true,
          ),
        ),
        DemoCard(
          title: l10n.navsPageJustifiedTitle,
          description: l10n.navsPageJustifiedDescription,
          child: NavDemo(
            label: l10n.navsPageJustifiedTitle,
            items: long,
            variant: NavDemoVariant.tabs,
            initialActive: 'active',
            justified: true,
          ),
        ),
        DemoCard(
          title: l10n.navsPageDropdownTitle,
          child: NavDemo(
            label: l10n.navsPageDropdownTitle,
            items: basic.sublist(0, 2),
            variant: NavDemoVariant.pills,
            dropdown: (
              label: l10n.navsPageDropdownLabel,
              groups: [
                [l10n.navsPageDropdownOne, l10n.navsPageDropdownTwo],
                [l10n.navsPageDropdownThree],
              ],
            ),
          ),
        ),
        DemoCard(
          title: l10n.navsPageVerticalTitle,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 224),
              child: NavDemo(
                label: l10n.navsPageVerticalTitle,
                items: basic,
                variant: NavDemoVariant.pills,
                initialActive: 'active',
                vertical: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
