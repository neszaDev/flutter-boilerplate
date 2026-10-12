import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/notifications/modals_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

Future<void> _pumpModals(WidgetTester tester, {Locale locale = const Locale('en')}) async {
  usePhoneSize(tester, height: 1600);
  await tester.pumpWidget(harness(const ModalsScreen(), locale: locale));
}

Future<void> _open(WidgetTester tester, String launch) async {
  await tester.tap(find.text(launch));
  await tester.pumpAndSettle();
}

void main() {
  group('ModalsScreen', () {
    testWidgets('opens every centred modal and closes it again', (tester) async {
      await _pumpModals(tester);
      final modals = {
        'Launch demo modal': 'Spring term report',
        'Launch large modal': 'Spring term report',
        'Launch small modal': 'Spring term report',
        'Launch scrollable modal': 'Marking guide',
        'Launch primary modal': 'Spring term report',
        'Launch pending modal': 'Some results are pending',
        'Launch info modal': 'About report cards',
      };

      for (final MapEntry(key: launch, value: title) in modals.entries) {
        await _open(tester, launch);
        expect(find.byType(Dialog), findsOneWidget, reason: launch);
        expect(find.text(title), findsOneWidget, reason: launch);

        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing, reason: launch);
      }
    });

    testWidgets('closes the success modal with its own button', (tester) async {
      await _pumpModals(tester);

      await _open(tester, 'Launch success modal');
      expect(find.text('Families can now see the spring term report.'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('keeps the custom modal open on a tap outside', (tester) async {
      await _pumpModals(tester);

      await _open(tester, 'Launch custom modal');
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('Publish the report?'), findsOneWidget);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.text('Publish the report?'), findsNothing);
    });

    testWidgets('closes the other modals on a tap outside', (tester) async {
      await _pumpModals(tester);

      await _open(tester, 'Launch demo modal');
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('asks before deleting', (tester) async {
      await _pumpModals(tester);

      await _open(tester, 'Launch destructive modal');
      expect(find.text('Delete this result?'), findsOneWidget);

      await tester.tap(find.text('Keep result'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this result?'), findsNothing);
    });

    testWidgets('opens the full-screen modal with Close and Save in its bar', (tester) async {
      await _pumpModals(tester);

      await _open(tester, 'Launch full-screen modal');
      expect(find.widgetWithText(TextButton, 'Save changes'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Save changes'), findsNothing);
    });

    testWidgets('opens both bottom sheets', (tester) async {
      await _pumpModals(tester);

      await _open(tester, 'Open a bottom sheet');
      expect(find.byType(BottomSheet), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);

      await _open(tester, 'Open a draggable sheet');
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('Marking guide'), findsOneWidget);
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byType(DraggableScrollableSheet), findsNothing);
    });

    testWidgets('fits the small modal on a narrow phone in French', (tester) async {
      await _pumpModals(tester, locale: const Locale('fr'));

      await _open(tester, 'Ouvrir une petite modale');

      expect(tester.takeException(), isNull);
      expect(find.text('Enregistrer'), findsOneWidget);
    });

    testWidgets('renders in both themes and languages', (tester) async {
      await expectRendersEverywhere(tester, const ModalsScreen());
    });
  });
}
