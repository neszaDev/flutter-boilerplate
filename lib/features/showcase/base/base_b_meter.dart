import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_meter_data.dart';

export 'package:flutter_boilerplate/features/showcase/base/base_b_meter_data.dart';

/// The fill of a tone, from the theme. Folder and folder deep lift to lighter greens at night
/// so the bars stay visible on the dark track.
Color meterToneColor(BuildContext context, MeterTone tone) {
  final colors = context.colors;
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (tone) {
    MeterTone.folder => colors.primary,
    MeterTone.ink => colors.ink600,
    MeterTone.pass => colors.pass,
    MeterTone.pencil => colors.pencil,
    MeterTone.deep => dark ? colors.folderInkSoft : colors.folderDeep,
    MeterTone.pen => colors.pen,
    MeterTone.light => colors.ink300,
    MeterTone.dark => colors.ink950,
  };
}

/// The default track height (the web's `h-4`).
const double meterHeight = 16;

/// A plain progress bar without a printed label (the web's `Progress` on a Marksheet track).
class PlainProgress extends StatelessWidget {
  const PlainProgress({
    required this.value,
    required this.label,
    this.height = meterHeight,
    super.key,
  });

  /// Percent filled, 0–100.
  final double value;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) => LinearProgressIndicator(
    value: meterFraction(value, 100),
    minHeight: height,
    color: context.colors.primary,
    backgroundColor: context.colors.ink100,
    borderRadius: BorderRadius.circular(Radii.sm),
    semanticsLabel: label,
  );
}

/// A progress bar with one or more stacked segments, each with its own tone, stripes, stripe
/// animation and printed label (the value or the percentage of [max], to [precision] decimals).
/// Each segment is a progress bar for screen readers; a stacked meter groups them under
/// [label]. Widths ease to new values, and stripes stand still, under reduced motion.
class Meter extends StatelessWidget {
  const Meter({
    required this.segments,
    required this.label,
    this.max = 100,
    this.precision = 0,
    this.height = meterHeight,
    super.key,
  });

  final List<MeterSegment> segments;
  final String label;

  /// The value of a full track.
  final double max;

  /// Decimals in printed labels.
  final int precision;
  final double height;

  @override
  Widget build(BuildContext context) {
    final stacked = segments.length > 1;
    final track = ClipRRect(
      borderRadius: BorderRadius.circular(Radii.sm),
      child: ColoredBox(
        color: context.colors.ink100,
        child: SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Segments share the track; one that would overflow it is cut to what is left.
              var left = constraints.maxWidth;
              final widths = <double>[];
              for (final segment in segments) {
                final width = math.min(
                  left,
                  constraints.maxWidth * meterFraction(segment.value, max),
                );
                widths.add(width);
                left -= width;
              }
              return Row(
                children: [
                  for (final (index, segment) in segments.indexed)
                    _MeterBar(
                      key: ValueKey(index),
                      segment: segment,
                      width: widths[index],
                      max: max,
                      precision: precision,
                      label: label,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
    return stacked
        ? Semantics(container: true, explicitChildNodes: true, label: label, child: track)
        : track;
  }
}

class _MeterBar extends StatefulWidget {
  const _MeterBar({
    required this.segment,
    required this.width,
    required this.max,
    required this.precision,
    required this.label,
    super.key,
  });

  final MeterSegment segment;
  final double width;
  final double max;
  final int precision;
  final String label;

  @override
  State<_MeterBar> createState() => _MeterBarState();
}

class _MeterBarState extends State<_MeterBar> with SingleTickerProviderStateMixin {
  late final _stripes = AnimationController(vsync: this, duration: const Duration(seconds: 1));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(_MeterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    final move = widget.segment.animated && !MediaQuery.disableAnimationsOf(context);
    if (move && !_stripes.isAnimating) {
      unawaited(_stripes.repeat());
    } else if (!move && _stripes.isAnimating) {
      _stripes
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _stripes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segment = widget.segment;
    final colors = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final semantics = meterSemantics(
      value: segment.value,
      max: widget.max,
      label: segment.label ?? MeterLabel.percentage,
      precision: widget.precision,
    );
    final label = segment.label;
    return Semantics(
      container: true,
      excludeSemantics: true,
      role: SemanticsRole.progressBar,
      label: widget.label,
      value: semantics.value,
      minValue: semantics.min,
      maxValue: semantics.max,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        width: widget.width,
        color: meterToneColor(context, segment.tone),
        child: CustomPaint(
          painter: segment.striped || segment.animated
              ? _StripesPainter(color: colors.ply.withValues(alpha: 0.22), shift: _stripes)
              : null,
          child: label == null
              ? const SizedBox.expand()
              : Center(
                  child: Text(
                    meterText(
                      value: segment.value,
                      max: widget.max,
                      label: label,
                      locale: context.localeName,
                      precision: widget.precision,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: segment.tone == MeterTone.light ? colors.ink950 : colors.ply,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Diagonal stripes, 16 pt apart (the web's 45° gradient on a 1 rem tile), slid right to left
/// by [shift] (0–1 of a period).
class _StripesPainter extends CustomPainter {
  _StripesPainter({required this.color, required this.shift}) : super(repaint: shift);

  final Color color;
  final Animation<double> shift;

  static const _period = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    canvas.clipRect(Offset.zero & size);
    final paint = Paint()..color = color;
    final offset = _period * (1 - shift.value);
    final path = Path();
    // Bands where (x - offset - y) mod 16 < 8: lines from the top edge down to the right.
    for (var start = offset - size.height - _period; start < size.width; start += _period) {
      path
        ..moveTo(start, 0)
        ..lineTo(start + _period / 2, 0)
        ..lineTo(start + _period / 2 + size.height, size.height)
        ..lineTo(start + size.height, size.height)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StripesPainter old) => old.color != color || old.shift != shift;
}
