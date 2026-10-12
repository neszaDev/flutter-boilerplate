import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';
import 'package:flutter_boilerplate/features/showcase/campus/labels.dart';

/// The campus app launcher (Vue `MAppItem`): one sheet per category, its app count, and a grid
/// of app tiles with an unread badge capped at "99+".
class AppLauncher extends StatelessWidget {
  const AppLauncher({required this.categories, super.key});

  final List<LauncherCategory> categories;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, category) in categories.indexed) ...[
        if (index > 0) const SizedBox(height: Space.page),
        _CategorySheet(category: category),
      ],
    ],
  );
}

String _categoryLabel(AppLocalizations l10n, LauncherCategoryName name) => switch (name) {
  LauncherCategoryName.events => l10n.campusLauncherCategoryEvents,
  LauncherCategoryName.services => l10n.campusLauncherCategoryServices,
  LauncherCategoryName.application => l10n.campusLauncherCategoryApplication,
  LauncherCategoryName.businessIntelligence => l10n.campusLauncherCategoryBusinessIntelligence,
};

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.category});

  final LauncherCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final label = _categoryLabel(l10n, category.name);
    return Semantics(
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Space.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(category.icon, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(label, style: context.text.titleMedium),
                    ),
                  ),
                  const SizedBox(width: Space.page),
                  Text(
                    l10n.campusLauncherAppCount(category.apps.length),
                    style: context.type.table.copyWith(
                      color: colors.ink700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.card),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Three tiles a row on a phone, four or six on wider screens, as on the web.
                  final width = constraints.maxWidth;
                  final columns = width >= 600 ? 6 : (width >= 420 ? 4 : 3);
                  final tileWidth = (width - Space.page * (columns - 1)) / columns;
                  return Wrap(
                    spacing: Space.page,
                    runSpacing: Space.card,
                    children: [
                      for (final app in category.apps)
                        SizedBox(
                          width: tileWidth,
                          child: _AppTile(app: app),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({required this.app});

  final LauncherApp app;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final name = l10n.campusLauncherAppApplication;
    final badge = badgeLabel(app.badge);
    return Semantics(
      container: true,
      label: badge == null ? name : '$name, ${l10n.campusLauncherNotifications(app.badge)}',
      excludeSemantics: true,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.ply,
                  borderRadius: BorderRadius.circular(Radii.lg),
                  border: Border.all(color: colors.ink200, width: 2),
                ),
                child: Icon(app.icon, size: 32, color: colors.ink900),
              ),
              if (badge != null)
                Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.error,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      textAlign: TextAlign.center,
                      style: context.type.table.copyWith(
                        fontSize: 12,
                        height: 1.33,
                        fontWeight: FontWeight.w700,
                        color: scheme.onError,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Text(
            name,
            textAlign: TextAlign.center,
            style: context.text.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
