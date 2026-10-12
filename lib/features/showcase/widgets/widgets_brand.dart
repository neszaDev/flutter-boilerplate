import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/brand_icon.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/sparkline.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tile_grid.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tones.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widget_cards.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The social widgets: a filled logo band (with a sparkline behind it when [charts]) over two
/// figures (`WidgetsBrand.vue`).
class WidgetsBrand extends StatelessWidget {
  const WidgetsBrand({this.charts = false, super.key});

  /// Draws the sparkline in each band (the Vue default; `noCharts` turned it off).
  final bool charts;

  @override
  Widget build(BuildContext context) => TileGrid(
    children: [for (final widget in brandWidgets) _BrandCard(widget: widget, charts: charts)],
  );
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.widget, required this.charts});

  final BrandWidget widget;
  final bool charts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final toneColors = ToneColors.of(context, widget.tone);
    final name = switch (widget.icon) {
      BrandWidgetIcon.facebook => l10n.widgetsBrandFacebook,
      BrandWidgetIcon.twitter => l10n.widgetsBrandTwitter,
      BrandWidgetIcon.linkedin => l10n.widgetsBrandLinkedin,
      BrandWidgetIcon.calendar => l10n.widgetsBrandCalendar,
    };
    String label(BrandLabel label) => switch (label) {
      BrandLabel.friends => l10n.widgetsBrandFriends,
      BrandLabel.feeds => l10n.widgetsBrandFeeds,
      BrandLabel.followers => l10n.widgetsBrandFollowers,
      BrandLabel.tweets => l10n.widgetsBrandTweets,
      BrandLabel.contacts => l10n.widgetsBrandContacts,
      BrandLabel.events => l10n.widgetsBrandEvents,
      BrandLabel.meetings => l10n.widgetsBrandMeetings,
    };
    String figure(BrandFigure item) {
      if (item.atLeast) {
        return l10n.widgetsBrandAtLeast(item.value);
      }
      return item.compact
          ? NumberFormat.compact(locale: context.localeName).format(item.value)
          : context.formatNumber(item.value);
    }

    final logo = switch (widget.icon) {
      BrandWidgetIcon.calendar => Icon(LucideIcons.calendar, size: 48, color: toneColors.onSolid),
      BrandWidgetIcon.facebook => BrandIcon(Brand.facebook, size: 48, color: toneColors.onSolid),
      BrandWidgetIcon.twitter => BrandIcon(Brand.twitter, size: 48, color: toneColors.onSolid),
      BrandWidgetIcon.linkedin => BrandIcon(Brand.linkedin, size: 48, color: toneColors.onSolid),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label: name,
            container: true,
            child: Container(
              height: 112,
              color: toneColors.solid,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (charts)
                    Positioned.fill(
                      child: Sparkline(
                        data: widget.points,
                        name: label(widget.left.label),
                        color: toneColors.onSolid.withValues(alpha: 0.55),
                        fill: toneColors.onSolid,
                        fillOpacity: 0.1,
                        height: null,
                      ),
                    ),
                  IgnorePointer(child: ExcludeSemantics(child: logo)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.page),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  for (final (index, item) in [widget.left, widget.right].indexed) ...[
                    if (index > 0) VerticalDivider(width: 1, color: colors.ink200),
                    Expanded(
                      child: MergeSemantics(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Space.sm),
                          child: Column(
                            children: [
                              WidgetFigure(figure(item), size: 20, center: true),
                              const SizedBox(height: Space.xs),
                              FormLabel(label(item.label)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
