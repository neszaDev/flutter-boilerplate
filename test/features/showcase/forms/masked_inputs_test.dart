import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/forms/masked_inputs.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump.dart';

Finder _input(MaskField field) => find.descendant(
  of: find.byKey(ValueKey('masked-${field.name}')),
  matching: find.byType(TextField),
);

String _text(WidgetTester tester, MaskField field) =>
    tester.widget<TextField>(_input(field)).controller!.text;

void main() {
  group('maskDisplay', () {
    test('adds the rest of the guide after the typed text', () {
      final date = maskSpecs[MaskField.date]!;

      expect(date.guide, '__/__/____');
      expect(maskDisplay(date, '', showGuide: true), '__/__/____');
      expect(maskDisplay(date, '12', showGuide: true), '12/__/____');
      expect(maskDisplay(date, '12', showGuide: false), '12');
    });
  });

  group('MaskedInputs', () {
    testWidgets('formats digits into the phone pattern', (tester) async {
      await pumpDemo(tester, const MaskedInputs());

      await tester.enterText(_input(MaskField.phone), '2125550142');

      expect(_text(tester, MaskField.phone), '(212) 555-0142');
    });

    testWidgets('shows the date guide and refuses a day starting with 4', (tester) async {
      await pumpDemo(tester, const MaskedInputs());

      expect(find.text('__/__/____'), findsOneWidget);

      await tester.enterText(_input(MaskField.date), '4');
      await tester.pump();

      expect(_text(tester, MaskField.date), isEmpty);
      expect(find.text('__/__/____'), findsOneWidget);

      await tester.enterText(_input(MaskField.date), '12');
      await tester.pump();

      expect(_text(tester, MaskField.date), '12');
      expect(find.text('12/__/____'), findsOneWidget);
    });

    testWidgets('drops letters typed into the card number', (tester) async {
      await pumpDemo(tester, const MaskedInputs());

      await tester.enterText(_input(MaskField.cardNumber), '4242abc4242');
      await tester.pump();

      expect(_text(tester, MaskField.cardNumber), '4242 4242');
      expect(find.text('4242 4242 #### ####'), findsOneWidget);
    });

    testWidgets('names each field and its example for screen readers', (tester) async {
      await pumpDemo(tester, const MaskedInputs());

      expect(find.bySemanticsLabel(en.advancedFormsPageMaskPhone), findsOneWidget);
    });
  });
}
