import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/pages/error_404_screen.dart';
import 'package:flutter_boilerplate/features/showcase/pages/error_500_screen.dart';
import 'package:flutter_boilerplate/features/showcase/pages/error_preview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

Finder get _searchField => find.byKey(const Key('errorPreview.search'));

Finder get _searchButton => find.widgetWithText(FilledButton, 'Search');

void main() {
  group('ErrorPreviewSearch', () {
    testWidgets('says that the preview searches nothing, quoting the words typed', (
      tester,
    ) async {
      await tester.pumpWidget(harness(const Scaffold(body: ErrorPreviewSearch())));

      await tester.enterText(_searchField, '  spring grades ');
      await tester.tap(_searchButton);
      await tester.pump();

      expect(
        find.text('This is a preview: nothing was searched for “spring grades”.'),
        findsOneWidget,
      );
    });

    testWidgets('searches from the keyboard too', (tester) async {
      await tester.pumpWidget(harness(const Scaffold(body: ErrorPreviewSearch())));

      await tester.enterText(_searchField, 'marks');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(find.text('This is a preview: nothing was searched for “marks”.'), findsOneWidget);
    });

    testWidgets('asks for words first when the box is empty', (tester) async {
      await tester.pumpWidget(harness(const Scaffold(body: ErrorPreviewSearch())));

      await tester.enterText(_searchField, '   ');
      await tester.tap(_searchButton);
      await tester.pump();

      expect(find.text('Type what you are looking for first.'), findsOneWidget);
    });

    testWidgets('names the search box for screen readers', (tester) async {
      await tester.pumpWidget(harness(const Scaffold(body: ErrorPreviewSearch())));

      expect(find.bySemanticsLabel(RegExp('^Search')), findsWidgets);
    });
  });

  group('Error404Screen', () {
    testWidgets('previews the not-found page with its code and search box', (tester) async {
      usePhoneSize(tester, height: 1600);
      await tester.pumpWidget(harness(const Error404Screen()));
      await tester.pumpAndSettle();

      expect(find.text('404'), findsOneWidget);
      expect(find.text("You're lost."), findsOneWidget);
      expect(find.byType(ErrorPreviewSearch), findsOneWidget);
      expect(find.text('Back to the overview'), findsOneWidget);
    });

    testWidgets('renders in both themes and languages', (tester) async {
      await expectRendersEverywhere(tester, const Error404Screen());
    });
  });

  group('Error500Screen', () {
    testWidgets('tries again and says the preview still fails', (tester) async {
      usePhoneSize(tester, height: 1600);
      await tester.pumpWidget(harness(const Error500Screen()));

      expect(find.text('500'), findsOneWidget);
      expect(find.text('Tried again: this preview always fails.'), findsNothing);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Tried again: this preview always fails.'), findsOneWidget);
    });

    testWidgets('renders in both themes and languages', (tester) async {
      await expectRendersEverywhere(tester, const Error500Screen());
    });
  });
}
