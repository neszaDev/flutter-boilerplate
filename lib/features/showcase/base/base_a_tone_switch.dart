import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_data.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_colors.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';

/// Track and knob metrics of one [ToneSwitchSize] (CoreUI's switch): the knob sits 2 pt inside
/// the 1 pt border, or covers the full height for the 3D variant.
typedef _Metrics = ({
  double height,
  double width,
  double labelledWidth,
  double thumb,
  double thumb3d,
  double shift,
  double labelShift,
  double font,
});

const Map<ToneSwitchSize, _Metrics> _metrics = {
  ToneSwitchSize.sm: (
    height: 22,
    width: 32,
    labelledWidth: 40,
    thumb: 16,
    thumb3d: 22,
    shift: 10,
    labelShift: 18,
    font: 8,
  ),
  ToneSwitchSize.md: (
    height: 26,
    width: 40,
    labelledWidth: 48,
    thumb: 20,
    thumb3d: 26,
    shift: 14,
    labelShift: 22,
    font: 10,
  ),
  ToneSwitchSize.lg: (
    height: 30,
    width: 48,
    labelledWidth: 56,
    thumb: 24,
    thumb3d: 30,
    shift: 18,
    labelShift: 26,
    font: 12,
  ),
};

/// The smallest tap target around a switch.
const _minTarget = 44.0;

/// A switch in one of the showcase tones, with the CoreUI variants: filled, outline, opposite
/// (outline with a filled knob) and 3D, three shapes, three sizes and optional on/off labels.
///
/// Controlled when [value] is set, otherwise it keeps its own state from [initialValue].
/// Announced as a switch, or as a radio button when [asRadio] is set inside a radio group.
class ToneSwitch extends StatefulWidget {
  const ToneSwitch({
    required this.tone,
    required this.label,
    this.variant = ToneSwitchVariant.filled,
    this.shape = ToneSwitchShape.rounded,
    this.size = ToneSwitchSize.md,
    this.labelOn,
    this.labelOff,
    this.value,
    this.initialValue = false,
    this.onChanged,
    this.enabled = true,
    this.asRadio = false,
    super.key,
  });

  /// Colour when checked.
  final Tone tone;

  /// Accessible name.
  final String label;
  final ToneSwitchVariant variant;

  /// Corner shape (3D switches are always pills).
  final ToneSwitchShape shape;
  final ToneSwitchSize size;

  /// Shown inside the track when checked (a short upper-case word or an icon).
  final Widget? labelOn;

  /// Shown inside the track when unchecked.
  final Widget? labelOff;

  /// The checked state when controlled.
  final bool? value;

  /// The first checked state when uncontrolled.
  final bool initialValue;

  /// Called with the new state.
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  /// Announces the switch as a radio button, for a group where only one is on.
  final bool asRadio;

  @override
  State<ToneSwitch> createState() => _ToneSwitchState();
}

class _ToneSwitchState extends State<ToneSwitch> {
  late bool _own = widget.initialValue;
  bool _focused = false;

  bool get _checked => widget.value ?? _own;

  void _toggle() {
    if (!widget.enabled) {
      return;
    }
    final next = !_checked;
    Haptics.selection();
    if (widget.value == null) {
      setState(() => _own = next);
    }
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final tone = ToneColors.of(context, widget.tone);
    final light = widget.tone == Tone.light;
    final m = _metrics[widget.size]!;
    final is3d = widget.variant == ToneSwitchVariant.threeD;
    final labelled = widget.labelOn != null || widget.labelOff != null;
    final filledTrack = widget.variant == ToneSwitchVariant.filled || is3d;
    final checked = _checked;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 150);

    // The light tone draws a darker rim than its fill so it shows on white.
    final toneRim = light ? colors.ink400 : tone.ink;
    final toneTrack = light ? colors.ink200 : tone.ink;
    final toneKnob = light ? colors.ink300 : tone.ink;

    final width = labelled ? m.labelledWidth : m.width;
    final shape = is3d ? ToneSwitchShape.pill : widget.shape;
    final (trackRadius, thumbRadius) = switch (shape) {
      ToneSwitchShape.rounded => (Radii.md, Radii.sm),
      ToneSwitchShape.square => (0.0, 0.0),
      ToneSwitchShape.pill => (999.0, 999.0),
    };

    final trackColor = checked && filledTrack ? toneTrack : (is3d ? colors.ink100 : colors.ply);
    final trackBorder = checked ? toneRim : (is3d ? colors.ink200 : colors.ink300);
    final knobSize = is3d ? m.thumb3d : m.thumb;
    final knobInset = is3d ? 0.0 : 3.0;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final knobColor = checked && widget.variant == ToneSwitchVariant.opposite
        ? toneKnob
        // By night the raised 3D knob is lit, like a Material switch thumb.
        : (is3d && dark ? colors.ink700 : colors.ply);
    final knobBorder = checked && !is3d ? toneRim : colors.ink200;
    final labelColor = !checked
        ? colors.ink400
        : filledTrack
        ? tone.onInk
        : (light ? colors.ink600 : tone.ink);

    final track = SizedBox(
      width: width,
      height: m.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: trackColor,
                border: Border.all(color: trackBorder),
                borderRadius: BorderRadius.circular(trackRadius),
                boxShadow: is3d ? null : plyShadow(context),
              ),
            ),
          ),
          if (labelled)
            Positioned(
              top: 0,
              bottom: 0,
              left: checked ? 1 : null,
              right: checked ? null : 1,
              width: width / 2,
              child: Center(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: m.font,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: labelColor,
                  ),
                  child: IconTheme(
                    data: IconThemeData(size: m.font + 2, color: labelColor),
                    child: (checked ? widget.labelOn : widget.labelOff) ?? const SizedBox(),
                  ),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: duration,
            curve: Curves.easeOut,
            top: knobInset,
            left: knobInset + (checked ? (labelled ? m.labelShift : m.shift) : 0),
            width: knobSize,
            height: knobSize,
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: knobColor,
                border: is3d ? null : Border.all(color: knobBorder),
                borderRadius: BorderRadius.circular(thumbRadius),
                boxShadow: is3d ? sheetShadow(context) : null,
              ),
            ),
          ),
          if (_focused)
            Positioned(
              left: -3,
              top: -3,
              right: -3,
              bottom: -3,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(trackRadius + 3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Semantics(
      container: true,
      enabled: widget.enabled,
      toggled: widget.asRadio ? null : checked,
      checked: widget.asRadio ? checked : null,
      inMutuallyExclusiveGroup: widget.asRadio ? true : null,
      label: widget.label,
      onTap: widget.enabled ? _toggle : null,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: widget.enabled,
          mouseCursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
          onShowFocusHighlight: (value) => setState(() => _focused = value),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _toggle();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? _toggle : null,
            child: SizedBox(
              width: math.max(_minTarget, width),
              height: math.max(_minTarget, m.height),
              child: Center(
                child: Opacity(opacity: widget.enabled ? 1 : 0.5, child: track),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
