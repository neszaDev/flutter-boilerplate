import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_navbar.dart';

// Language codes are data: they read the same in every locale.
const _languages = ['EN', 'ES', 'RU', 'FA'];

/// `/dashboard/base/navbars`: app bars with a brand, links, menus and a search form; on a
/// phone the ones with a breakpoint fold behind a menu button.
class NavbarsScreen extends StatelessWidget {
  const NavbarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.navbarsPageTitle,
      description: Text(l10n.navbarsPageDescription),
      children: [
        DemoCard(
          title: l10n.navbarsPageMainTitle,
          description: l10n.navbarsPageMainDescription,
          child: Navbar(
            tone: NavbarTone.folder,
            label: l10n.navbarsPageMainTitle,
            expand: NavbarExpand.md,
            brand: NavbarBrand(name: l10n.navbarsPageBrand, home: true),
            children: [
              NavbarGroup(
                children: [
                  NavbarLink(label: l10n.navbarsPageLink, path: Routes.testResults),
                  NavbarLink(
                    label: l10n.navbarsPageDisabled,
                    path: Routes.dashboard,
                    disabled: true,
                  ),
                ],
              ),
              NavbarGroup(
                children: [
                  NavbarSearch(
                    placeholder: l10n.navbarsPageSearch,
                    button: l10n.navbarsPageSearch,
                  ),
                  NavbarMenu(label: l10n.navbarsPageLang, choices: _languages),
                  NavbarMenu(
                    label: l10n.navbarsPageUser,
                    items: [
                      (label: l10n.navbarsPageProfile, path: Routes.account, signOut: false),
                      (label: l10n.navbarsPageSignOut, path: null, signOut: true),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.navbarsPageBrandTitle,
          child: Navbar(
            tone: NavbarTone.paper,
            label: l10n.navbarsPageBrandTitle,
            brand: NavbarBrand(name: l10n.navbarsPageBrand, home: true, mark: true),
          ),
        ),
        DemoCard(
          title: l10n.navbarsPageTextTitle,
          child: Navbar(
            tone: NavbarTone.paper,
            label: l10n.navbarsPageTextTitle,
            expand: NavbarExpand.sm,
            brand: NavbarBrand(name: l10n.navbarsPageBrand),
            children: [NavbarText(l10n.navbarsPageNavbarText)],
          ),
        ),
        DemoCard(
          title: l10n.navbarsPageDropdownTitle,
          child: Navbar(
            tone: NavbarTone.folder,
            label: l10n.navbarsPageDropdownTitle,
            expand: NavbarExpand.sm,
            children: [
              NavbarGroup(
                children: [
                  NavbarLink(label: l10n.navbarsPageHome, path: Routes.dashboard),
                  NavbarLink(label: l10n.navbarsPageLink, path: Routes.testResults),
                  NavbarMenu(label: l10n.navbarsPageLang, choices: _languages),
                  NavbarMenu(
                    label: l10n.navbarsPageUser,
                    items: [
                      (label: l10n.navbarsPageAccount, path: Routes.account, signOut: false),
                      (label: l10n.navbarsPageSettings, path: Routes.settings, signOut: false),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.navbarsPageFormTitle,
          child: Navbar(
            tone: NavbarTone.paper,
            label: l10n.navbarsPageFormTitle,
            children: [
              NavbarSearch(placeholder: l10n.navbarsPageSearch, button: l10n.navbarsPageSearch),
            ],
          ),
        ),
        DemoCard(
          title: l10n.navbarsPageInputTitle,
          child: Navbar(
            tone: NavbarTone.paper,
            label: l10n.navbarsPageInputTitle,
            children: [_UsernameInput(hint: l10n.navbarsPageUsername)],
          ),
        ),
      ],
    );
  }
}

/// A username field with an "@" in front (the web's input group). Full width on a phone,
/// 256 pt beside other items on wider screens.
class _UsernameInput extends StatelessWidget {
  const _UsernameInput({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      style: context.text.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: ExcludeSemantics(
          child: Center(
            widthFactor: 1,
            child: Text('@', style: TextStyle(color: context.colors.ink600)),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
      ),
    );
    return MediaQuery.sizeOf(context).width >= NavbarExpand.sm.minWidth
        ? SizedBox(width: 256, child: field)
        : field;
  }
}
