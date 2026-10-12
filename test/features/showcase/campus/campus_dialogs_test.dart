import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/campus_dialogs.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/loading_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

import 'campus_test_app.dart';

const _unavailable =
    'Two-factor sign-in is not available yet. The server cannot send or check codes for now.';

Future<void> _openTwoFactor(WidgetTester tester) async {
  await pumpCampusWidget(tester, const CampusDialogs(email: 'student@mfu.ac.th'));
  await tester.tap(find.text('Two-factor code'));
  await tester.pumpAndSettle();
}

/// Types [code] into the code field; a complete code is sent right away.
Future<void> _type(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(TextField), code);
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  group('CampusDialogs two-factor step', () {
    testWidgets('shows where the code went, labelled for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await _openTwoFactor(tester);

      expect(find.text('Confirm it is you'), findsOneWidget);
      expect(find.text('Email: student@mfu.ac.th'), findsOneWidget);
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.bySemanticsLabel('Two-factor code'),
          ),
        ),
        isSemantics(label: 'Two-factor code', isTextField: true),
      );
      semantics.dispose();
    });

    testWidgets('reports a complete code as not available yet, and retries', (tester) async {
      await _openTwoFactor(tester);

      await _type(tester, 'A1b2C3');

      expect(find.byType(LoadingOverlay), findsNothing);
      expect(find.text(_unavailable), findsOneWidget);
      expect(find.text('# 1-50100'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text(_unavailable), findsNothing);
      expect(find.text('Confirm it is you'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, isEmpty);
      expect(find.text('Last button pressed: retry'), findsOneWidget);
    });

    testWidgets('closes both dialogs on cancel', (tester) async {
      await _openTwoFactor(tester);
      await _type(tester, 'ZZ9999');

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm it is you'), findsNothing);
      expect(find.text('Last button pressed: cancel'), findsOneWidget);
    });

    testWidgets('keeps out symbols and asks for every character', (tester) async {
      await _openTwoFactor(tester);

      await _type(tester, '12-45');
      expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, '1245');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Enter all 6 characters.'), findsOneWidget);
      expect(find.text(_unavailable), findsNothing);
    });

    testWidgets('says a new code cannot be sent yet', (tester) async {
      await _openTwoFactor(tester);

      await tester.tap(find.text('Send a new code'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text(_unavailable), findsOneWidget);
    });
  });

  group('CampusDialogs', () {
    testWidgets('shows the sample error and remembers the pressed button', (tester) async {
      await pumpCampusWidget(tester, const CampusDialogs(email: 'student@mfu.ac.th'));

      await tester.tap(find.text('Error message'));
      await tester.pumpAndSettle();
      expect(find.text('The email or password is incorrect.'), findsOneWidget);
      expect(find.text('# 1-40100'), findsOneWidget);

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Last button pressed: submit'), findsOneWidget);
    });

    testWidgets('shows the loading overlay for two seconds', (tester) async {
      await pumpCampusWidget(tester, const CampusDialogs(email: 'student@mfu.ac.th'));

      await tester.tap(find.text('Loading overlay'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LoadingOverlay), findsOneWidget);

      await tester.pump(loadingDemoDuration);
      await tester.pumpAndSettle();
      expect(find.byType(LoadingOverlay), findsNothing);
    });

    testWidgets('opens the sign-in help with its contacts', (tester) async {
      await pumpCampusWidget(tester, const CampusDialogs(email: 'student@mfu.ac.th'));

      await tester.tap(find.text('Sign-in help'));
      await tester.pumpAndSettle();
      expect(find.text('Help with signing in'), findsOneWidget);
      expect(find.text('Personnel division, phone 0-5391-6494, 6053'), findsOneWidget);
      expect(find.text('personnel@mfu.ac.th'), findsOneWidget);
      expect(find.text('Thai version'), findsNWidgets(2));

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Help with signing in'), findsNothing);
    });
  });
}
