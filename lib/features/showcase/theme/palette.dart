import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';

/// The Marksheet palette as data, for the colours page: one entry per [MarksheetColors] token,
/// named like its field, with the token it is read against for the contrast figure.
enum PaletteToken {
  folder,
  folderDeep,
  folderInk,
  folderInkSoft,
  primary,
  onPrimary,
  pass,
  pen,
  pencil,
  paper,
  paperCard,
  ply,
  ink950,
  ink900,
  ink700,
  ink600,
  ink400,
  ink300,
  ink200,
  ink100;

  /// This token's colour in [colors].
  Color of(MarksheetColors colors) => switch (this) {
    folder => colors.folder,
    folderDeep => colors.folderDeep,
    folderInk => colors.folderInk,
    folderInkSoft => colors.folderInkSoft,
    primary => colors.primary,
    onPrimary => colors.onPrimary,
    pass => colors.pass,
    pen => colors.pen,
    pencil => colors.pencil,
    paper => colors.paper,
    paperCard => colors.paperCard,
    ply => colors.ply,
    ink950 => colors.ink950,
    ink900 => colors.ink900,
    ink700 => colors.ink700,
    ink600 => colors.ink600,
    ink400 => colors.ink400,
    ink300 => colors.ink300,
    ink200 => colors.ink200,
    ink100 => colors.ink100,
  };

  /// The colour this one is read with: text on a surface, a surface under ink.
  PaletteToken get pair => switch (this) {
    folder || folderDeep => folderInk,
    folderInk || folderInkSoft => folder,
    primary => onPrimary,
    onPrimary => primary,
    paper || paperCard || ply || ink100 => ink900,
    ink400 => ply,
    pass || pen || pencil || ink950 || ink900 || ink700 || ink600 || ink300 || ink200 => paperCard,
  };
}

/// The surfaces, the cover and the marks, in the order the page lists them.
const themeColors = [
  PaletteToken.folder,
  PaletteToken.folderDeep,
  PaletteToken.folderInk,
  PaletteToken.folderInkSoft,
  PaletteToken.primary,
  PaletteToken.onPrimary,
  PaletteToken.pass,
  PaletteToken.pen,
  PaletteToken.pencil,
  PaletteToken.paper,
  PaletteToken.paperCard,
  PaletteToken.ply,
];

/// The navy ink ramp, darkest first (in the light theme).
const inkRamp = [
  PaletteToken.ink950,
  PaletteToken.ink900,
  PaletteToken.ink700,
  PaletteToken.ink600,
  PaletteToken.ink400,
  PaletteToken.ink300,
  PaletteToken.ink200,
  PaletteToken.ink100,
];

int _channel(double value) => (value * 255).round();

/// Red, green and blue of [color], 0–255.
List<int> rgbOf(Color color) => [_channel(color.r), _channel(color.g), _channel(color.b)];

/// [color] as `#rrggbb`.
String hexOf(Color color) =>
    '#${rgbOf(color).map((channel) => channel.toRadixString(16).padLeft(2, '0')).join()}';

double _luminance(Color color) {
  double linear(double channel) =>
      channel <= 0.04045 ? channel / 12.92 : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * linear(color.r) + 0.7152 * linear(color.g) + 0.0722 * linear(color.b);
}

/// The WCAG 2 contrast ratio between two colours, from 1 (none) to 21 (black on white).
double contrastRatio(Color first, Color second) {
  final a = _luminance(first);
  final b = _luminance(second);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

/// The WCAG levels a contrast ratio can reach.
enum ContrastLevel {
  /// 7:1.
  aaa,

  /// 4.5:1, body text.
  aa,

  /// 3:1, large text and controls.
  large,

  /// Below 3:1: rules and fills only.
  decorative,
}

/// The WCAG level [ratio] reaches.
ContrastLevel contrastLevel(double ratio) => switch (ratio) {
  >= 7 => ContrastLevel.aaa,
  >= 4.5 => ContrastLevel.aa,
  >= 3 => ContrastLevel.large,
  _ => ContrastLevel.decorative,
};
