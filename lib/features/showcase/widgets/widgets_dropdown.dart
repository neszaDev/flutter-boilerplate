import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/sparkline.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tile_grid.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tones.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widget_cards.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The four filled widgets, each with a figure, an options menu and a sparkline
/// (`WidgetsDropdown.vue`).
class WidgetsDropdown extends StatelessWidget {
  const WidgetsDropdown({super.key});

  @override
  Widget build(BuildContext context) => TileGrid(
    children: [for (final widget in dropdownWidgets) _DropdownCard(widget: widget)],
  );
}

class _DropdownCard extends StatelessWidget {
  const _DropdownCard({required this.widget});

  final DropdownWidget widget;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final toneColors = ToneColors.of(context, widget.tone);
    final chart = widget.chart;
    return Card(
      color: toneColors.solid,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.page, Space.xs, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WidgetFigure(context.formatNumber(widget.value), color: toneColors.onSolid),
                      Text(
                        l10n.widgetsDropdownMembersOnline,
                        style: context.text.bodyMedium?.copyWith(color: toneColors.onSolidMuted),
                      ),
                    ],
                  ),
                ),
                _OptionsMenu(
                  icon: widget.icon == DropdownIcon.pin ? LucideIcons.mapPin : LucideIcons.settings,
                  color: toneColors.onSolid,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          const Spacer(),
          if (chart.kind == SparklineKind.bar)
            Sparkline(
              kind: SparklineKind.bar,
              data: chart.points,
              name: l10n.widgetsDropdownSeries,
              color: toneColors.onSolid,
              fillOpacity: 0.45,
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: Space.page),
            )
          else
            Sparkline(
              data: chart.points,
              name: l10n.widgetsDropdownSeries,
              color: toneColors.onSolid,
              pointed: chart.pointed,
              linear: chart.linear,
              dotColor: toneColors.solid,
              fill: chart.area ? toneColors.onSolid : null,
              fillOpacity: chart.area ? 0.2 : null,
              strokeWidth: chart.area ? 2.5 : null,
              height: 70,
              padding: chart.area
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: Space.page - 10),
            ),
        ],
      ),
    );
  }
}

/// The widget's options button and its menu; the last action is disabled.
class _OptionsMenu extends StatelessWidget {
  const _OptionsMenu({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MenuAnchor(
      alignmentOffset: const Offset(-120, 0),
      menuChildren: [
        MenuItemButton(onPressed: () {}, child: Text(l10n.widgetsDropdownAction)),
        MenuItemButton(onPressed: () {}, child: Text(l10n.widgetsDropdownAnotherAction)),
        MenuItemButton(onPressed: () {}, child: Text(l10n.widgetsDropdownSomethingElse)),
        MenuItemButton(child: Text(l10n.widgetsDropdownDisabledAction)),
      ],
      builder: (context, controller, child) => IconButton(
        tooltip: l10n.widgetsDropdownOptions,
        icon: Icon(icon, size: 20, color: color),
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
