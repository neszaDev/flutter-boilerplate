import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/editors/rich_text_editor.dart';
import 'package:flutter_boilerplate/features/showcase/editors/text_editors_screen.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump.dart';

Future<void> _pumpDemo(WidgetTester tester) =>
    pumpDemo(tester, TextEditorDemo(document: Delta()..insert('Spring term\n')));

QuillController _controller(WidgetTester tester) =>
    tester.widget<QuillEditor>(find.byType(QuillEditor)).controller;

Future<void> _tapTool(WidgetTester tester, String tooltip) async {
  await tester.ensureVisible(find.byTooltip(tooltip));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip(tooltip));
  await tester.pumpAndSettle();
}

bool? _selected(WidgetTester tester, String tooltip) => tester
    .widget<IconButton>(
      find.ancestor(of: find.byTooltip(tooltip), matching: find.byType(IconButton)),
    )
    .isSelected;

void main() {
  group('TextEditorDemo', () {
    testWidgets('prints the HTML of the document under the editor', (tester) async {
      await _pumpDemo(tester);

      expect(find.text('<p>Spring term</p>'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^${en.textEditorsPageEditorLabel}')), findsOneWidget);
    });

    testWidgets('writes bold text after the bold toggle and can undo it', (tester) async {
      await _pumpDemo(tester);
      final controller = _controller(tester);

      controller.updateSelection(const TextSelection.collapsed(offset: 11), ChangeSource.local);
      await _tapTool(tester, en.richTextEditorBold);
      controller.replaceText(11, 0, ' report', const TextSelection.collapsed(offset: 18));
      await tester.pumpAndSettle();

      expect(find.text('<p>Spring term<strong> report</strong></p>'), findsOneWidget);
      expect(_selected(tester, en.richTextEditorBold), isTrue);

      await _tapTool(tester, en.richTextEditorUndo);

      expect(find.text('<p>Spring term</p>'), findsOneWidget);
    });

    testWidgets('turns the current paragraph into a heading', (tester) async {
      await _pumpDemo(tester);

      await _tapTool(tester, en.richTextEditorHeading2);

      expect(find.text('<h2>Spring term</h2>'), findsOneWidget);
      expect(_selected(tester, en.richTextEditorHeading2), isTrue);
    });

    testWidgets('links the selection from the link dialog', (tester) async {
      await _pumpDemo(tester);
      _controller(tester).updateSelection(
        const TextSelection(baseOffset: 0, extentOffset: 6),
        ChangeSource.local,
      );

      await _tapTool(tester, en.richTextEditorLink);
      await tester.enterText(
        find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)),
        'https://example.com',
      );
      await tester.tap(find.text(en.richTextEditorApplyLink));
      await tester.pumpAndSettle();

      expect(find.textContaining('href="https://example.com">Spring</a>'), findsOneWidget);
      expect(_selected(tester, en.richTextEditorLink), isTrue);
    });

    testWidgets('names every toolbar button', (tester) async {
      await _pumpDemo(tester);

      expect(find.byType(ToolbarButton), findsNWidgets(17));
      for (final button in tester.widgetList<ToolbarButton>(find.byType(ToolbarButton))) {
        expect(button.tooltip, isNotEmpty);
      }
    });
  });

  group('TextEditorsScreen', () {
    for (final (label, theme, width, locale) in [
      ('light', AppTheme.light(), 360.0, const Locale('fr')),
      ('dark', AppTheme.dark(), 430.0, const Locale('en')),
    ]) {
      testWidgets(
        'lays out on a ${width.round()} pt phone in the $label theme (${locale.languageCode})',
        (tester) async {
          useTallPhone(tester, width: width, height: 3000);
          await pumpDemo(
            tester,
            const TextEditorsScreen(),
            screen: true,
            theme: theme,
            locale: locale,
          );

          expect(tester.takeException(), isNull);
          expect(find.textContaining('<p><strong>'), findsOneWidget);
        },
      );
    }
  });
}
