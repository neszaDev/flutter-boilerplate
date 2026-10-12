import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/forms/validated_input.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump.dart';

void main() {
  group('passesRule', () {
    test('accepts anything when optional and rejects blanks when required', () {
      expect(passesRule('', InputRule.optional), isTrue);
      expect(passesRule('  ', InputRule.required), isFalse);
    });

    test('checks the length and email rules', () {
      expect(passesRule('abc', InputRule.minLength4), isFalse);
      expect(passesRule('abcd', InputRule.minLength4), isTrue);
      expect(passesRule('ada@example', InputRule.email), isFalse);
      expect(passesRule('ada@example.com', InputRule.email), isTrue);
    });
  });

  group('ValidatedInput', () {
    testWidgets('switches from the invalid to the valid feedback as you type', (tester) async {
      await pumpDemo(
        tester,
        const ValidatedInput(
          label: 'Nickname',
          rule: InputRule.minLength4,
          validFeedback: 'Looks good',
          invalidFeedback: 'Too short',
        ),
      );
      InputDecoration decoration() =>
          tester.widget<InputDecorator>(find.byType(InputDecorator)).decoration;

      expect(find.text('Too short'), findsOneWidget);
      expect(decoration().errorText, 'Too short');

      await tester.enterText(find.bySemanticsLabel('Nickname'), 'Robin');
      await tester.pumpAndSettle();

      expect(find.text('Looks good'), findsOneWidget);
      expect(find.text('Too short'), findsNothing);
      expect(decoration().errorText, isNull);
    });

    testWidgets('starts valid with a valid initial value', (tester) async {
      await pumpDemo(
        tester,
        const ValidatedInput(
          label: 'Code',
          rule: InputRule.minLength4,
          initialValue: 'Valid value',
          validFeedback: 'Input is valid.',
          invalidFeedback: 'Please provide at least 4 characters.',
        ),
      );

      expect(find.text('Input is valid.'), findsOneWidget);
    });
  });
}
