import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_meter.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_secondary_button.dart';

/// Bars stacked in a column, a little apart (the web's `flex flex-col gap-2`).
class _Bars extends StatelessWidget {
  const _Bars({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, child) in children.indexed) ...[
        if (index > 0) const SizedBox(height: Space.sm),
        child,
      ],
    ],
  );
}

/// The first Vue progress card: an animated bar and a stacked bar that both follow one counter,
/// and a button that sets the counter to a random value.
class CounterProgress extends StatefulWidget {
  const CounterProgress({this.random, super.key});

  /// Where new counter values come from (seeded in tests).
  final math.Random? random;

  @override
  State<CounterProgress> createState() => _CounterProgressState();
}

class _CounterProgressState extends State<CounterProgress> {
  late final _random = widget.random ?? math.Random();
  double _counter = 73;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.progressBarsPageCounterTitle,
      description: l10n.progressBarsPageCounterDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bars(
            children: [
              Meter(
                label: l10n.progressBarsPageCounterTitle,
                segments: [
                  MeterSegment(value: _counter, label: MeterLabel.percentage, animated: true),
                ],
              ),
              Meter(
                label: l10n.progressBarsPageCounterStacked,
                segments: [
                  MeterSegment(
                    value: _counter * 0.6,
                    tone: MeterTone.pass,
                    label: MeterLabel.value,
                  ),
                  MeterSegment(
                    value: _counter * 0.25,
                    tone: MeterTone.pencil,
                    label: MeterLabel.value,
                  ),
                  MeterSegment(
                    value: _counter * 0.15,
                    tone: MeterTone.pen,
                    label: MeterLabel.value,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Space.card),
          SecondaryButton(
            onPressed: () => setState(() => _counter = _random.nextDouble() * 100),
            child: Text(l10n.progressBarsPageCounterButton),
          ),
        ],
      ),
    );
  }
}

const _colorTones = [
  MeterTone.pass,
  MeterTone.deep,
  MeterTone.pencil,
  MeterTone.pen,
  MeterTone.folder,
  MeterTone.ink,
  MeterTone.dark,
];

/// The name of a tone (the web's `BaseTones` namespace).
String _toneName(AppLocalizations l10n, MeterTone tone) => switch (tone) {
  MeterTone.folder => l10n.baseTonesFolder,
  MeterTone.ink => l10n.baseTonesInk,
  MeterTone.pass => l10n.baseTonesPass,
  MeterTone.pencil => l10n.baseTonesPencil,
  MeterTone.deep => l10n.baseTonesDeep,
  MeterTone.pen => l10n.baseTonesPen,
  MeterTone.light => l10n.baseTonesLight,
  MeterTone.dark => l10n.baseTonesDark,
};

/// Bars in every tone; their values change every two seconds, as in the Vue demo.
class ColorProgress extends StatefulWidget {
  const ColorProgress({super.key});

  @override
  State<ColorProgress> createState() => _ColorProgressState();
}

class _ColorProgressState extends State<ColorProgress> {
  final _random = math.Random();
  List<double> _values = [for (final _ in _colorTones) 75];
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() => _values = [for (final _ in _colorTones) 25 + _random.nextDouble() * 75]);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // The name is printed for sighted users; the bar carries it for screen readers.
  Widget _name(AppLocalizations l10n, MeterTone tone, TextStyle? style) =>
      ExcludeSemantics(child: Text(_toneName(l10n, tone), style: style));

  Widget _meter(AppLocalizations l10n, MeterTone tone, double value) => Meter(
    label: _toneName(l10n, tone),
    segments: [MeterSegment(value: value, tone: tone)],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nameStyle = context.text.bodySmall?.copyWith(color: context.colors.ink700);
    return DemoCard(
      title: l10n.progressBarsPageColorsTitle,
      description: l10n.progressBarsPageColorsDescription,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // A name column beside the bars when there is room, else each name above its bar.
          final wide = constraints.maxWidth >= 480;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, tone) in _colorTones.indexed) ...[
                if (index > 0) SizedBox(height: wide ? Space.sm : Space.md),
                if (wide)
                  Row(
                    children: [
                      SizedBox(width: 160, child: _name(l10n, tone, nameStyle)),
                      const SizedBox(width: Space.page),
                      Expanded(child: _meter(l10n, tone, _values[index])),
                    ],
                  )
                else ...[
                  _name(l10n, tone, nameStyle),
                  const SizedBox(height: Space.xs),
                  _meter(l10n, tone, _values[index]),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

const _stripedBars = [
  MeterSegment(value: 25, tone: MeterTone.pass),
  MeterSegment(value: 50, tone: MeterTone.deep),
  MeterSegment(value: 75, tone: MeterTone.pencil),
  MeterSegment(value: 100, tone: MeterTone.pen),
];

/// Four bars with stripes that a button adds or removes.
class StripedProgress extends StatefulWidget {
  const StripedProgress({super.key});

  @override
  State<StripedProgress> createState() => _StripedProgressState();
}

class _StripedProgressState extends State<StripedProgress> {
  bool _striped = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.progressBarsPageStripedTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bars(
            children: [
              for (final bar in _stripedBars)
                Meter(
                  label: l10n.progressBarsPageBarLabel(bar.value.toStringAsFixed(0)),
                  segments: [bar.copyWith(striped: _striped)],
                ),
            ],
          ),
          const SizedBox(height: Space.card),
          SecondaryButton(
            onPressed: () => setState(() => _striped = !_striped),
            child: Text(
              _striped ? l10n.progressBarsPageStripedRemove : l10n.progressBarsPageStripedAdd,
            ),
          ),
        ],
      ),
    );
  }
}

/// Four striped bars whose stripes move until a button stops them.
class AnimatedProgress extends StatefulWidget {
  const AnimatedProgress({super.key});

  @override
  State<AnimatedProgress> createState() => _AnimatedProgressState();
}

class _AnimatedProgressState extends State<AnimatedProgress> {
  bool _animated = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.progressBarsPageAnimatedTitle,
      description: l10n.progressBarsPageAnimatedDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bars(
            children: [
              for (final bar in _stripedBars)
                Meter(
                  label: l10n.progressBarsPageBarLabel(bar.value.toStringAsFixed(0)),
                  segments: [bar.copyWith(striped: true, animated: _animated)],
                ),
            ],
          ),
          const SizedBox(height: Space.card),
          SecondaryButton(
            onPressed: () => setState(() => _animated = !_animated),
            child: Text(
              _animated ? l10n.progressBarsPageAnimatedStop : l10n.progressBarsPageAnimatedStart,
            ),
          ),
        ],
      ),
    );
  }
}
