import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/sparkline.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tile_grid.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tones.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widget_cards.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_brand.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_dropdown.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _icons = [LucideIcons.settings, LucideIcons.laptop, LucideIcons.moon, LucideIcons.bell];

IconData _progressIcon(ProgressIconId id) => switch (id) {
  ProgressIconId.visitors => LucideIcons.users,
  ProgressIconId.newClients => LucideIcons.userPlus,
  ProgressIconId.productsSold => LucideIcons.shoppingBasket,
  ProgressIconId.returning => LucideIcons.chartPie,
  ProgressIconId.avgTime => LucideIcons.gauge,
  ProgressIconId.comments => LucideIcons.messageSquare,
};

String _simpleLabel(AppLocalizations l10n, SimpleWidgetId id) => switch (id) {
  SimpleWidgetId.sessions => l10n.widgetsPageSimpleSessions,
  SimpleWidgetId.signUps => l10n.widgetsPageSimpleSignUps,
  SimpleWidgetId.downloads => l10n.widgetsPageSimpleDownloads,
  SimpleWidgetId.orders => l10n.widgetsPageSimpleOrders,
  SimpleWidgetId.refunds => l10n.widgetsPageSimpleRefunds,
  SimpleWidgetId.reviews => l10n.widgetsPageSimpleReviews,
};

/// `/dashboard/widgets`: the dashboard figure cards in every variant (progress, icon, brand,
/// progress icon, dropdown and simple widgets).
class WidgetsScreen extends StatelessWidget {
  const WidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeName;
    // US dollars, with the symbol each language uses for them ("$", "$US").
    final currency = NumberFormat.currency(
      locale: locale,
      name: 'USD',
      symbol: l10n.widgetsPageUsdSymbol,
    );
    final percent = NumberFormat.percentPattern(locale);
    final uptime = NumberFormat.percentPattern(locale)..maximumFractionDigits = 1;

    final progress = [
      (
        header: uptime.format(0.899),
        text: l10n.widgetsPageProgressUptime,
        footer: l10n.widgetsPageProgressUptimeNote,
      ),
      (
        header: context.formatNumber(12124),
        text: l10n.widgetsPageProgressOrders,
        footer: l10n.widgetsPageProgressOrdersNote,
      ),
      (
        header: currency.format(98111),
        text: l10n.widgetsPageProgressRevenue,
        footer: l10n.widgetsPageProgressRevenueNote,
      ),
      (
        header: l10n.widgetsPageProgressStorageValue(context.formatNumber(2)),
        text: l10n.widgetsPageProgressStorage,
        footer: l10n.widgetsPageProgressStorageNote,
      ),
    ];
    final income = currency.format(1999.5);
    ({String header, String text}) progressIcon(ProgressIconId id) => switch (id) {
      ProgressIconId.visitors => (
        header: context.formatNumber(87500),
        text: l10n.widgetsPageVisitors,
      ),
      ProgressIconId.newClients => (
        header: context.formatNumber(385),
        text: l10n.widgetsPageNewClients,
      ),
      ProgressIconId.productsSold => (
        header: context.formatNumber(1238),
        text: l10n.widgetsPageProductsSold,
      ),
      ProgressIconId.returning => (
        header: percent.format(0.28),
        text: l10n.widgetsPageReturningVisitors,
      ),
      // A duration, printed as the Vue demo did.
      ProgressIconId.avgTime => (header: '5:34:11', text: l10n.widgetsPageAvgTime),
      ProgressIconId.comments => (
        header: context.formatNumber(972),
        text: l10n.widgetsPageComments,
      ),
    };

    Widget progressIconWidget(
      ({ProgressIconId id, Tone tone}) widget, {
      required bool inverse,
      bool grouped = false,
    }) {
      final figure = progressIcon(widget.id);
      return ProgressIconWidget(
        header: figure.header,
        text: figure.text,
        icon: _progressIcon(widget.id),
        tone: widget.tone,
        value: progressValue,
        inverse: inverse,
        grouped: grouped,
      );
    }

