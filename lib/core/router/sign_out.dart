import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/router/app_router.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Signs out and shows the welcome screen, like the web app's sign-out. (Losing the session any
/// other way, e.g. an expired refresh token, lands on sign-in instead.)
///
/// The router is read before signing out: the calling screen is usually disposed by the
/// redirect that follows, and its `ref` with it.
Future<void> signOutToWelcome(WidgetRef ref) async {
  final router = ref.read(routerProvider);
  await ref.read(sessionProvider.notifier).signOut();
  router.go(Routes.welcome);
}
