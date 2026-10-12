import 'package:flutter/material.dart';

/// The categorical series colours of the showcase charts: green (the folder's hue), blue (the
/// ink's), magenta and ochre, always assigned in this order and never cycled.
///
/// Each set was checked with the data-viz palette validator against its chart surface
/// (`paperCard`): lightness band, chroma floor, colour-blind separation of every pair
/// (worst ΔE 8.4 by day, 8.6 by night), normal-vision separation and 3:1 contrast all pass.
/// The Marksheet inks alone are too grey to tell series apart, so charts don't reuse them for
/// series; the red pen stays reserved for errors.
@immutable
class ChartPalette {
  const ChartPalette._(this.series);

  static const light = ChartPalette._([
    Color(0xFF237A4B),
    Color(0xFF2F6BD0),
    Color(0xFFB8449B),
    Color(0xFFC77814),
  ]);

  static const dark = ChartPalette._([
    Color(0xFF3DA673),
    Color(0xFF5490F0),
    Color(0xFFD06AB8),
    Color(0xFFC98030),
  ]);

  /// The palette for the theme of [context].
  static ChartPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// The series colours, in their fixed order.
  final List<Color> series;

  /// The colour of series [index] (0-based). There are four: fold more series into "Other".
  Color operator [](int index) => series[index];
}
