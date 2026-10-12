import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The signed-in app: one tab per main destination, each with its own navigation stack (the
/// web app's sidebar becomes the Menu tab).
class AppShell extends ConsumerWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final access = ref.watch(accessProvider);
    // Tabs in branch order (app_router.dart). A tab the role lacks is hidden, not disabled.
    final tabs = [
      (0, LucideIcons.layoutGrid, l10n.appTabsOverview, Permission.viewDashboard),
      (1, LucideIcons.clipboardList, l10n.appTabsResults, Permission.manageOwnTestResults),
      (2, LucideIcons.folderOpen, l10n.appTabsFiles, Permission.manageOwnFiles),
      (3, LucideIcons.smartphone, l10n.appTabsPhone, Permission.useDeviceFeatures),
      (4, LucideIcons.menu, l10n.appTabsMenu, null),
    ].where((tab) => tab.$4 == null || access.can(tab.$4!)).toList();
    final selected = tabs.indexWhere((tab) => tab.$1 == shell.currentIndex);

    // A NavigationBar needs two destinations. Fewer happens for a role with a single tab, and
    // for one frame on sign-out (no permissions left, before the router leaves /dashboard).
    if (tabs.length < 2) {
      return Scaffold(body: shell);
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        onDestinationSelected: (index) {
          final branch = tabs[index].$1;
          // Tapping the current tab again goes back to its first screen.
          shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
        },
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              key: Key('tab.${tab.$1}'),
              icon: Icon(tab.$2),
              label: tab.$3,
            ),
        ],
      ),
    );
  }
}
