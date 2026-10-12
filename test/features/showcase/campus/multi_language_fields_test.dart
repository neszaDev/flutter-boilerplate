import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/multi_language_fields.dart';
import 'package:flutter_test/flutter_test.dart';

import 'campus_test_app.dart';

Future<void> _pumpFields(WidgetTester tester, {required bool editable}) =>
    pumpCampusWidget(tester, MultiLanguageFields(editable: editable));

void main() {
  group('MultiLanguageFields', () {
    group('Editable', () {
      testWidgets('adds and removes rows and keeps the data preview in sync', (tester) async {
        final semantics = tester.ensureSemantics();
        await _pumpFields(tester, editable: true);

        expect(find.bySemanticsLabel('Language key, row 1'), findsOneWidget);
        expect(fieldText(tester, 'Language key, row 1'), 'th');

        await tester.tap(find.byTooltip('Add a language').first);
        await tester.pump();
        await tester.enterText(fieldLabelled('Language key, row 3'), 'fr');
        await tester.enterText(fieldLabelled('Text, row 3'), 'Bonjour');
        await tester.pump();

        expect(find.textContaining('"value": "Bonjour"'), findsOneWidget);

        await tester.tap(find.byTooltip('Remove row 1'));
        await tester.pump();

        expect(fieldText(tester, 'Language key, row 1'), 'en');
        expect(fieldText(tester, 'Language key, row 2'), 'fr');
        expect(fieldLabelled('Language key, row 3'), findsNothing);
        expect(find.textContaining('"key": "th"'), findsNothing);
        semantics.dispose();
      });

      testWidgets('offers an add button once every row is removed', (tester) async {
        await _pumpFields(tester, editable: true);

        await tester.tap(find.byTooltip('Remove row 2'));
        await tester.pump();
        await tester.tap(find.byTooltip('Remove row 1'));
        await tester.pump();

        expect(fieldLabelled('Language key, row 1'), findsNothing);
        await tester.tap(find.widgetWithText(OutlinedButton, 'Add a language'));
        await tester.pump();

        expect(fieldText(tester, 'Language key, row 1'), '');
      });
    });

    group('Read-only rows', () {
      testWidgets('hides the add and remove buttons', (tester) async {
        await _pumpFields(tester, editable: false);

        expect(fieldLabelled('Text, row 2'), findsOneWidget);
        expect(find.byTooltip('Remove row 1'), findsNothing);
        expect(find.byTooltip('Add a language'), findsNothing);
      });
    });
  });
}
