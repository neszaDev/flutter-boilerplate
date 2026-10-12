import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_collapse.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_links.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_colors.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A card with header actions: a settings link, a button that folds the body away and one that
/// closes the card. A closed card leaves a button to bring it back.
class ActionsCard extends StatefulWidget {
  const ActionsCard({required this.child, this.tone, super.key});

  /// The card body.
  final Widget child;

  /// Fills the card with a tone.
  final Tone? tone;

  @override
  State<ActionsCard> createState() => _ActionsCardState();
}

class _ActionsCardState extends State<ActionsCard> {
  bool _open = true;
  bool _shown = true;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    return AnimatedSwitcher(
      duration: duration,
      child: _shown ? _card(context) : _restore(context),
    );
  }

  Widget _restore(BuildContext context) => CustomPaint(
    key: const ValueKey('restore'),
    painter: _DashedBorderPainter(color: context.colors.ink300, radius: Radii.sm),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 160, minWidth: double.infinity),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: () => setState(() => _shown = true),
          icon: const Icon(LucideIcons.rotateCcw, size: 16),
          label: Text(context.l10n.cardsPageActionsRestore),
        ),
      ),
    ),
  );

  Widget _card(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final tone = widget.tone == null ? null : ToneColors.of(context, widget.tone!);
    final foreground = tone?.onSolid ?? colors.ink950;
    return Card(
      key: const ValueKey('card'),
      color: tone?.solid,
      shape: tone == null
          ? null
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.card, Space.sm, Space.xs, Space.sm),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.cardsPageActionsTitle,
                      style: context.text.titleLarge?.copyWith(color: foreground),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.cardsPageActionsSettings,
                  color: foreground,
                  onPressed: () => openAppPath(context, Routes.account),
                  icon: const Icon(LucideIcons.settings, size: 18),
                ),
                MergeSemantics(
                  child: Semantics(
                    expanded: _open,
                    child: IconButton(
                      tooltip: _open ? l10n.cardsPageActionsMinimize : l10n.cardsPageActionsExpand,
                      color: foreground,
                      onPressed: () => setState(() => _open = !_open),
                      icon: Icon(_open ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 18),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.cardsPageActionsClose,
                  color: foreground,
                  onPressed: () => setState(() => _shown = false),
                  icon: const Icon(LucideIcons.x, size: 18),
                ),
              ],
            ),
          ),
          Collapse(
            open: _open,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Divider(color: colors.ink300),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.card,
                    Space.page,
                    Space.card,
                    Space.card,
                  ),
                  child: DefaultTextStyle.merge(
                    style: context.text.bodyMedium?.copyWith(color: foreground),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A dashed rounded frame: where a closed card was.
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final outline = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(0.5));
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in outline.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += dash + gap) {
        canvas.drawPath(metric.extractPath(start, start + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color || old.radius != radius;
}
