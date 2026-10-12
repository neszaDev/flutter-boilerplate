import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/rbac/role.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The localized name of a role (`AccountPage.role_USER`, …).
String roleLabel(AppLocalizations l10n, Role? role) => switch (role) {
  Role.user => l10n.accountPageRoleUSER,
  Role.admin => l10n.accountPageRoleADMIN,
  null => '—',
};

/// Shown in place of content the signed-in role may not see: when a route's permission is
/// missing, or the backend answered 403. Explains, never signs out.
class AccessDeniedView extends ConsumerWidget {
  const AccessDeniedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final role = ref.watch(currentUserProvider)?.role;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Mark(status: TestStatus.pending, size: 40),
            const SizedBox(height: Space.md),
            Text(l10n.accessDeniedTitle, style: context.text.headlineSmall),
            const SizedBox(height: Space.sm),
            Text(
              l10n.accessDeniedText(roleLabel(l10n, role)),
              style: context.text.bodyMedium?.copyWith(color: context.colors.ink600),
            ),
            const SizedBox(height: Space.page),
            OutlinedButton(
              onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
              child: Text(l10n.accessDeniedBack),
            ),
          ],
        ),
      ),
    );
  }
}

/// [AccessDeniedView] as a full screen with a back button.
class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(), body: const AccessDeniedView());
}
