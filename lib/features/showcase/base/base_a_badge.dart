import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_colors.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';

/// The web's `Badge`: a small upper-case label. Filled in [tone], or the primary green when no
/// tone is given; [destructive] prints it in red pen on a red wash.
class ToneBadge extends StatelessWidget {
  const ToneBadge(
    this.text, {
    this.tone,
    this.destructive = false,
    this.pill = false,
    this.semanticsLabel,
    super.key,
  });

  final String text;
  final Tone? tone;
  final bool destructive;

  /// Fully rounded ends (counts).
  final bool pill;

  /// Read instead of [text] (e.g. "14 tests" for "14").
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final toneColors = tone == null ? null : ToneColors.of(context, tone!);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (background, foreground) = destructive
        ? (colors.pen.withValues(alpha: dark ? 0.20 : 0.10), colors.pen)
        : (toneColors?.solid ?? scheme.primary, toneColors?.onSolid ?? scheme.onPrimary);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: Space.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(pill ? 999 : Radii.sm),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          text.toUpperCase(),
          // Read in its own case: screen readers spell out some upper-case words.
          semanticsLabel: semanticsLabel ?? text,
          maxLines: 1,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            height: 1,
            color: foreground,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
