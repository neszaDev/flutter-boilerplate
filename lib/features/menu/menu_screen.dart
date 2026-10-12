import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/config/app_info.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_boilerplate/core/router/nav_items.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/brand.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/settings/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/menu`: everything the web sidebar holds, filtered by the account's permissions.
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  /// The bottom tabs: switch tab instead of stacking a second copy.
  static const _tabPaths = {Routes.dashboard, Routes.testResults, Routes.files, Routes.device};

  void _open(BuildContext context, String path) =>
      _tabPaths.contains(path) ? context.go(path) : context.push(path);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final user = ref.watch(currentUserProvider);
    final info = ref.watch(appInfoProvider);
    final sections = navSections(l10n, ref.watch(accessProvider));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: colors.folder,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.page, Space.page, Space.xs, Space.card),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Wordmark(onFolder: true),
                          Spacer(),
                          LocaleSwitcher(onFolder: true),
                        ],
                      ),
                      const SizedBox(height: Space.card),
                      Text(
                        l10n.dashboardLayoutSignedInAs,
                        style: context.text.bodySmall?.copyWith(color: colors.folderInkSoft),
                      ),
                      Text(
                        user?.email ?? '',
                        style: context.text.titleSmall?.copyWith(color: colors.folderInk),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          for (final section in sections) ...[
            if (section.title != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, Space.xs),
                sliver: SliverToBoxAdapter(child: FormLabel(section.title!)),
              ),
            SliverList.list(
              children: [
                for (final entry in section.entries)
                  switch (entry) {
                    NavLink() => ListTile(
                      key: Key('menu.${entry.path}'),
                      leading: Icon(entry.icon, size: 20),
                      title: Text(entry.label),
                      trailing: const Icon(LucideIcons.chevronRight, size: 18),
                      onTap: () => _open(context, entry.path),
                    ),
                    NavGroup() => ExpansionTile(
                      leading: Icon(entry.icon, size: 20),
                      title: Text(entry.label, style: context.text.titleSmall),
                      children: [
                        for (final item in entry.items)
                          ListTile(
                            contentPadding: const EdgeInsets.only(left: 56, right: Space.page),
                            title: Text(item.label),
                            onTap: () => _open(context, item.path),
                          ),
                      ],
                    ),
                    _ => const SizedBox.shrink(),
                  },
              ],
            ),
          ],
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, Space.section),
            sliver: SliverList.list(
              children: [
                Divider(color: colors.ink200),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.info, size: 20),
                  title: Text(l10n.menuPageAbout),
                  onTap: () => context.push(Routes.about),
                ),
                ListTile(
                  key: const Key('menu.signOut'),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(LucideIcons.logOut, size: 20, color: colors.pen),
                  title: Text(l10n.dashboardLayoutSignOut, style: TextStyle(color: colors.pen)),
                  onTap: () => confirmSignOut(context, ref),
                ),
                const SizedBox(height: Space.page),
                Text(
                  l10n.menuPageVersion(info.version, info.buildNumber),
                  style: context.text.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
