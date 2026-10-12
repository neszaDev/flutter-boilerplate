import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/analytics_data.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/analytics_users_table.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/brand_icon.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tile_grid.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tone_progress.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tones.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widget_cards.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Monday 31 August 2026, the first day of the demo week.
final _monday = DateTime.utc(2026, 8, 31);

/// The traffic and sales card of the dashboard: client callouts with bars per weekday,
/// audience by gender and source, and the users table.
class TrafficSales extends StatelessWidget {
  const TrafficSales({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SheetCard(
      title: l10n.trafficSalesTitle,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TileGrid(minTileWidth: 300, spacing: Space.xl, children: [_Clients(), _Audience()]),
          SizedBox(height: Space.xl),
          AnalyticsUsersTable(),
        ],
      ),
    );
  }
}

/// A figure under a tracked label, with a rule in the tone on its leading edge.
class _Callout extends StatelessWidget {
  const _Callout({required this.label, required this.value, required this.tone});

  final String label;
  final String value;
  final Tone tone;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Container(
      padding: const EdgeInsetsDirectional.only(start: Space.md, top: Space.xs, bottom: Space.xs),
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: ToneColors.of(context, tone).fill, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormLabel(label),
          const SizedBox(height: Space.xs),
          WidgetFigure(value, color: context.colors.ink950),
        ],
      ),
    ),
  );
}

/// A legend entry: a round swatch and its name.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.tone, required this.label});

  final Tone tone;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ExcludeSemantics(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: ToneColors.of(context, tone).fill,
            shape: BoxShape.circle,
          ),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: context.text.bodySmall?.copyWith(color: context.colors.ink700)),
    ],
  );
}

/// A share row: icon, name, figure, then its bar.
class _ShareRow extends StatelessWidget {
  const _ShareRow({
    required this.icon,
    required this.label,
    required this.figure,
    required this.value,
    required this.tone,
    this.detail,
  });

  final Widget icon;
  final String label;
  final String figure;
  final String? detail;
  final double value;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = context.text.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ExcludeSemantics(child: icon),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text(label, style: small?.copyWith(color: colors.ink700)),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: figure,
                    style: context.type.table.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.ink950,
                    ),
                  ),
                  if (detail != null)
                    TextSpan(
                      text: ' ($detail)',
                      style: context.type.table.copyWith(fontSize: 13, color: colors.ink600),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ToneProgress(value: value, label: label, tone: tone),
      ],
    );
  }
}

class _Clients extends StatelessWidget {
  const _Clients();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weekday = DateFormat.EEEE(context.localeName);
    return Semantics(
      container: true,
      label: l10n.trafficSalesClientsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _Callout(
                  label: l10n.trafficSalesNewClients,
                  value: context.formatNumber(salesCallouts.newClients),
                  tone: Tone.ink,
                ),
              ),
              const SizedBox(width: Space.page),
              Expanded(
                child: _Callout(
                  label: l10n.trafficSalesRecurringClients,
                  value: context.formatNumber(salesCallouts.recurringClients),
                  tone: Tone.pencil,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.page),
          const Divider(),
          for (final (index, day) in clientsByDay.indexed) ...[
            const SizedBox(height: Space.page),
            Builder(
              builder: (context) {
                final name = weekday.format(_monday.add(Duration(days: index)));
                return Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(name, style: context.text.bodySmall),
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Column(
                        children: [
                          ToneProgress(
                            value: day.fresh,
                            tone: Tone.ink,
                            label: l10n.trafficSalesBarLabel(l10n.trafficSalesNewClients, name),
                          ),
                          const SizedBox(height: Space.xs),
                          ToneProgress(
                            value: day.recurring,
                            tone: Tone.pencil,
                            label: l10n.trafficSalesBarLabel(
                              l10n.trafficSalesRecurringClients,
                              name,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: Space.page),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.page,
            children: [
              _Swatch(tone: Tone.ink, label: l10n.trafficSalesNewClients),
              _Swatch(tone: Tone.pencil, label: l10n.trafficSalesRecurringClients),
            ],
          ),
        ],
      ),
    );
  }
}

class _Audience extends StatelessWidget {
  const _Audience();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final percent = NumberFormat.percentPattern(context.localeName);
    String share(double value) => percent.format(value / 100);
    String source(SourceId id) => switch (id) {
      SourceId.organic => l10n.trafficSalesOrganicSearch,
      SourceId.facebook => l10n.trafficSalesFacebook,
      SourceId.twitter => l10n.trafficSalesTwitter,
      SourceId.linkedin => l10n.trafficSalesLinkedin,
    };

    return Semantics(
      container: true,
      label: l10n.trafficSalesAudienceLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _Callout(
                  label: l10n.trafficSalesPageviews,
                  value: context.formatNumber(salesCallouts.pageviews),
                  tone: Tone.slate,
                ),
              ),
              const SizedBox(width: Space.page),
              Expanded(
                child: _Callout(
                  label: l10n.trafficSalesOrganic,
                  value: context.formatNumber(salesCallouts.organic),
                  tone: Tone.pass,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.page),
          const Divider(),
          for (final (icon, label, value) in [
            (LucideIcons.user, l10n.trafficSalesMale, genderSplit.male),
            (LucideIcons.userRound, l10n.trafficSalesFemale, genderSplit.female),
          ]) ...[
            const SizedBox(height: Space.page),
            _ShareRow(
              icon: Icon(icon, size: 16, color: colors.ink600),
              label: label,
              figure: share(value),
              value: value,
              tone: Tone.slate,
            ),
          ],
          const SizedBox(height: Space.sm),
          for (final item in sources) ...[
            const SizedBox(height: Space.page),
            _ShareRow(
              icon: switch (item.brand) {
                final brand? => BrandIcon(brand, size: 16, color: colors.ink600),
                null => Icon(LucideIcons.globe, size: 16, color: colors.ink600),
              },
              label: source(item.id),
              figure: context.formatNumber(item.count),
              detail: share(item.percent),
              value: item.percent,
              tone: Tone.pass,
            ),
          ],
        ],
      ),
    );
  }
}
