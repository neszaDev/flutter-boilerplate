import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/forms/sign_up_validation_form.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump.dart';

Finder _field(String name) => find.byKey(ValueKey('signup.$name'));

Finder _button(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
);

bool _enabled(WidgetTester tester, String label) =>
    tester.widget<ButtonStyleButton>(_button(label)).onPressed != null;

String? _error(WidgetTester tester, String name) => tester
    .widget<InputDecorator>(
      find.descendant(of: _field(name), matching: find.byType(InputDecorator)),
    )
    .decoration
    .errorText;

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(_field('firstName'), 'Ada');
  await tester.enterText(_field('lastName'), 'Lovelace');
  await tester.enterText(_field('userName'), 'adalove');
  await tester.enterText(_field('email'), 'ada@example.com');
  await tester.enterText(_field('password'), 'Report1card');
  await tester.enterText(_field('confirmPassword'), 'Report1card');
  await tester.ensureVisible(_field('accept'));
  await tester.tap(_field('accept'));
  await tester.pumpAndSettle();
}

void main() {
  group('SignUpValidationForm', () {
    group('while editing', () {
      testWidgets('shows a field error only once that field is edited', (tester) async {
        await pumpDemo(tester, const SignUpValidationForm());

        expect(find.text(en.validationMin3Characters), findsNothing);

        await tester.enterText(_field('firstName'), 'Al');
        await tester.pump();

        expect(find.text(en.validationMin3Characters), findsOneWidget);
        expect(_error(tester, 'lastName'), isNull);
      });

      testWidgets('flags a confirmation that stops matching the password', (tester) async {
        await pumpDemo(tester, const SignUpValidationForm());

        await tester.enterText(_field('password'), 'Report1card');
        await tester.enterText(_field('confirmPassword'), 'Report1card');
        await tester.enterText(_field('password'), 'Report2card');
        await tester.pump();

        expect(find.text(en.validationPasswordsMustMatch), findsOneWidget);
      });
    });

    group('Validate button', () {
      testWidgets('reveals every rule the empty form breaks', (tester) async {
        await pumpDemo(tester, const SignUpValidationForm());

        await tester.ensureVisible(_button(en.validationFormsPageValidate));
        await tester.tap(_button(en.validationFormsPageValidate));
        await tester.pump();

        expect(find.text(en.validationAcceptTerms), findsOneWidget);
        expect(_error(tester, 'firstName'), en.validationRequired);
      });
    });

    group('submitting', () {
      testWidgets('enables submit only for a valid form, then marks the values submitted', (
        tester,
      ) async {
        await pumpDemo(tester, const SignUpValidationForm());

        expect(_enabled(tester, en.validationFormsPageSubmit), isFalse);

        await _fillValidForm(tester);
        expect(_enabled(tester, en.validationFormsPageSubmit), isTrue);
        await tester.ensureVisible(_button(en.validationFormsPageSubmit));
        await tester.tap(_button(en.validationFormsPageSubmit));
        await tester.pumpAndSettle();

        expect(find.text(en.validationFormsPageValuesSubmitted.toUpperCase()), findsOneWidget);
        expect(find.textContaining('"firstName": "Ada"'), findsOneWidget);
        expect(_enabled(tester, en.validationFormsPageSubmit), isFalse);
      });

      testWidgets('resets the form to empty values', (tester) async {
        await pumpDemo(tester, const SignUpValidationForm());
        await _fillValidForm(tester);

        await tester.ensureVisible(_button(en.validationFormsPageReset));
        await tester.tap(_button(en.validationFormsPageReset));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<TextField>(
                find.descendant(
                  of: _field('firstName'),
                  matching: find.byType(TextField),
                ),
              )
              .controller!
              .text,
          isEmpty,
        );
        expect(_enabled(tester, en.validationFormsPageReset), isFalse);
        expect(find.text(en.validationFormsPageValuesTitle.toUpperCase()), findsOneWidget);
      });
    });
  });
}
