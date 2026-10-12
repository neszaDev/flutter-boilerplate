/// Every path in the app. The signed-in area is `/dashboard/**` and uses the web app's paths,
/// so a link shared from the web opens the same screen here (once app links are set up, see
/// docs/architecture.md).
abstract final class Routes {
  // Public
  static const splash = '/splash';
  static const welcome = '/';
  static const about = '/about';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';

  // Tabs
  static const dashboard = '/dashboard';
  static const testResults = '/dashboard/test-results';
  static const files = '/dashboard/files';
  static const device = '/dashboard/device';
  static const menu = '/dashboard/menu';

  // Account and admin
  static const account = '/dashboard/account';
  static const settings = '/dashboard/settings';
  static const users = '/dashboard/users';
  static String user(int id) => '/dashboard/users/$id';

  // Phone features
  static const deviceBiometrics = '/dashboard/device/biometrics';
  static const deviceShake = '/dashboard/device/shake';
  static const deviceMotion = '/dashboard/device/motion';
  static const deviceCamera = '/dashboard/device/camera';
  static const deviceScanner = '/dashboard/device/scanner';
  static const deviceLocation = '/dashboard/device/location';
  static const deviceHaptics = '/dashboard/device/haptics';
  static const deviceNotifications = '/dashboard/device/notifications';
  static const deviceInfo = '/dashboard/device/info';
  static const deviceShare = '/dashboard/device/share';

  // Showcase: the web app's demo sections.
  static const campus = '/dashboard/campus';
  static const campusFilters = '/dashboard/campus/filters';
  static const campusContent = '/dashboard/campus/content';
  static const campusQrCode = '/dashboard/campus/qr-code';
  static const themeColors = '/dashboard/theme/colors';
  static const themeTypography = '/dashboard/theme/typography';
  static const baseBreadcrumbs = '/dashboard/base/breadcrumbs';
  static const baseCards = '/dashboard/base/cards';
  static const baseCarousels = '/dashboard/base/carousels';
  static const baseCollapses = '/dashboard/base/collapses';
  static const baseJumbotrons = '/dashboard/base/jumbotrons';
  static const baseListGroups = '/dashboard/base/list-groups';
  static const baseNavs = '/dashboard/base/navs';
  static const baseNavbars = '/dashboard/base/navbars';
  static const basePaginations = '/dashboard/base/paginations';
  static const basePopovers = '/dashboard/base/popovers';
  static const baseProgressBars = '/dashboard/base/progress-bars';
  static const baseSwitches = '/dashboard/base/switches';
  static const baseTabs = '/dashboard/base/tabs';
  static const baseTooltips = '/dashboard/base/tooltips';
  static const buttonsStandard = '/dashboard/buttons/standard-buttons';
  static const buttonsDropdowns = '/dashboard/buttons/dropdowns';
  static const buttonsGroups = '/dashboard/buttons/button-groups';
  static const buttonsBrand = '/dashboard/buttons/brand-buttons';
  static const charts = '/dashboard/charts';
  static const editorsCode = '/dashboard/editors/code-editors';
  static const editorsText = '/dashboard/editors/text-editors';
  static const formsBasic = '/dashboard/forms/basic-forms';
  static const formsAdvanced = '/dashboard/forms/advanced-forms';
  static const formsValidation = '/dashboard/forms/validation-forms';
  static const maps = '/dashboard/google-maps';
  static const iconsLibrary = '/dashboard/icons/coreui-icons';
  static const iconsBrands = '/dashboard/icons/brands';
  static const iconsFlags = '/dashboard/icons/flags';
  static const notificationsAlerts = '/dashboard/notifications/alerts';
  static const notificationsBadges = '/dashboard/notifications/badges';
  static const notificationsModals = '/dashboard/notifications/modals';
  static const notificationsToaster = '/dashboard/notifications/toaster';
  static const pluginsDraggable = '/dashboard/plugins/draggable';
  static const pluginsCalendar = '/dashboard/plugins/calendar';
  static const pluginsSpinners = '/dashboard/plugins/spinners';
  static const tablesBasic = '/dashboard/tables/tables';
  static const tablesAdvanced = '/dashboard/tables/advanced-tables';
  static const widgets = '/dashboard/widgets';
  static const analytics = '/dashboard/analytics';
  static const pages404 = '/dashboard/pages/404';
  static const pages500 = '/dashboard/pages/500';
  static const appsInvoice = '/dashboard/apps/invoicing/invoice';
  static const appsInbox = '/dashboard/apps/email/inbox';
  static const appsMessage = '/dashboard/apps/email/message';
  static const appsCompose = '/dashboard/apps/email/compose';

  /// Inside the signed-in area.
  static bool isApp(String path) => path == dashboard || path.startsWith('$dashboard/');
}
