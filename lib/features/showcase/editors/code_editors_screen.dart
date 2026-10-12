import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_editor.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_samples.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_theme.dart';
import 'package:flutter_boilerplate/features/showcase/editors/editor_docs_link.dart';
import 'package:flutter_boilerplate/features/showcase/editors/syntax_highlighting.dart';

/// A code editor with syntax highlighting, line numbers and two themes (the web's code editors
/// page, which uses CodeMirror; here highlight.js through package:highlight).
class CodeEditorsScreen extends StatelessWidget {
  const CodeEditorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.codeEditorsPageTitle,
      description: Text(l10n.codeEditorsPageDescription),
      children: [
        DemoCard(
          title: l10n.codeEditorsPageCardTitle,
          description: l10n.codeEditorsPageCardDescription,
          action: EditorDocsLink(
            url: 'https://pub.dev/packages/highlight',
            label: l10n.codeEditorsPageDocs,
            title: l10n.codeEditorsPageDocsTitle,
          ),
          child: const CodeEditorDemo(),
        ),
      ],
    );
  }
}

/// The editor and selects for its theme (Marksheet paper or One Dark) and language (Markdown,
/// JavaScript or HTML). Changing the language loads that language's sample; changing the theme
/// keeps your edits.
class CodeEditorDemo extends StatefulWidget {
  const CodeEditorDemo({super.key});

  @override
  State<CodeEditorDemo> createState() => _CodeEditorDemoState();
}

class _CodeEditorDemoState extends State<CodeEditorDemo> {
  var _themeName = CodeThemeName.paper;
  final _controller = CodeEditingController(
    language: CodeLanguage.html,
    theme: CodeTheme.night,
    text: expandTabs(codeSamples[CodeLanguage.html]!),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setLanguage(CodeLanguage? language) {
    if (language == null || language == _controller.language) {
      return;
    }
    setState(() {
      _controller
        ..language = language
        ..value = TextEditingValue(text: expandTabs(codeSamples[language]!));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = CodeTheme.of(_themeName, context.colors, Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CodeEditor(
          controller: _controller,
          theme: theme,
          label: l10n.codeEditorsPageEditorLabel,
          minHeight: MediaQuery.sizeOf(context).height * 0.5,
        ),
        const SizedBox(height: Space.page),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Select<CodeThemeName>(
                key: const Key('code-theme'),
                label: l10n.codeEditorsPageThemeLabel,
                value: _themeName,
                options: {
                  CodeThemeName.paper: l10n.codeEditorsPageThemePaper,
                  CodeThemeName.night: l10n.codeEditorsPageThemeNight,
                },
                onChanged: (name) => setState(() => _themeName = name ?? _themeName),
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: _Select<CodeLanguage>(
                key: const Key('code-language'),
                label: l10n.codeEditorsPageLanguageLabel,
                value: _controller.language,
                options: {
                  CodeLanguage.markdown: l10n.codeEditorsPageLanguageMarkdown,
                  CodeLanguage.javascript: l10n.codeEditorsPageLanguageJavascript,
                  CodeLanguage.html: l10n.codeEditorsPageLanguageHtml,
                },
                onChanged: _setLanguage,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A labelled select of [options] (value → text).
class _Select<T> extends StatelessWidget {
  const _Select({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => LabeledField(
    label: label,
    child: DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      items: [
        for (final MapEntry(key: option, value: text) in options.entries)
          DropdownMenuItem(
            value: option,
            child: Text(text, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    ),
  );
}
