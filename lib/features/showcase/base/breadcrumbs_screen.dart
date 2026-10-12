import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_links.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final _google = Uri.parse('https://www.google.com');

/// `/dashboard/base/breadcrumbs`: three trails, where the last crumb is the current page and
/// every other one is a link.
class BreadcrumbsScreen extends StatefulWidget {
  const BreadcrumbsScreen({super.key});

  @override
  State<BreadcrumbsScreen> createState() => _BreadcrumbsScreenState();
}

class _BreadcrumbsScreenState extends State<BreadcrumbsScreen> {
  final _customKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final link = Theme.of(context).colorScheme.primary;
    final customStyle = context.text.titleLarge?.copyWith(fontWeight: FontWeight.w600);
    final customSeparator = Icon(LucideIcons.chevronsRight, size: 18, color: colors.pass);

    return AppPage(
      title: l10n.breadcrumbsPageTitle,
      description: Text(l10n.breadcrumbsPageDescription),
      children: [
        DemoCard(
          title: l10n.breadcrumbsPageCardTitle,
          description: l10n.breadcrumbsPageCardDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TrailSection(
                title: l10n.breadcrumbsPagePlainTitle,
                crumbs: [
                  _Crumb(
                    l10n.breadcrumbsPagePlainAdmin,
                    onTap: () => openAppPath(context, Routes.dashboard),
                  ),
                  _Crumb(
                    l10n.breadcrumbsPagePlainManage,
                    onTap: () => openAppPath(context, Routes.testResults),
                  ),
                  _Crumb(l10n.breadcrumbsPagePlainLibrary),
                ],
              ),
              const SizedBox(height: Space.lg),
              _TrailSection(
                title: l10n.breadcrumbsPageLinksTitle,
                crumbs: [
                  _Crumb(
                    l10n.breadcrumbsPageLinksDashboard,
                    onTap: () => openAppPath(context, Routes.dashboard),
                  ),
                  _Crumb(
                    l10n.breadcrumbsPageLinksWidgets,
                    onTap: () => openAppPath(context, Routes.widgets),
                  ),
                  _Crumb(
                    l10n.breadcrumbsPageLinksGoogle,
                    onTap: () => unawaited(openExternal(context, _google)),
                  ),
                  _Crumb(l10n.breadcrumbsPageLinksCurrent),
                ],
              ),
              const SizedBox(height: Space.lg),
              _TrailSection(
                key: _customKey,
                title: l10n.breadcrumbsPageCustomTitle,
                gap: Space.sm,
                separator: customSeparator,
                linkStyle: customStyle?.copyWith(color: link),
                currentStyle: customStyle?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.ink950,
                ),
                crumbs: [
                  for (final label in [
                    l10n.breadcrumbsPageCustomAdded,
                    l10n.breadcrumbsPageCustomCustom,
                  ])
                    _Crumb(label, onTap: () => revealSection(_customKey)),
                  _Crumb(l10n.breadcrumbsPageCustomClasses),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One crumb: a link when [onTap] is set, otherwise the current page.
@immutable
class _Crumb {
  const _Crumb(this.label, {this.onTap});

  final String label;
  final VoidCallback? onTap;
}

/// A titled trail of crumbs and separators that wraps on narrow screens.
class _TrailSection extends StatelessWidget {
  const _TrailSection({
    required this.title,
    required this.crumbs,
    this.gap = 6,
    this.separator,
    this.linkStyle,
    this.currentStyle,
    super.key,
  });

  final String title;
  final List<_Crumb> crumbs;
  final double gap;
  final Widget? separator;
  final TextStyle? linkStyle;
  final TextStyle? currentStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = context.text.bodyMedium?.copyWith(fontSize: 14);
    final separator =
        this.separator ?? Icon(LucideIcons.chevronRight, size: 14, color: colors.ink400);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: FormLabel(title)),
        const SizedBox(height: Space.xs),
        Semantics(
          container: true,
          explicitChildNodes: true,
          label: title,
          child: Wrap(
            spacing: gap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final (index, crumb) in crumbs.indexed) ...[
                if (index > 0) ExcludeSemantics(child: separator),
                if (crumb.onTap == null)
                  Text(
                    crumb.label,
                    style:
                        currentStyle ??
                        base?.copyWith(fontWeight: FontWeight.w500, color: colors.ink950),
                  )
                else
                  _CrumbLink(
                    crumb: crumb,
                    style: linkStyle ?? base?.copyWith(color: colors.ink600),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CrumbLink extends StatelessWidget {
  const _CrumbLink({required this.crumb, required this.style});

  final _Crumb crumb;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    child: InkWell(
      onTap: crumb.onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Center(widthFactor: 1, child: Text(crumb.label, style: style)),
        ),
      ),
    ),
  );
}
