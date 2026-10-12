import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_boilerplate/core/router/nav_items.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

class _FixedSession extends SessionController {
  _FixedSession(this.initial);

  final SessionState initial;

  @override
  SessionState build() => initial;
}

void main() {
  group('Access', () {
    test('gives every signed-in role the member permissions', () {
      for (final role in [Role.user, Role.admin, null]) {
        expect(Access.forRole(role).canAll(memberPermissions), isTrue, reason: '$role');
      }
    });

    test('keeps user management to admins', () {
      final user = Access.forRole(Role.user);
      final admin = Access.forRole(Role.admin);

      expect(
        user.canAny([Permission.viewUsers, Permission.editUsers, Permission.deleteUsers]),
        isFalse,
      );
      expect(
        admin.canAll([Permission.viewUsers, Permission.editUsers, Permission.deleteUsers]),
        isTrue,
      );
    });

    test('gives nothing to nobody', () {
      expect(Access.none.permissions, isEmpty);
    });

    test('reads roles the backend sends, and ignores unknown ones', () {
      expect(Role.fromApi('ADMIN'), Role.admin);
      expect(Role.fromApi('USER'), Role.user);
      expect(Role.fromApi('AUDITOR'), isNull);
    });
  });

  group('navSections', () {
    late AppLocalizations l10n;
    setUpAll(() async => l10n = await englishStrings());

    Iterable<String> paths(List<NavSection> sections) => sections.expand(
      (section) => section.entries.expand(
        (entry) => switch (entry) {
          NavLink(:final path) => [path],
          NavGroup(:final items) => items.map((item) => item.path),
          _ => const <String>[],
        },
      ),
    );

    test('shows user management to admins only', () {
      expect(paths(navSections(l10n, Access.forRole(Role.admin))), contains(Routes.users));
      expect(paths(navSections(l10n, Access.forRole(Role.user))), isNot(contains(Routes.users)));
    });
  });

  group('PermissionGate', () {
    Future<void> pumpGate(WidgetTester tester, Role role) => pumpScreen(
      tester,
      const Scaffold(
        body: PermissionGate(
          permission: Permission.deleteUsers,
          fallback: Text('hidden'),
          child: Text('delete'),
        ),
      ),
      overrides: [
        sessionProvider.overrideWith(
          () => _FixedSession(SignedIn(UserProfile(id: 1, email: 'a@b.co', role: role))),
        ),
      ],
    );

    testWidgets('shows the control when the role has the permission', (tester) async {
      await pumpGate(tester, Role.admin);

      expect(find.text('delete'), findsOneWidget);
    });

    testWidgets('shows the fallback when it does not', (tester) async {
      await pumpGate(tester, Role.user);

      expect(find.text('delete'), findsNothing);
      expect(find.text('hidden'), findsOneWidget);
    });
  });

  group('RequirePermission', () {
    testWidgets('replaces a screen with the access-denied view', (tester) async {
      final l10n = await englishStrings();
      await pumpScreen(
        tester,
        const RequirePermission(permission: Permission.viewUsers, child: Text('users')),
        overrides: [
          sessionProvider.overrideWith(
            () => _FixedSession(
              const SignedIn(UserProfile(id: 1, email: 'a@b.co', role: Role.user)),
            ),
          ),
        ],
      );

      expect(find.text('users'), findsNothing);
      expect(find.text(l10n.accessDeniedTitle), findsOneWidget);
      expect(find.text(l10n.accessDeniedText(l10n.accountPageRoleUSER)), findsOneWidget);
    });
  });
}
