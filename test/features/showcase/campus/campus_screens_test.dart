import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_content_screen.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_filters_screen.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_qr_code_screen.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_screen.dart';
import 'package:flutter_boilerplate/features/showcase/campus/filters.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'campus_test_app.dart';

Future<void> _scrollTo(WidgetTester tester, Finder finder) => tester.scrollUntilVisible(
  finder,
  300,
  scrollable: find.byType(Scrollable).first,
);

/// The label printed under the code (not the field that edits it).
Finder _caption(String text) =>
    find.byWidgetPredicate((widget) => widget is Text && widget.data == text);

void main() {
  group('campus screens', () {
    for (final (name, theme) in [('light', AppTheme.light()), ('dark', AppTheme.dark())]) {
      testWidgets('render in the $name theme', (tester) async {
        for (final screen in const [
          CampusScreen(),
          CampusFiltersScreen(),
          CampusContentScreen(),
          CampusQrCodeScreen(),
        ]) {
          await pumpCampus(tester, screen, theme: theme);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '${screen.runtimeType}');
        }
      });
    }
  });

  group('CampusScreen', () {
    testWidgets('shows the launcher, the profile and the account menu', (tester) async {
      await pumpCampus(tester, const CampusScreen());
      await tester.pumpAndSettle();

      expect(find.text('Apps'), findsOneWidget);
      expect(find.text('Business intelligence'), findsOneWidget);

      await _scrollTo(tester, find.text('Alex Martin'));
      expect(find.text('ศูนย์เทคโนโลยีสารสนเทศ'), findsOneWidget);

      final menu = find.byTooltip('Account menu for Alex Martin');
      await _scrollTo(tester, menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(MenuItemButton, 'Sign out'), findsOneWidget);
    });
  });

  group('CampusFiltersScreen', () {
    testWidgets('loads the units into both filters', (tester) async {
      await pumpCampus(tester, const CampusFiltersScreen());
      await tester.pumpAndSettle();

      expect(find.text('Organisation filter'), findsOneWidget);
      await _scrollTo(tester, find.text('Course options'));
      expect(find.text('Course options'), findsOneWidget);
    });
  });

  group('CampusContentScreen', () {
    testWidgets('starts the plain fields read-only and the rich text editable', (tester) async {
      await pumpCampus(tester, const CampusContentScreen());
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.byKey(const ValueKey('row-th-text')));
      expect(find.byTooltip('Remove row 1'), findsOneWidget);
      expect(find.byTooltip('Bold'), findsWidgets);
    });

    testWidgets('saves rich text as HTML and refills an emptied editor', (tester) async {
      await pumpCampus(tester, const CampusContentScreen());
      await tester.pumpAndSettle();
      await _scrollTo(tester, find.byKey(const ValueKey('row-th-text')));
      final editor = find.byType(QuillEditor).first;

      tester.widget<QuillEditor>(editor).controller
        ..replaceText(0, 0, 'Hello', null)
        ..formatText(0, 5, Attribute.bold);
      await tester.pump();
      expect(find.textContaining(r'"value": "<p><strong>Hello</strong></p>"'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove row 2'));
      await tester.pump();
      await tester.tap(find.byTooltip('Remove row 1'));
      await tester.pump();

      expect(find.byType(QuillEditor), findsOneWidget);
      expect(
        find.text(
          prettyJson([
            {'key': 'th', 'value': ''},
          ]),
        ),
        findsOneWidget,
      );
    });
  });

  group('CampusQrCodeScreen', () {
    testWidgets('draws the code for its content and follows the fields', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpCampus(tester, const CampusQrCodeScreen());
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.bySemanticsLabel('QR code for https://www.mfu.ac.th'), findsOneWidget);
      expect(_caption('MFU'), findsOneWidget);

      await tester.enterText(fieldLabelled('Label'), 'Library');
      await tester.pump();
      expect(_caption('Library'), findsOneWidget);

      await tester.enterText(fieldLabelled('Content of the code'), '');
      await tester.pump();
      final share = tester.widget<IconButton>(
        find.ancestor(of: find.byTooltip('Share as PNG'), matching: find.byType(IconButton)),
      );
      expect(share.onPressed, isNull);
      expect(
        tester
            .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Share the content'))
            .onPressed,
        isNull,
      );
      semantics.dispose();
    });

    testWidgets('says when the content is too long for a code', (tester) async {
      await pumpCampus(tester, const CampusQrCodeScreen());
      await tester.pumpAndSettle();

      await tester.enterText(fieldLabelled('Content of the code'), 'x' * 4000);
      await tester.pump();

      expect(find.byType(QrImageView), findsNothing);
      expect(find.text('This content is too long for a QR code.'), findsOneWidget);
      final share = tester.widget<IconButton>(
        find.ancestor(of: find.byTooltip('Share as PNG'), matching: find.byType(IconButton)),
      );
      expect(share.onPressed, isNull);
    });
  });
}
