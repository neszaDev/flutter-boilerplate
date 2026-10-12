import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart';

export 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart' show Tone;

/// The colours of a [Tone], resolved from the Marksheet tokens for the current theme.
///
/// By day they are the web app's classes (`bg-folder`, `text-ink-600`…). By night the solid
/// fills are darkened so folder-ink text stays readable on them, and the folder green of bars
/// and figures is lifted to the night [MarksheetColors.primary].
@immutable
class ToneColors {
  const ToneColors({
    required this.solid,
    required this.onSolid,
    required this.onSolidMuted,
    required this.fill,
    required this.text,
  });

  /// Resolves [tone] for the theme of [context].
  factory ToneColors.of(BuildContext context, Tone tone) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    Color over(Color color, double alpha) =>
        Color.alphaBlend(color.withValues(alpha: alpha), c.paperCard);

    final solid = switch (tone) {
      Tone.folder => c.folder,
      Tone.pass => dark ? over(c.pass, 0.4) : c.pass,
      Tone.ink => dark ? c.ink100 : c.ink900,
      Tone.slate => dark ? c.ink300 : c.ink600,
      Tone.pencil => dark ? over(c.pencil, 0.3) : c.pencil,
    };
    final fill = switch (tone) {
      Tone.folder => dark ? c.primary : c.folder,
      Tone.pass => c.pass,
      Tone.ink => c.ink900,
      Tone.slate => c.ink400,
      Tone.pencil => c.pencil,
    };
    final text = switch (tone) {
      Tone.folder => dark ? c.primary : c.folder,
      Tone.pass => c.pass,
      Tone.ink => c.ink900,
      Tone.slate => c.ink600,
      Tone.pencil => c.pencil,
    };
    return ToneColors(
      solid: solid,
      onSolid: c.folderInk,
      onSolidMuted: c.folderInk.withValues(alpha: 0.85),
      fill: fill,
      text: text,
    );
  }

  /// A whole card or band filled with the tone (`toneSolid`).
  final Color solid;

  /// Text and icons on [solid] (folder ink).
  final Color onSolid;

  /// Secondary text on [solid].
  final Color onSolidMuted;

  /// A bar, dot or chart stroke on card stock (`toneFill`, `toneColor`).
  final Color fill;

  /// A figure printed in the tone on card stock (`toneText`).
  final Color text;
}
