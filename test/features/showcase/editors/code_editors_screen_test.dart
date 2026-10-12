import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_editor.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_editors_screen.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_samples.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_theme.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump.dart';

Finder get _editor =>
    find.descendant(of: find.byType(CodeEditor), matching: find.byType(TextField));

String _text(WidgetTester tester) => tester.widget<TextField>(_editor).controller!.text;

Future<void> _choose(WidgetTester tester, String select, String option) async {
  await tester.ensureVisible(find.byKey(Key(select)));
  await tester.tap(find.byKey(Key(select)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  group('CodeEditorDemo', () {
    testWidgets('starts on the HTML sample with a line number per line', (tester) async {
      await pumpDemo(tester, const CodeEditorDemo());
      final html = expandTabs(codeSamples[CodeLanguage.html]!);
      final lines = '\n'.allMatches(html).length + 1;

      expect(_text(tester), html);
      expect(find.text('$lines'), findsOneWidget);
      expect(find.bySemanticsLabel(en.codeEditorsPageEditorLabel), findsOneWidget);
    });

    testWidgets('loads the sample of the chosen language', (tester) async {
      await pumpDemo(tester, const CodeEditorDemo());

      await _choose(tester, 'code-language', en.codeEditorsPageLanguageJavascript);

      expect(_text(tester), expandTabs(codeSamples[CodeLanguage.javascript]!));
      expect(_text(tester), contains('    name: "react-codemirror"'));
    });

    testWidgets('keeps the edits when the theme changes', (tester) async {
      await pumpDemo(tester, const CodeEditorDemo());

      await tester.enterText(_editor, '<p>Spring term</p>');
      await _choose(tester, 'code-theme', en.codeEditorsPageThemeNight);

      expect(_text(tester), '<p>Spring term</p>');
      expect(tester.widget<CodeEditor>(find.byType(CodeEditor)).theme, CodeTheme.night);
    });
  });

  group('CodeEditorsScreen', () {
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
            const CodeEditorsScreen(),
            screen: true,
            theme: theme,
            locale: locale,
          );

          expect(tester.takeException(), isNull);
          expect(find.byType(CodeEditor), findsOneWidget);
        },
      );
    }
  });
}
