import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_samples.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_theme.dart';
import 'package:highlight/highlight_core.dart' show Highlight, Node;
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:highlight/languages/xml.dart';

/// A stretch of source text and the highlight.js class that colours it (null: plain text).
@immutable
class CodeRun {
  const CodeRun(this.text, this.className);

  final String text;
  final String? className;

  @override
  bool operator ==(Object other) =>
      other is CodeRun && other.text == text && other.className == className;

  @override
  int get hashCode => Object.hash(text, className);

  @override
  String toString() => 'CodeRun(${className ?? '-'}: "$text")';
}

// Only the demo's languages, plus CSS and JavaScript for <style> and <script> in HTML.
final _highlight = Highlight()
  ..registerLanguage('xml', xml)
  ..registerLanguage('javascript', javascript)
  ..registerLanguage('css', css)
  ..registerLanguage('markdown', markdown);

/// [source] split into runs by token class, in order: joined, they give back [source]. A
/// token without a class of its own takes its parent's (the `<`, `=` and `>` of a tag).
List<CodeRun> highlightRuns(String source, CodeLanguage language) {
  if (source.isEmpty) {
    return const [];
  }
  final nodes = _highlight.parse(source, language: language.highlightName).nodes ?? const [];
  final runs = <CodeRun>[];

  void add(String text, String? className) {
    if (runs.isNotEmpty && runs.last.className == className) {
      runs[runs.length - 1] = CodeRun(runs.last.text + text, className);
    } else {
      runs.add(CodeRun(text, className));
    }
  }

  void visit(Node node, String? inherited) {
    final className = node.className ?? inherited;
    final value = node.value;
    if (value != null && value.isNotEmpty) {
      add(value, className);
    }
    for (final child in node.children ?? const <Node>[]) {
      visit(child, className);
    }
  }

  for (final node in nodes) {
    visit(node, null);
  }
  return runs;
}

/// Spans for [runs] coloured by [theme], with the [composing] range (an unfinished IME word)
/// underlined as in a plain text field.
List<TextSpan> codeSpans(List<CodeRun> runs, CodeTheme theme, TextRange composing) {
  final spans = <TextSpan>[];
  final composes = composing.isValid && !composing.isCollapsed;
  var offset = 0;
  for (final run in runs) {
    final color = theme.colorOf(run.className);
    final style = color == null ? null : TextStyle(color: color);
    final start = offset;
    final end = offset + run.text.length;
    offset = end;
    if (!composes || composing.end <= start || composing.start >= end) {
      spans.add(TextSpan(text: run.text, style: style));
      continue;
    }
    final from = math.max(composing.start, start) - start;
    final to = math.min(composing.end, end) - start;
    if (from > 0) {
      spans.add(TextSpan(text: run.text.substring(0, from), style: style));
    }
    spans.add(
      TextSpan(
        text: run.text.substring(from, to),
        style: (style ?? const TextStyle()).copyWith(decoration: TextDecoration.underline),
      ),
    );
    if (to < run.text.length) {
      spans.add(TextSpan(text: run.text.substring(to), style: style));
    }
  }
  return spans;
}

/// A text controller that draws its text highlighted for [language] in [theme]'s colours.
class CodeEditingController extends TextEditingController {
  CodeEditingController({required this._language, required this.theme, super.text});

  CodeLanguage _language;

  /// The colours; the editor sets it on every build, so it does not notify.
  CodeTheme theme;

  String? _highlightedText;
  CodeLanguage? _highlightedLanguage;
  List<CodeRun> _runs = const [];

  CodeLanguage get language => _language;

  set language(CodeLanguage value) {
    if (value == _language) {
      return;
    }
    _language = value;
    notifyListeners();
  }

  /// The highlighted runs of the current text (parsed once per text and language).
  List<CodeRun> get runs {
    if (_highlightedText != text || _highlightedLanguage != _language) {
      _runs = highlightRuns(text, _language);
      _highlightedText = text;
      _highlightedLanguage = _language;
    }
    return _runs;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final composing = withComposing && value.isComposingRangeValid
        ? value.composing
        : TextRange.empty;
    return TextSpan(style: style, children: codeSpans(runs, theme, composing));
  }
}
