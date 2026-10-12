import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_boilerplate/core/router/auth_redirect.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/features/account/account_screen.dart';
import 'package:flutter_boilerplate/features/auth/auth_screens.dart';
import 'package:flutter_boilerplate/features/dashboard/dashboard_screen.dart';
import 'package:flutter_boilerplate/features/device/device_screens.dart';
import 'package:flutter_boilerplate/features/errors/system_screens.dart';
import 'package:flutter_boilerplate/features/files/files_screen.dart';
import 'package:flutter_boilerplate/features/marketing/marketing_screens.dart';
import 'package:flutter_boilerplate/features/menu/menu_screen.dart';
import 'package:flutter_boilerplate/features/settings/settings_screen.dart';
import 'package:flutter_boilerplate/features/shell/app_shell.dart';
import 'package:flutter_boilerplate/features/showcase/showcase_routes.dart';
import 'package:flutter_boilerplate/features/test_results/test_results_screen.dart';
import 'package:flutter_boilerplate/features/users/users_screens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The app's root navigator, for sheets and dialogs opened outside a screen (shake menu).
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// A route that needs [permission]: without it the screen is replaced by the access-denied
/// view (the router already sent signed-out users to sign-in).
GoRoute guardedRoute({
  required String path,
  required Permission permission,
  required Widget Function(GoRouterState state) builder,
}) => GoRoute(
  path: path,
  builder: (context, state) => RequirePermission(permission: permission, child: builder(state)),
);

StatefulShellBranch _tab(String path, Permission permission, Widget screen) => StatefulShellBranch(
  routes: [guardedRoute(path: path, permission: permission, builder: (_) => screen)],
);

final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<SessionState>(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => session.value = next);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: session,
    redirect: (context, state) => authRedirect(session.value, state.uri),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(path: Routes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: Routes.about, builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => SignInScreen(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (context, state) => SignUpScreen(from: state.uri.queryParameters['from']),
      ),

      // Tabs: each keeps its own stack (StatefulShellRoute), in AppShell's order.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          _tab(Routes.dashboard, Permission.viewDashboard, const DashboardScreen()),
          _tab(Routes.testResults, Permission.manageOwnTestResults, const TestResultsScreen()),
          _tab(Routes.files, Permission.manageOwnFiles, const FilesScreen()),
          _tab(Routes.device, Permission.useDeviceFeatures, const DeviceHubScreen()),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.menu, builder: (context, state) => const MenuScreen())],
          ),
        ],
      ),

      // Full-screen pages above the tabs.
      guardedRoute(
        path: Routes.account,
        permission: Permission.viewOwnAccount,
        builder: (_) => const AccountScreen(),
      ),
      GoRoute(path: Routes.settings, builder: (context, state) => const SettingsScreen()),
      guardedRoute(
        path: Routes.users,
        permission: Permission.viewUsers,
        builder: (_) => const UsersScreen(),
      ),
      guardedRoute(
        path: '${Routes.users}/:id',
        permission: Permission.viewUsers,
        builder: (state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return id == null || id < 1 ? const NotFoundScreen() : UserScreen(id: id);
        },
      ),
      ...deviceRoutes,
      ...showcaseRoutes,
    ],
  );
  ref.onDispose(() {
    router.dispose();
    session.dispose();
  });
  return router;
});
