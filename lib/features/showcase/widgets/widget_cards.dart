import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tone_progress.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tones.dart';

/// A large tabular figure that shrinks rather than wraps in a narrow tile.
class WidgetFigure extends StatelessWidget {
  const WidgetFigure(this.text, {this.size = 24, this.color, this.center = false, super.key});

  final String text;
  final double size;
  final Color? color;
  final bool center;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: center ? Alignment.center : AlignmentDirectional.centerStart,
    child: Text(
      text,
      maxLines: 1,
      style: context.type.figure.copyWith(fontSize: size, letterSpacing: -0.4, color: color),
    ),
  );
}

/// A card on card stock, or filled with a tone when [solid] is set.
class _ToneCard extends StatelessWidget {
  const _ToneCard({required this.child, this.solid, this.grouped = false});

  final Widget child;
  final Color? solid;

  /// Drops the card's own border, for a joined card group.
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    if (grouped) {
      return ColoredBox(color: solid ?? context.colors.paperCard, child: child);
    }
    return Card(
      color: solid,
      shape: solid == null
          ? null
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// A figure, a caption, a thin bar and a footnote (CoreUI `CWidgetProgress`).
class ProgressWidget extends StatelessWidget {
  const ProgressWidget({
    required this.header,
    required this.text,
    required this.footer,
    required this.value,
    required this.tone,
    this.inverse = false,
    super.key,
  });

  final String header;

  /// Caption under the figure; also names the bar.
  final String text;
  final String footer;

  /// Bar value, 0 to 100.
  final double value;
  final Tone tone;

  /// Fills the card with the tone.
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final toneColors = ToneColors.of(context, tone);
    return _ToneCard(
      solid: inverse ? toneColors.solid : null,
      child: Padding(
        padding: const EdgeInsets.all(Space.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetFigure(header, color: inverse ? toneColors.onSolid : colors.ink950),
            Text(
              text,
              style: context.text.bodyMedium?.copyWith(
                color: inverse ? toneColors.onSolidMuted : colors.ink700,
              ),
            ),
            const SizedBox(height: Space.md),
            ToneProgress(value: value, label: text, tone: tone, solid: inverse),
            const SizedBox(height: Space.md),
            Text(
              footer,
              style: context.text.bodySmall?.copyWith(
                color: inverse ? toneColors.onSolidMuted : colors.ink600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum IconWidgetLayout { padded, flush, wide }

/// A coloured icon block beside a figure and a label (CoreUI `CWidgetIcon`).
class IconWidget extends StatelessWidget {
  const IconWidget({
    required this.header,
    required this.text,
    required this.icon,
    required this.tone,
    required this.layout,
    this.footer,
    super.key,
  });

  /// The figure, printed in the tone.
  final String header;
  final String text;

  /// Decorative.
  final IconData icon;
  final Tone tone;

  /// Inset block, block to the card edge, or a wider flush block.
  final IconWidgetLayout layout;

  /// Optional footer row, such as a "view more" link.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final toneColors = ToneColors.of(context, tone);
    final padded = layout == IconWidgetLayout.padded;
    final block = ExcludeSemantics(
      child: Container(
        padding: switch (layout) {
          IconWidgetLayout.padded => const EdgeInsets.all(Space.md),
          IconWidgetLayout.flush => const EdgeInsets.all(Space.card),
          IconWidgetLayout.wide => const EdgeInsets.symmetric(horizontal: 40, vertical: Space.card),
        },
        decoration: BoxDecoration(
          color: toneColors.solid,
          borderRadius: padded ? BorderRadius.circular(Radii.sm) : null,
        ),
        child: Icon(icon, size: 24, color: toneColors.onSolid),
      ),
    );
    return _ToneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(padded ? Space.md : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  block,
                  const SizedBox(width: Space.page),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: padded ? 0 : Space.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetFigure(header, size: 18, color: toneColors.text),
                          FormLabel(text),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                ],
              ),
            ),
          ),
          if (footer != null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.paper,
                border: Border(top: BorderSide(color: colors.ink200)),
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}

/// An icon over a figure, a label and a thin bar (CoreUI `CWidgetProgressIcon`).
class ProgressIconWidget extends StatelessWidget {
  const ProgressIconWidget({
    required this.header,
    required this.text,
    required this.icon,
    required this.tone,
    required this.value,
    this.inverse = false,
    this.grouped = false,
    super.key,
  });

  final String header;

  /// Label under the figure; also names the bar.
  final String text;

  /// Decorative, shown top right.
  final IconData icon;
  final Tone tone;
  final double value;

  /// Fills the card with the tone.
  final bool inverse;

  /// Drops the card's own border, for a joined card group.
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final toneColors = ToneColors.of(context, tone);
    return _ToneCard(
      solid: inverse ? toneColors.solid : null,
      grouped: grouped,
      child: Padding(
        padding: const EdgeInsets.all(Space.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ExcludeSemantics(
                child: Icon(
                  icon,
                  size: 32,
                  color: inverse ? toneColors.onSolid.withValues(alpha: 0.7) : colors.ink400,
                ),
              ),
            ),
            const SizedBox(height: Space.page),
            WidgetFigure(header, color: inverse ? toneColors.onSolid : colors.ink950),
            FormLabel(text, color: inverse ? toneColors.onSolidMuted : null),
            const Spacer(),
            const SizedBox(height: Space.md),
            ToneProgress(value: value, label: text, tone: tone, solid: inverse),
          ],
        ),
      ),
    );
  }
}

/// A label, a large figure and a small chart, centred (CoreUI `CWidgetSimple`).
class SimpleWidget extends StatelessWidget {
  const SimpleWidget({
    required this.header,
    required this.text,
    required this.child,
    super.key,
  });

  /// Label above the figure.
  final String header;

  /// The figure.
  final String text;

  /// The chart.
  final Widget child;

  @override
  Widget build(BuildContext context) => _ToneCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.page),
      child: Column(
        children: [
          FormLabel(header),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.md),
            child: WidgetFigure(text, size: 30, center: true),
          ),
          child,
        ],
      ),
    ),
  );
}
