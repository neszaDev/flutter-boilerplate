import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/editors/editor_docs_link.dart';
import 'package:flutter_boilerplate/features/showcase/editors/quill_html.dart';
import 'package:flutter_boilerplate/features/showcase/editors/rich_text_editor.dart';
import 'package:flutter_boilerplate/features/showcase/editors/sample_document.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

/// A rich text editor that writes clean HTML (the web's text editors page, which uses Tiptap;
/// here flutter_quill).
class TextEditorsScreen extends StatelessWidget {
  const TextEditorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.textEditorsPageTitle,
      description: Text(l10n.textEditorsPageDescription),
      children: [
        DemoCard(
          title: l10n.textEditorsPageCardTitle,
          description: l10n.textEditorsPageCardDescription,
          action: EditorDocsLink(
            url: 'https://pub.dev/packages/flutter_quill',
            label: l10n.textEditorsPageDocs,
            title: l10n.textEditorsPageDocsTitle,
          ),
          child: TextEditorDemo(document: sampleDocument(l10n)),
        ),
      ],
    );
  }
}

/// The rich text editor and, under it, the HTML it produces as you type.
class TextEditorDemo extends StatefulWidget {
  const TextEditorDemo({required this.document, super.key});

  /// The first content of the editor.
  final Delta document;

  @override
  State<TextEditorDemo> createState() => _TextEditorDemoState();
}

class _TextEditorDemoState extends State<TextEditorDemo> {
  late final _controller = QuillController(
    document: Document.fromDelta(widget.document),
    selection: const TextSelection.collapsed(offset: 0),
  );
  late String _html = deltaToHtml(_controller.document.toDelta());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
  }

  void _update() {
    final html = deltaToHtml(_controller.document.toDelta());
    if (html != _html) {
      setState(() => _html = html);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_update)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichTextEditor(controller: _controller, label: l10n.textEditorsPageEditorLabel),
        const SizedBox(height: Space.lg),
        Semantics(
          header: true,
          child: FormLabel(l10n.textEditorsPageOutputTitle, color: colors.ink700),
        ),
        const SizedBox(height: Space.sm),
        Container(
          constraints: const BoxConstraints(maxHeight: 288),
          decoration: BoxDecoration(
            color: colors.ink100,
            border: Border.all(color: colors.ink200),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Space.md),
            child: SelectableText(_html, style: context.type.code),
          ),
        ),
      ],
    );
  }
}
