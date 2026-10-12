import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_editor.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_samples.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_theme.dart';
import 'package:flutter_boilerplate/features/showcase/editors/syntax_highlighting.dart';
import 'package:flutter_test/flutter_test.dart';

String _joined(List<CodeRun> runs) => runs.map((run) => run.text).join();

void main() {
  group('highlightRuns', () {
    test('keeps every character of each sample', () {
      for (final language in CodeLanguage.values) {
        final source = expandTabs(codeSamples[language]!);
        expect(_joined(highlightRuns(source, language)), source, reason: language.name);
      }
    });

    test('marks HTML doctypes, tag names, attributes and comments', () {
      final runs = highlightRuns(expandTabs(codeSamples[CodeLanguage.html]!), CodeLanguage.html);

      expect(runs.first.className, 'meta');
      expect(runs.first.text, startsWith('<!DOCTYPE'));
      expect(runs, contains(const CodeRun('head', 'name')));
      expect(runs, contains(const CodeRun('charset', 'attr')));
      expect(runs, contains(const CodeRun('<!-- Icons -->', 'comment')));
    });

    test('marks JavaScript keywords and strings', () {
      final runs = highlightRuns(codeSamples[CodeLanguage.javascript]!, CodeLanguage.javascript);

      expect(runs.first, const CodeRun('const', 'keyword'));
      expect(runs, contains(const CodeRun('"uiwjs"', 'string')));
    });

    test('marks Markdown headings, emphasis and code', () {
      final runs = highlightRuns(codeSamples[CodeLanguage.markdown]!, CodeLanguage.markdown);

      expect(runs.first.className, 'section');
      expect(runs, contains(const CodeRun('`code`', 'code')));
      expect(runs.where((run) => run.className == 'strong'), isNotEmpty);
    });

    test('has no runs for an empty text', () {
      expect(highlightRuns('', CodeLanguage.html), isEmpty);
    });
  });

  group('codeSpans', () {
    final theme = CodeTheme.paper(MarksheetColors.light, Brightness.light);
    const runs = [CodeRun('const', 'keyword'), CodeRun(' a', null)];

    test('colours each run from the theme', () {
      final spans = codeSpans(runs, theme, TextRange.empty);

      expect(spans.map((span) => span.text), ['const', ' a']);
      expect(spans.first.style?.color, theme.colorOf('keyword'));
      expect(spans.last.style, isNull);
    });

    test('underlines the composing range across runs', () {
      final spans = codeSpans(runs, theme, const TextRange(start: 3, end: 6));

      expect(spans.map((span) => span.text), ['con', 'st', ' ', 'a']);
      expect(spans[1].style?.decoration, TextDecoration.underline);
      expect(spans[1].style?.color, theme.colorOf('keyword'));
      expect(spans[2].style?.decoration, TextDecoration.underline);
      expect(spans[3].style, isNull);
    });
  });

  group('CodeTheme', () {
    test('keeps paper surfaces on the Marksheet tokens in both app themes', () {
      final light = CodeTheme.paper(MarksheetColors.light, Brightness.light);
      final dark = CodeTheme.paper(MarksheetColors.dark, Brightness.dark);

      expect(light.background, MarksheetColors.light.ply);
      expect(dark.background, MarksheetColors.dark.ply);
      expect(light.colorOf('keyword'), isNot(dark.colorOf('keyword')));
      expect(
        CodeTheme.of(CodeThemeName.night, MarksheetColors.light, Brightness.light),
        CodeTheme.night,
      );
    });
  });

  group('lineIndexAt', () {
    test('counts the line breaks before an offset', () {
      expect(lineIndexAt('a\nb\nc', 0), 0);
      expect(lineIndexAt('a\nb\nc', 2), 1);
      expect(lineIndexAt('a\nb\nc', 5), 2);
      expect(lineIndexAt('a\nb\nc', 99), 2);
    });
  });

  group('CodeEditingController', () {
    test('highlights again when the language changes', () {
      final controller = CodeEditingController(
        language: CodeLanguage.html,
        theme: CodeTheme.night,
        text: 'const a = 1;',
      );
      addTearDown(controller.dispose);

      expect(controller.runs.any((run) => run.className == 'keyword'), isFalse);

      controller.language = CodeLanguage.javascript;

      expect(controller.runs.first, const CodeRun('const', 'keyword'));
    });
  });
}
