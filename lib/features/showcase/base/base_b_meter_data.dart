import 'package:intl/intl.dart';

/// What a meter segment prints on itself: its value, or its share of the track in percent.
enum MeterLabel { value, percentage }

/// The Marksheet stand-ins for the Bootstrap colour variants of the CoreUI demos (the web app's
/// `Tone`): primary → folder, secondary → ink, success → pass, warning → pencil, info → deep,
/// danger → pen, light → light, dark → dark.
enum MeterTone { folder, ink, pass, pencil, deep, pen, light, dark }

/// One bar of a meter (the web app's `MeterSegment`).
class MeterSegment {
  const MeterSegment({
    required this.value,
    this.tone = MeterTone.folder,
    this.striped = false,
    this.animated = false,
    this.label,
  });

  final double value;
  final MeterTone tone;

  /// Diagonal stripes over the fill. [animated] stripes are drawn even when this is false.
  final bool striped;

  /// Moving stripes (still under reduced motion).
  final bool animated;

  /// What to print on the bar; nothing when null.
  final MeterLabel? label;

  MeterSegment copyWith({bool? striped, bool? animated, MeterLabel? label}) => MeterSegment(
    value: value,
    tone: tone,
    striped: striped ?? this.striped,
    animated: animated ?? this.animated,
    label: label ?? this.label,
  );
}

/// The share of the track [value] fills, between 0 and 1.
double meterFraction(double value, double max) =>
    max <= 0 ? 0 : (value / max).clamp(0, 1).toDouble();

/// The text printed on a segment: the value, or its percentage of [max], to [precision]
/// decimals, in the [locale]'s format ("33.33", "67%", "66,67 %").
String meterText({
  required double value,
  required double max,
  required MeterLabel label,
  required String locale,
  int precision = 0,
}) {
  final format = label == MeterLabel.percentage
      ? NumberFormat.percentPattern(locale)
      : NumberFormat.decimalPattern(locale);
  format
    ..minimumFractionDigits = precision
    ..maximumFractionDigits = precision;
  return format.format(label == MeterLabel.percentage ? value / max : value);
}

/// What a screen reader announces for a segment, and the range it is read against: the value
/// clamped to the track for value labels, else the percentage. Numbers are locale-independent
/// so the progress-bar semantics stay valid.
({String value, String min, String max}) meterSemantics({
  required double value,
  required double max,
  MeterLabel label = MeterLabel.percentage,
  int precision = 0,
}) {
  if (label == MeterLabel.value) {
    final clamped = value.clamp(0, max).toDouble();
    final top = max == max.roundToDouble() ? max.toStringAsFixed(0) : '$max';
    return (value: clamped.toStringAsFixed(precision), min: '0', max: top);
  }
  final percent = meterFraction(value, max) * 100;
  return (value: '${percent.toStringAsFixed(precision)}%', min: '0', max: '100');
}
