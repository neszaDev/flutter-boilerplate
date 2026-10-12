import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_badge.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_data.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_colors.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_switch.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// The Vue "labelIcon" pair: a tick for on, a cross for off.
const _iconOn = Icon(LucideIcons.check600);
const _iconOff = Icon(LucideIcons.x600);

/// A wrapping row of switches, the way every switch card lays them out.
class _SwitchWrap extends StatelessWidget {
  const _SwitchWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: Space.xs, crossAxisAlignment: WrapCrossAlignment.center, children: children);
}

/// One switch per tone, all checked, then a disabled unchecked one: the row every switch card
/// repeats in a different [style].
class SwitchRow extends StatelessWidget {
  const SwitchRow({required this.style, super.key});

  final SwitchRowStyle style;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    (Widget?, Widget?) labelsFor(int index) => switch (style.labels) {
      null => (null, null),
      SwitchRowLabels.textFirst when index == 0 => (
        Text(l10n.switchesPageLabelYes.toUpperCase()),
        Text(l10n.switchesPageLabelNo.toUpperCase()),
      ),
      _ => (_iconOn, _iconOff),
    };

    ToneSwitch toneSwitch(Tone tone, int index, {required String label, required bool on}) {
      final (labelOn, labelOff) = labelsFor(index);
      return ToneSwitch(
        tone: tone,
        variant: style.variant,
        shape: style.shape,
        initialValue: on,
        enabled: on && !style.disabled,
        label: label,
        labelOn: labelOn,
        labelOff: labelOff,
      );
    }

    return _SwitchWrap(
      children: [
        for (final (index, tone) in Tone.values.indexed)
          toneSwitch(tone, index, label: tone.label(l10n), on: true),
        toneSwitch(
          Tone.folder,
          Tone.values.length,
          label: l10n.switchesPageDisabledSwitch,
          on: false,
        ),
      ],
    );
  }
}

/// 3D switches that behave as one radio group: turning one on turns the others off, and the
/// badge in the header names the chosen tone.
class RadioSwitches extends StatefulWidget {
  const RadioSwitches({super.key});

  @override
  State<RadioSwitches> createState() => _RadioSwitchesState();
}

class _RadioSwitchesState extends State<RadioSwitches> {
  Tone _chosen = radioSwitchInitial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.switchesPageRadioTitle,
      description: l10n.switchesPageRadioDescription,
      action: Padding(
        padding: const EdgeInsets.only(top: Space.xs, right: Space.md),
        child: ToneBadge(_chosen.label(l10n), tone: _chosen),
      ),
      child: Semantics(
        container: true,
        role: SemanticsRole.radioGroup,
        label: l10n.switchesPageRadioTitle,
        explicitChildNodes: true,
        child: _SwitchWrap(
          children: [
            for (final tone in radioSwitchTones)
              ToneSwitch(
                asRadio: true,
                tone: tone,
                variant: ToneSwitchVariant.threeD,
                value: _chosen == tone,
                onChanged: (checked) {
                  if (checked) {
                    setState(() => _chosen = tone);
                  }
                },
                labelOn: _iconOn,
                labelOff: _iconOff,
                label: tone.label(l10n),
              ),
          ],
        ),
      ),
    );
  }
}

/// The default switches: the first one is bound to the badge in the header, the rest show every
/// tone checked, and the last is disabled.
class DefaultSwitches extends StatefulWidget {
  const DefaultSwitches({super.key});

  @override
  State<DefaultSwitches> createState() => _DefaultSwitchesState();
}

class _DefaultSwitchesState extends State<DefaultSwitches> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.switchesPageDefaultTitle,
      description: l10n.switchesPageDefaultDescription,
      action: Padding(
        padding: const EdgeInsets.only(top: Space.xs, right: Space.md),
        child: ToneBadge(_on ? l10n.switchesPageStateOn : l10n.switchesPageStateOff),
      ),
      child: _SwitchWrap(
        children: [
          ToneSwitch(
            tone: Tone.folder,
            value: _on,
            onChanged: (value) => setState(() => _on = value),
            label: Tone.folder.label(l10n),
          ),
          for (final tone in Tone.values.skip(1))
            ToneSwitch(tone: tone, initialValue: true, label: tone.label(l10n)),
          ToneSwitch(tone: Tone.folder, enabled: false, label: l10n.switchesPageDisabledSwitch),
        ],
      ),
    );
  }
}
