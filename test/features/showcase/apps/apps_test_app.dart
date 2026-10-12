import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/apps/compose_screen.dart';
import 'package:flutter_boilerplate/features/showcase/apps/inbox_screen.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox_controller.dart';
import 'package:flutter_boilerplate/features/showcase/apps/message_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void _phone(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(390 * 3, 844 * 3)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Pumps [home] in the app's localizations and theme on a phone-sized screen.
Future<void> pumpApps(WidgetTester tester, Widget home, {ThemeData? theme}) async {
  _phone(tester);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        theme: theme ?? AppTheme.light(),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pumps the three email screens behind a router that starts at [location], as the app routes
/// them (the screens read their query parameters from the router).
Future<GoRouter> pumpEmail(WidgetTester tester, String location, {ThemeData? theme}) async {
  _phone(tester);
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(path: Routes.appsInbox, builder: (context, state) => const InboxScreen()),
      GoRoute(path: Routes.appsMessage, builder: (context, state) => const MessageScreen()),
      GoRoute(path: Routes.appsCompose, builder: (context, state) => const ComposeScreen()),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        theme: theme ?? AppTheme.light(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// The shared mailbox of the pumped app.
List<Mail> mailboxOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Navigator).first)).read(mailboxProvider);

/// The checkbox that screen readers know as [label].
Finder checkboxLabelled(String label) =>
    find.byWidgetPredicate((widget) => widget is Checkbox && widget.semanticLabel == label);

/// The text field that screen readers know as [label].
Finder fieldLabelled(String label) => find.descendant(
  of: find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label == label),
  matching: find.byType(TextField),
);

/// The text of the field labelled [label].
String fieldText(WidgetTester tester, String label) =>
    tester.widget<TextField>(fieldLabelled(label)).controller?.text ?? '';
