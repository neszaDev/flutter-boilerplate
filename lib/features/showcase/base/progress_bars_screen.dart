import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_meter.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_progress_demos.dart';

// The Vue labels demo: a third of a track whose full value is 50.
const _labelValue = 33.333333333;
const _labelMax = 50.0;
const _value = 75.0;
const _stack = [
  MeterSegment(value: 15),
  MeterSegment(value: 30, tone: MeterTone.pass),
  MeterSegment(value: 20, tone: MeterTone.deep),
];

/// `/dashboard/base/progress-bars`: how far along something is, with labels, widths, heights,
/// tones, stripes and stacked bars.
class ProgressBarsScreen extends StatelessWidget {
  const ProgressBarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const percentage = [MeterSegment(value: _value, label: MeterLabel.percentage)];
    return AppPage(
      title: l10n.progressBarsPageTitle,
      description: Text(l10n.progressBarsPageDescription),
      children: [
        const CounterProgress(),
        DemoCard(
          title: l10n.progressBarsPageLabelsTitle,
          child: _Examples(
            children: [
              (
                l10n.progressBarsPageLabelsNone,
                PlainProgress(
                  value: _labelValue / _labelMax * 100,
                  label: l10n.progressBarsPageLabelsNone,
                ),
              ),
              (
                l10n.progressBarsPageLabelsValue,
                Meter(
                  label: l10n.progressBarsPageLabelsValue,
                  max: _labelMax,
                  segments: const [MeterSegment(value: _labelValue, label: MeterLabel.value)],
                ),
              ),
              (
                l10n.progressBarsPageLabelsPercentage,
                Meter(
                  label: l10n.progressBarsPageLabelsPercentage,
                  max: _labelMax,
                  segments: const [
                    MeterSegment(value: _labelValue, label: MeterLabel.percentage),
                  ],
                ),
              ),
              (
                l10n.progressBarsPageLabelsValuePrecision,
                Meter(
                  label: l10n.progressBarsPageLabelsValuePrecision,
                  max: _labelMax,
                  precision: 2,
                  segments: const [MeterSegment(value: _labelValue, label: MeterLabel.value)],
                ),
              ),
              (
                l10n.progressBarsPageLabelsPercentagePrecision,
                Meter(
                  label: l10n.progressBarsPageLabelsPercentagePrecision,
                  max: _labelMax,
                  precision: 2,
                  segments: const [
                    MeterSegment(value: _labelValue, label: MeterLabel.percentage),
                  ],
                ),
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.progressBarsPageWidthTitle,
          child: _Examples(
            children: [
              (
                l10n.progressBarsPageWidthDefault,
                PlainProgress(value: _value, label: l10n.progressBarsPageWidthDefault),
              ),
              (
                l10n.progressBarsPageWidthCustom,
                _Stack(
                  children: [
                    for (final (factor, label) in [
                      (0.75, l10n.progressBarsPageWidthThreeQuarters),
                      (0.5, l10n.progressBarsPageWidthHalf),
                      (0.25, l10n.progressBarsPageWidthQuarter),
                    ])
                      FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: factor,
                        child: PlainProgress(value: _value, label: label),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.progressBarsPageHeightTitle,
          child: _Examples(
            children: [
              (
                l10n.progressBarsPageHeightDefault,
                Meter(label: l10n.progressBarsPageHeightDefault, segments: percentage),
              ),
              (
                l10n.progressBarsPageHeightCustom,
                _Stack(
                  children: [
                    Meter(
                      label: l10n.progressBarsPageHeightLarge,
                      height: 32,
                      segments: percentage,
                    ),
                    Meter(
                      label: l10n.progressBarsPageHeightMedium,
                      height: 20,
                      segments: percentage,
                    ),
                    PlainProgress(
                      value: _value,
                      label: l10n.progressBarsPageHeightThin,
                      height: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const ColorProgress(),
        const StripedProgress(),
        const AnimatedProgress(),
        DemoCard(
          title: l10n.progressBarsPageMultipleTitle,
          description: l10n.progressBarsPageMultipleDescription,
          child: _Stack(
            gap: Space.md,
            children: [
              Meter(label: l10n.progressBarsPageMultiplePlain, segments: _stack),
              Meter(
                label: l10n.progressBarsPageMultiplePercentage,
                segments: [
                  for (final segment in _stack) segment.copyWith(label: MeterLabel.percentage),
                ],
              ),
              Meter(
                label: l10n.progressBarsPageMultipleValue,
                segments: [
                  for (final segment in _stack)
                    segment.copyWith(label: MeterLabel.value, striped: true),
                ],
              ),
              Meter(
                label: l10n.progressBarsPageMultipleMixed,
                segments: [
                  _stack[0].copyWith(label: MeterLabel.percentage),
                  _stack[1].copyWith(label: MeterLabel.percentage, animated: true),
                  _stack[2].copyWith(label: MeterLabel.percentage, striped: true),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Examples one under the other, each under its caption (the web's `form-label` `h3`).
class _Examples extends StatelessWidget {
  const _Examples({required this.children});

  final List<(String, Widget)> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, (caption, example)) in children.indexed) ...[
        if (index > 0) const SizedBox(height: Space.page),
        Semantics(header: true, child: FormLabel(caption)),
        const SizedBox(height: Space.sm),
        example,
      ],
    ],
  );
}

/// Bars in a column, [gap] apart.
class _Stack extends StatelessWidget {
  const _Stack({required this.children, this.gap = Space.sm});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, child) in children.indexed) ...[
        if (index > 0) SizedBox(height: gap),
        child,
      ],
    ],
  );
}
