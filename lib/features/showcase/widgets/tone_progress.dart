import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tones.dart';

/// A thin progress bar in one of the widget tones, announced with its name and value (as
/// "25%": assistive tech needs a plain number there).
class ToneProgress extends StatelessWidget {
  const ToneProgress({
    required this.value,
    required this.label,
    this.tone = Tone.folder,
    this.solid = false,
    super.key,
  });

  /// Percentage, 0 to 100.
  final double value;

  /// Accessible name of the bar.
  final String label;

  /// Bar colour on card stock (ignored when [solid]).
  final Tone tone;

  /// Draws a folder-ink bar for a card filled with a tone.
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Its own node, so the bar is announced apart from the card's text.
    return Semantics(
      container: true,
      child: LinearProgressIndicator(
        value: (value / 100).clamp(0, 1),
        minHeight: 6,
        borderRadius: BorderRadius.circular(3),
        color: solid ? colors.folderInk : ToneColors.of(context, tone).fill,
        backgroundColor: solid ? colors.folderInk.withValues(alpha: 0.25) : colors.ink100,
        semanticsLabel: label,
        semanticsValue: '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2)}%',
      ),
    );
  }
}
