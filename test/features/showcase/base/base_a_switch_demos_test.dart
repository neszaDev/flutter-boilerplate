import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_data.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_switch_demos.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_switch.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_a_harness.dart';

/// The switch named [label] (badges may carry the same words).
Finder _switch(String label) =>
    find.byWidgetPredicate((widget) => widget is ToneSwitch && widget.label == label);

void main() {
  group('RadioSwitches', () {
    testWidgets('starts with the pencil switch on and names it in the badge', (tester) async {
      await pumpBase(tester, const RadioSwitches());

      expect(
        tester.getSemantics(_switch('Graphite pencil')),
        isSemantics(isInMutuallyExclusiveGroup: true, hasCheckedState: true, isChecked: true),
      );
      expect(find.text('GRAPHITE PENCIL'), findsOneWidget);
    });

    testWidgets('turns the others off when another switch is turned on', (tester) async {
      await pumpBase(tester, const RadioSwitches());

      await tester.tap(_switch('Pass green'));
      await tester.pump();

      expect(tester.getSemantics(_switch('Pass green')), isSemantics(isChecked: true));
      expect(tester.getSemantics(_switch('Graphite pencil')), isSemantics(isChecked: false));
      final checked = [
        for (final tone in Tone.values)
          if (isSemantics(isChecked: true)
              .matches(tester.getSemantics(_switch(_toneLabels[tone]!)), {}))
            tone,
      ];
      expect(checked, [Tone.pass]);
      expect(find.text('PASS GREEN'), findsOneWidget);
    });

    testWidgets('keeps the chosen switch on when it is tapped again', (tester) async {
      await pumpBase(tester, const RadioSwitches());

      await tester.tap(_switch('Graphite pencil'));
      await tester.pump();

      expect(tester.getSemantics(_switch('Graphite pencil')), isSemantics(isChecked: true));
    });
  });

  group('DefaultSwitches', () {
    testWidgets('shows the first switch state in the badge', (tester) async {
      await pumpBase(tester, const DefaultSwitches());

      expect(find.text('ON'), findsOneWidget);
      expect(tester.getSemantics(_switch('Folder green')), isSemantics(isToggled: true));

      await tester.tap(_switch('Folder green'));
      await tester.pump();

      expect(find.text('OFF'), findsOneWidget);
      expect(tester.getSemantics(_switch('Folder green')), isSemantics(isToggled: false));
      expect(
        tester.getSemantics(_switch('Disabled switch')),
        isSemantics(hasEnabledState: true, isEnabled: false),
      );
    });
  });

  group('ToneSwitch', () {
    testWidgets('keeps its own state when uncontrolled and ignores taps when disabled', (
      tester,
    ) async {
      await pumpBase(
        tester,
        const Row(
          children: [
            ToneSwitch(tone: Tone.pass, label: 'Free'),
            ToneSwitch(tone: Tone.pass, label: 'Locked', initialValue: true, enabled: false),
          ],
        ),
      );

      await tester.tap(_switch('Free'));
      await tester.pump();
      await tester.tap(_switch('Locked'));
      await tester.pump();

      expect(tester.getSemantics(_switch('Free')), isSemantics(isToggled: true));
      expect(tester.getSemantics(_switch('Locked')), isSemantics(isToggled: true));
    });

    testWidgets('offers a tap target of at least 44 points in every size', (tester) async {
      await pumpBase(
        tester,
        Column(
          children: [
            for (final size in ToneSwitchSize.values)
              ToneSwitch(tone: Tone.folder, label: size.name, size: size),
          ],
        ),
      );

      for (final size in ToneSwitchSize.values) {
        final box = tester.getSize(_switch(size.name));
        expect(box.width, greaterThanOrEqualTo(44));
        expect(box.height, greaterThanOrEqualTo(44));
      }
    });
  });
}

const _toneLabels = {
  Tone.folder: 'Folder green',
  Tone.ink: 'Form ink',
  Tone.pass: 'Pass green',
  Tone.pencil: 'Graphite pencil',
  Tone.deep: 'Folder deep',
  Tone.pen: 'Red pen',
  Tone.light: 'Light rule',
  Tone.dark: 'Dark ink',
};
