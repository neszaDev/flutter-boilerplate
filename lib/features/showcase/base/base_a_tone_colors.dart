import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';

/// The colours of one [Tone] in the current theme (the web's `toneSolid`, `toneFill`,
/// `toneBorder`, `toneSoft` and `toneAccent`).
///
/// By day the tones are the web's. By night the folder greens, which are too dark to read on the
/// dark paper, are lifted wherever the tone sits on paper ([ink]); filled surfaces ([solid]) keep
/// the cover colours.
@immutable
class ToneColors {
  const ToneColors({
    required this.solid,
    required this.onSolid,
    required this.ink,
    required this.onInk,
    required this.softText,
    required this.softBackground,
    required this.softPressed,
  });

  /// The tone of [tone] in the theme of [context].
  factory ToneColors.of(BuildContext context, Tone tone) => ToneColors.resolve(
    tone,
    context.colors,
    dark: Theme.of(context).brightness == Brightness.dark,
  );

  /// The tone of [tone] from the palette [c].
  factory ToneColors.resolve(Tone tone, MarksheetColors c, {required bool dark}) {
    final (solid, onSolid) = switch (tone) {
      Tone.folder => (c.folder, c.folderInk),
      Tone.ink => (c.ink600, c.ply),
      Tone.pass => (c.pass, c.ply),
      Tone.pencil => (c.pencil, c.ply),
      Tone.deep => (c.folderDeep, c.folderInk),
      Tone.pen => (c.pen, c.ply),
      Tone.light => (c.ink200, c.ink950),
      Tone.dark => (c.ink950, c.ply),
    };
    final (ink, onInk) = switch (tone) {
      // `primary` is the folder green by day and a lighter green by night.
      Tone.folder => (c.primary, c.onPrimary),
      Tone.deep => dark ? (c.folderInkSoft, c.folderDeep) : (c.folderDeep, c.folderInk),
      Tone.light => (c.ink300, c.ink950),
      _ => (solid, onSolid),
    };
    return ToneColors(
      solid: solid,
      onSolid: onSolid,
      ink: ink,
      onInk: onInk,
      softText: switch (tone) {
        Tone.ink || Tone.light => c.ink700,
        _ => ink,
      },
      softBackground: tone == Tone.light ? c.ply : ink.withValues(alpha: 0.10),
      softPressed: tone == Tone.light ? c.paperCard : ink.withValues(alpha: 0.20),
    );
  }

  /// A whole surface filled with the tone (cards, badges, slides)…
  final Color solid;

  /// …and the text on it.
  final Color onSolid;

  /// The tone on paper: borders, top rules, bars, dots, a checked switch track. Readable on the
  /// page in both themes.
  final Color ink;

  /// Text on a surface filled with [ink].
  final Color onInk;

  /// A light wash of the tone with text printed in it, for contextual rows.
  final Color softText;
  final Color softBackground;

  /// The wash of a contextual row that is pressed (the web's hover).
  final Color softPressed;
}

/// The tone names in `BaseTones`.
extension ToneLabel on Tone {
  String label(AppLocalizations l10n) => switch (this) {
    Tone.folder => l10n.baseTonesFolder,
    Tone.ink => l10n.baseTonesInk,
    Tone.pass => l10n.baseTonesPass,
    Tone.pencil => l10n.baseTonesPencil,
    Tone.deep => l10n.baseTonesDeep,
    Tone.pen => l10n.baseTonesPen,
    Tone.light => l10n.baseTonesLight,
    Tone.dark => l10n.baseTonesDark,
  };
}

/// The web's `shadow-ply`: a control resting on a card.
List<BoxShadow> plyShadow(BuildContext context) => [
  BoxShadow(
    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.10),
    offset: const Offset(0, 1),
    blurRadius: 2,
  ),
];

/// The web's `shadow-sheet`: a raised sheet (the 3D switch knob).
List<BoxShadow> sheetShadow(BuildContext context) {
  final shadow = Theme.of(context).colorScheme.shadow;
  return [
    BoxShadow(color: shadow.withValues(alpha: 0.05), offset: const Offset(0, 1)),
    BoxShadow(color: shadow.withValues(alpha: 0.08), offset: const Offset(0, 1), blurRadius: 3),
  ];
}