    return AppPage(
      title: l10n.widgetsPageTitle,
      description: Text(l10n.widgetsPageDescription),
      gap: Space.xl,
      children: [
        _Section(
          title: l10n.widgetsPageProgressTitle,
          description: l10n.widgetsPageProgressDescription,
          children: [
            for (final inverse in [false, true])
              TileGrid(
                children: [
                  for (final (index, item) in progress.indexed)
                    ProgressWidget(
                      header: item.header,
                      text: item.text,
                      footer: item.footer,
                      value: progressValue,
                      tone: rowTones[index],
                      inverse: inverse,
                    ),
                ],
              ),
          ],
        ),
        _Section(
          title: l10n.widgetsPageIconTitle,
          description: l10n.widgetsPageIconDescription,
          children: [
            for (final layout in [IconWidgetLayout.padded, IconWidgetLayout.flush])
              TileGrid(
                minTileWidth: 220,
                children: [
                  for (final (index, icon) in _icons.indexed)
                    IconWidget(
                      header: income,
                      text: l10n.widgetsPageIncome,
                      icon: icon,
                      tone: iconTones[index],
                      layout: layout,
                    ),
                ],
              ),
            TileGrid(
              minTileWidth: 260,
              children: [
                for (final (index, icon) in _icons.take(3).indexed)
                  IconWidget(
                    header: income,
                    text: l10n.widgetsPageIncome,
                    icon: icon,
                    tone: iconTones[index],
                    layout: IconWidgetLayout.wide,
                    footer: index == 2 ? const _ViewMore() : null,
                  ),
              ],
            ),
          ],
        ),
        _Section(
          title: l10n.widgetsPageBrandTitle,
          description: l10n.widgetsPageBrandDescription,
          children: const [WidgetsBrand(), WidgetsBrand(charts: true)],
        ),
        _Section(
          title: l10n.widgetsPageProgressIconTitle,
          description: l10n.widgetsPageProgressIconDescription,
          children: [
            for (final inverse in [false, true])
              _CardGroup(
                children: [
                  for (final widget in progressIconWidgets.take(5))
                    progressIconWidget(widget, inverse: inverse, grouped: true),
                ],
              ),
            for (final inverse in [false, true])
              TileGrid(
                children: [
                  for (final widget in progressIconWidgets)
                    progressIconWidget(widget, inverse: inverse),
                ],
              ),
          ],
        ),
        _Section(
          title: l10n.widgetsPageDropdownTitle,
          description: l10n.widgetsPageDropdownDescription,
          children: const [WidgetsDropdown()],
        ),
        _Section(
          title: l10n.widgetsPageSimpleTitle,
          description: l10n.widgetsPageSimpleDescription,
          children: [
            TileGrid(
              minTileWidth: 140,
              children: [
                for (final widget in simpleWidgets)
                  SimpleWidget(
                    header: _simpleLabel(l10n, widget.id),
                    text: context.formatNumber(widget.value),
                    child: Sparkline(
                      kind: widget.kind,
                      data: salesPoints,
                      name: _simpleLabel(l10n, widget.id),
                      color: ToneColors.of(context, widget.tone).fill,
                      height: 40,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// A titled group of widget rows (the web page's `Section`; the widgets are cards themselves,
/// so no card around them).
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.description, required this.children});

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionTitle(title),
      const SizedBox(height: Space.xs),
      Text(description, style: context.text.bodyMedium?.copyWith(color: context.colors.ink600)),
      for (final child in children) ...[const SizedBox(height: Space.page), child],
    ],
  );
}

/// Widgets joined in one card, separated by hairlines (`grid gap-px bg-ink-200`).
class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    color: context.colors.ink200,
    child: TileGrid(
      spacing: 1,
      filler: ColoredBox(color: context.colors.paperCard),
      children: children,
    ),
  );
}

/// The "view more" footer link of the last wide icon widget.
class _ViewMore extends StatelessWidget {
  const _ViewMore();

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => unawaited(context.push<void>(Routes.analytics)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.widgetsPageViewMore,
                style: context.text.labelMedium?.copyWith(color: context.colors.ink600),
              ),
            ),
            Icon(LucideIcons.arrowRight, size: 16, color: context.colors.ink600),
          ],
        ),
      ),
    ),
  );
}
