import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A link in the menu. Hidden unless the account has [permission].
class NavLink {
  const NavLink(this.path, this.label, {this.icon, this.permission});

  final String path;
  final String label;
  final IconData? icon;
  final Permission? permission;
}

/// A collapsible group of links.
class NavGroup {
  const NavGroup(this.label, this.icon, this.items, {this.permission});

  final String label;
  final IconData icon;
  final List<NavLink> items;
  final Permission? permission;
}

/// A titled block of the menu.
class NavSection {
  const NavSection({required this.id, required this.entries, this.title, this.permission});

  final String id;
  final String? title;
  final List<Object> entries;
  final Permission? permission;
}

/// The menu, translated and filtered for [access]: the product's own screens, the phone
/// features, then the sections of the web app's showcase. The same tree as the web sidebar
/// (`navItems.ts`); the bottom tabs duplicate its first entries.
List<NavSection> navSections(AppLocalizations l10n, Access access) {
  bool allowed(Permission? permission) => permission == null || access.can(permission);
  const showcase = Permission.viewShowcase;

  final sections = [
    NavSection(
      id: 'main',
      entries: [
        NavLink(Routes.dashboard, l10n.appNavDashboard, icon: LucideIcons.layoutGrid),
        NavLink(Routes.testResults, l10n.appNavTestResults, icon: LucideIcons.clipboardList),
        NavLink(Routes.files, l10n.appNavFiles, icon: LucideIcons.folderOpen),
        NavLink(Routes.account, l10n.appNavAccount, icon: LucideIcons.userRound),
        NavLink(
          Routes.users,
          l10n.appNavUsers,
          icon: LucideIcons.users,
          permission: Permission.viewUsers,
        ),
        NavLink(Routes.settings, l10n.menuPageSettings, icon: LucideIcons.settings),
      ],
    ),
    NavSection(
      id: 'phone',
      title: l10n.menuPageSectionPhone,
      permission: Permission.useDeviceFeatures,
      entries: [
        NavLink(Routes.device, l10n.menuPagePhoneFeatures, icon: LucideIcons.smartphone),
      ],
    ),
    NavSection(
      id: 'campus',
      title: l10n.appNavSectionCampus,
      permission: showcase,
      entries: [
        NavLink(Routes.campus, l10n.appNavCampus, icon: LucideIcons.school),
        NavLink(Routes.campusFilters, l10n.appNavCampusFilters, icon: LucideIcons.filter),
        NavLink(Routes.campusContent, l10n.appNavCampusContent, icon: LucideIcons.languages),
        NavLink(Routes.campusQrCode, l10n.appNavCampusQrCode, icon: LucideIcons.qrCode),
      ],
    ),
    NavSection(
      id: 'theme',
      title: l10n.appNavSectionTheme,
      permission: showcase,
      entries: [
        NavLink(Routes.themeColors, l10n.appNavColors, icon: LucideIcons.palette),
        NavLink(Routes.themeTypography, l10n.appNavTypography, icon: LucideIcons.type),
      ],
    ),
    NavSection(
      id: 'components',
      title: l10n.appNavSectionComponents,
      permission: showcase,
      entries: [
        NavGroup(l10n.appNavBase, LucideIcons.puzzle, [
          NavLink(Routes.baseBreadcrumbs, l10n.appNavBreadcrumbs),
          NavLink(Routes.baseCards, l10n.appNavCards),
          NavLink(Routes.baseCarousels, l10n.appNavCarousels),
          NavLink(Routes.baseCollapses, l10n.appNavCollapses),
          NavLink(Routes.baseJumbotrons, l10n.appNavJumbotrons),
          NavLink(Routes.baseListGroups, l10n.appNavListGroups),
          NavLink(Routes.baseNavs, l10n.appNavNavs),
          NavLink(Routes.baseNavbars, l10n.appNavNavbars),
          NavLink(Routes.basePaginations, l10n.appNavPaginations),
          NavLink(Routes.basePopovers, l10n.appNavPopovers),
          NavLink(Routes.baseProgressBars, l10n.appNavProgressBars),
          NavLink(Routes.baseSwitches, l10n.appNavSwitches),
          NavLink(Routes.baseTabs, l10n.appNavTabs),
          NavLink(Routes.baseTooltips, l10n.appNavTooltips),
        ]),
        NavGroup(l10n.appNavButtons, LucideIcons.mousePointerClick, [
          NavLink(Routes.buttonsStandard, l10n.appNavStandardButtons),
          NavLink(Routes.buttonsDropdowns, l10n.appNavButtonDropdowns),
          NavLink(Routes.buttonsGroups, l10n.appNavButtonGroups),
          NavLink(Routes.buttonsBrand, l10n.appNavBrandButtons),
        ]),
        NavLink(Routes.charts, l10n.appNavCharts, icon: LucideIcons.chartPie),
        NavGroup(l10n.appNavEditors, LucideIcons.code, [
          NavLink(Routes.editorsCode, l10n.appNavCodeEditors),
          NavLink(Routes.editorsText, l10n.appNavTextEditors),
        ]),
        NavGroup(l10n.appNavForms, LucideIcons.notebookPen, [
          NavLink(Routes.formsBasic, l10n.appNavBasicForms),
          NavLink(Routes.formsAdvanced, l10n.appNavAdvancedForms),
          NavLink(Routes.formsValidation, l10n.appNavValidationForms),
        ]),
        NavLink(Routes.maps, l10n.appNavMaps, icon: LucideIcons.map),
        NavGroup(l10n.appNavIcons, LucideIcons.star, [
          NavLink(Routes.iconsLibrary, l10n.appNavIconLibrary),
          NavLink(Routes.iconsBrands, l10n.appNavBrands),
          NavLink(Routes.iconsFlags, l10n.appNavFlags),
        ]),
        NavGroup(l10n.appNavNotifications, LucideIcons.bell, [
          NavLink(Routes.notificationsAlerts, l10n.appNavAlerts),
          NavLink(Routes.notificationsBadges, l10n.appNavBadges),
          NavLink(Routes.notificationsModals, l10n.appNavModals),
          NavLink(Routes.notificationsToaster, l10n.appNavToaster),
        ]),
        NavGroup(l10n.appNavPlugins, LucideIcons.plug, [
          NavLink(Routes.pluginsDraggable, l10n.appNavDraggable),
          NavLink(Routes.pluginsCalendar, l10n.appNavCalendar),
          NavLink(Routes.pluginsSpinners, l10n.appNavSpinners),
        ]),
        NavGroup(l10n.appNavTables, LucideIcons.table, [
          NavLink(Routes.tablesBasic, l10n.appNavBasicTables),
          NavLink(Routes.tablesAdvanced, l10n.appNavAdvancedTables),
        ]),
        NavLink(Routes.widgets, l10n.appNavWidgets, icon: LucideIcons.calculator),
      ],
    ),
    NavSection(
      id: 'extras',
      title: l10n.appNavSectionExtras,
      permission: showcase,
      entries: [
        NavLink(Routes.analytics, l10n.appNavAnalytics, icon: LucideIcons.chartLine),
        NavGroup(l10n.appNavPages, LucideIcons.fileWarning, [
          NavLink(Routes.pages404, l10n.appNavError404),
          NavLink(Routes.pages500, l10n.appNavError500),
        ]),
        NavGroup(l10n.appNavApps, LucideIcons.layers, [
          NavLink(Routes.appsInvoice, l10n.appNavInvoice),
          NavLink(Routes.appsInbox, l10n.appNavInbox),
          NavLink(Routes.appsMessage, l10n.appNavMessage),
          NavLink(Routes.appsCompose, l10n.appNavCompose),
        ]),
      ],
    ),
  ];

  // Filter by permission: sections, groups and links the account can't use disappear.
  return [
    for (final section in sections)
      if (allowed(section.permission))
        NavSection(
          id: section.id,
          title: section.title,
          entries: [
            for (final entry in section.entries)
              if (entry is NavLink && allowed(entry.permission))
                entry
              else if (entry is NavGroup && allowed(entry.permission))
                NavGroup(entry.label, entry.icon, [
                  for (final item in entry.items)
                    if (allowed(item.permission)) item,
                ]),
          ],
        ),
  ];
}
