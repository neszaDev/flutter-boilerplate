import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/analytics_screen.dart';
import 'package:flutter_boilerplate/features/showcase/apps/compose_screen.dart';
import 'package:flutter_boilerplate/features/showcase/apps/inbox_screen.dart';
import 'package:flutter_boilerplate/features/showcase/apps/invoice_screen.dart';
import 'package:flutter_boilerplate/features/showcase/apps/message_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/breadcrumbs_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/cards_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/carousels_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/collapses_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/jumbotrons_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/list_groups_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/navbars_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/navs_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/paginations_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/popovers_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/progress_bars_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/switches_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/tabs_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/tooltips_screen.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/brand_buttons_screen.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/button_groups_screen.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/dropdowns_screen.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/standard_buttons_screen.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_content_screen.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_filters_screen.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_qr_code_screen.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_screen.dart';
import 'package:flutter_boilerplate/features/showcase/charts/charts_screen.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_editors_screen.dart';
import 'package:flutter_boilerplate/features/showcase/editors/text_editors_screen.dart';
import 'package:flutter_boilerplate/features/showcase/forms/advanced_forms_screen.dart';
import 'package:flutter_boilerplate/features/showcase/forms/basic_forms_screen.dart';
import 'package:flutter_boilerplate/features/showcase/forms/validation_forms_screen.dart';
import 'package:flutter_boilerplate/features/showcase/icons/brands_screen.dart';
import 'package:flutter_boilerplate/features/showcase/icons/flags_screen.dart';
import 'package:flutter_boilerplate/features/showcase/icons/icon_library_screen.dart';
import 'package:flutter_boilerplate/features/showcase/maps/maps_screen.dart';
import 'package:flutter_boilerplate/features/showcase/notifications/alerts_screen.dart';
import 'package:flutter_boilerplate/features/showcase/notifications/badges_screen.dart';
import 'package:flutter_boilerplate/features/showcase/notifications/modals_screen.dart';
import 'package:flutter_boilerplate/features/showcase/notifications/toaster_screen.dart';
import 'package:flutter_boilerplate/features/showcase/pages/error_404_screen.dart';
import 'package:flutter_boilerplate/features/showcase/pages/error_500_screen.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/calendar_screen.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/draggable_screen.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/spinners_screen.dart';
import 'package:flutter_boilerplate/features/showcase/tables/advanced_tables_screen.dart';
import 'package:flutter_boilerplate/features/showcase/tables/basic_tables_screen.dart';
import 'package:flutter_boilerplate/features/showcase/theme/colors_screen.dart';
import 'package:flutter_boilerplate/features/showcase/theme/typography_screen.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_screen.dart';
import 'package:go_router/go_router.dart';

/// The showcase: one screen per demo page of the web app, all behind
/// [Permission.viewShowcase]. Delete `lib/features/showcase/` and this list's use in
/// `app_router.dart` (and its menu sections) to drop the demos from a product.
final showcaseRoutes = <RouteBase>[
  _screen(Routes.campus, (_) => const CampusScreen()),
  _screen(Routes.campusFilters, (_) => const CampusFiltersScreen()),
  _screen(Routes.campusContent, (_) => const CampusContentScreen()),
  _screen(Routes.campusQrCode, (_) => const CampusQrCodeScreen()),
  _screen(Routes.themeColors, (_) => const ColorsScreen()),
  _screen(Routes.themeTypography, (_) => const TypographyScreen()),
  _screen(Routes.baseBreadcrumbs, (_) => const BreadcrumbsScreen()),
  _screen(Routes.baseCards, (_) => const CardsScreen()),
  _screen(Routes.baseCarousels, (_) => const CarouselsScreen()),
  _screen(Routes.baseCollapses, (_) => const CollapsesScreen()),
  _screen(Routes.baseJumbotrons, (_) => const JumbotronsScreen()),
  _screen(Routes.baseListGroups, (_) => const ListGroupsScreen()),
  _screen(Routes.baseNavs, (_) => const NavsScreen()),
  _screen(Routes.baseNavbars, (_) => const NavbarsScreen()),
  _screen(Routes.basePaginations, (_) => const PaginationsScreen()),
  _screen(Routes.basePopovers, (_) => const PopoversScreen()),
  _screen(Routes.baseProgressBars, (_) => const ProgressBarsScreen()),
  _screen(Routes.baseSwitches, (_) => const SwitchesScreen()),
  _screen(Routes.baseTabs, (_) => const TabsScreen()),
  _screen(Routes.baseTooltips, (_) => const TooltipsScreen()),
  _screen(Routes.buttonsStandard, (_) => const StandardButtonsScreen()),
  _screen(Routes.buttonsDropdowns, (_) => const DropdownsScreen()),
  _screen(Routes.buttonsGroups, (_) => const ButtonGroupsScreen()),
  _screen(Routes.buttonsBrand, (_) => const BrandButtonsScreen()),
  _screen(Routes.charts, (_) => const ChartsScreen()),
  _screen(Routes.editorsCode, (_) => const CodeEditorsScreen()),
  _screen(Routes.editorsText, (_) => const TextEditorsScreen()),
  _screen(Routes.formsBasic, (_) => const BasicFormsScreen()),
  _screen(Routes.formsAdvanced, (_) => const AdvancedFormsScreen()),
  _screen(Routes.formsValidation, (_) => const ValidationFormsScreen()),
  _screen(Routes.maps, (_) => const MapsScreen()),
  _screen(Routes.iconsLibrary, (_) => const IconLibraryScreen()),
  _screen(Routes.iconsBrands, (_) => const BrandsScreen()),
  _screen(Routes.iconsFlags, (_) => const FlagsScreen()),
  _screen(Routes.notificationsAlerts, (_) => const AlertsScreen()),
  _screen(Routes.notificationsBadges, (_) => const BadgesScreen()),
  _screen(Routes.notificationsModals, (_) => const ModalsScreen()),
  _screen(Routes.notificationsToaster, (_) => const ToasterScreen()),
  _screen(Routes.pluginsDraggable, (_) => const DraggableScreen()),
  _screen(Routes.pluginsCalendar, (_) => const CalendarScreen()),
  _screen(Routes.pluginsSpinners, (_) => const SpinnersScreen()),
  _screen(Routes.tablesBasic, (_) => const BasicTablesScreen()),
  _screen(Routes.tablesAdvanced, (_) => const AdvancedTablesScreen()),
  _screen(Routes.widgets, (_) => const WidgetsScreen()),
  _screen(Routes.analytics, (_) => const AnalyticsScreen()),
  _screen(Routes.pages404, (_) => const Error404Screen()),
  _screen(Routes.pages500, (_) => const Error500Screen()),
  _screen(Routes.appsInvoice, (_) => const InvoiceScreen()),
  _screen(Routes.appsInbox, (_) => const InboxScreen()),
  _screen(Routes.appsMessage, (_) => const MessageScreen()),
  _screen(Routes.appsCompose, (_) => const ComposeScreen()),
];

GoRoute _screen(String path, Widget Function(GoRouterState state) build) => GoRoute(
  path: path,
  builder: (context, state) =>
      RequirePermission(permission: Permission.viewShowcase, child: build(state)),
);
