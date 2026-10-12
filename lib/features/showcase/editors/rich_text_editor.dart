import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/features/showcase/editors/quill_html.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Sets the link of the selection, or of the whole link the caret is in, to [url]; an empty
/// [url] removes it. With a bare caret outside a link, inserts the address as linked text.
void applyLink(QuillController controller, String url) {
  final href = url.trim();
  var index = controller.selection.start;
  var length = controller.selection.end - index;
  if (length == 0) {
    // The caret may sit inside the link or just after its last character.
    for (final offset in [index, index - 1]) {
      if (offset < 0) {
        continue;
      }
      final leaf = controller.document.querySegmentLeafNode(offset).leaf;
      if (leaf != null && leaf.style.containsKey(Attribute.link.key)) {
        final range = getLinkRange(leaf);
        index = range.start;
        length = range.end - range.start;
        break;
      }
    }
  }
  if (length == 0) {
    if (href.isNotEmpty) {
      controller
        ..replaceText(index, 0, href, TextSelection.collapsed(offset: index + href.length))
        ..formatText(index, href.length, LinkAttribute(href));
    }
    return;
  }
  controller.formatText(index, length, LinkAttribute(href.isEmpty ? null : href));
}

/// Replaces the selection with a horizontal rule on a line of its own, and puts the caret on
/// the line after it.
void insertRule(QuillController controller) {
  final selection = controller.selection;
  var index = selection.start;
  if (selection.end > index) {
    controller.replaceText(index, selection.end - index, '', null);
  }
  if (index > 0 && controller.document.getPlainText(index - 1, 1) != '\n') {
    controller.replaceText(index, 0, '\n', null);
    index++;
  }
  controller
    ..replaceText(index, 0, const BlockEmbed(ruleEmbedType, 'hr'), null)
    ..replaceText(index + 1, 0, '\n', TextSelection.collapsed(offset: index + 2));
}

/// Draws the horizontal rule embed.
class RuleEmbedBuilder extends EmbedBuilder {
  const RuleEmbedBuilder();

  @override
  String get key => ruleEmbedType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Space.md),
    child: Divider(color: context.colors.ink300),
  );
}

/// The editor's printed-page styles, from the Marksheet tokens (the web's `CONTENT_CLASS`).
DefaultStyles richTextStyles(BuildContext context) {
  final colors = context.colors;
  final scheme = Theme.of(context).colorScheme;
  final base = context.text.bodyMedium!.copyWith(color: colors.ink900, height: 1.6);
  final mono = context.type.code;
  const none = HorizontalSpacing(0, 0);
  DefaultTextBlockStyle block(TextStyle style, VerticalSpacing spacing, [BoxDecoration? box]) =>
      DefaultTextBlockStyle(style, none, spacing, VerticalSpacing.zero, box);
  TextStyle heading(double size, FontWeight weight) => base.copyWith(
    fontSize: size,
    fontWeight: weight,
    height: 1.3,
    letterSpacing: size >= 24 ? -0.48 : 0,
    color: colors.ink950,
  );
  return DefaultStyles(
    paragraph: block(base, const VerticalSpacing(8, 0)),
    h1: block(heading(24, FontWeight.w700), const VerticalSpacing(16, 8)),
    h2: block(heading(20, FontWeight.w700), const VerticalSpacing(16, 8)),
    h3: block(heading(18, FontWeight.w600), const VerticalSpacing(12, 6)),
    lists: DefaultListBlockStyle(
      base,
      none,
      const VerticalSpacing(8, 8),
      VerticalSpacing.zero,
      null,
      null,
    ),
    quote: block(
      base.copyWith(color: colors.ink700),
      const VerticalSpacing(12, 12),
      BoxDecoration(
        border: Border(left: BorderSide(width: 3, color: colors.ink300)),
      ),
    ),
    code: block(
      mono.copyWith(color: scheme.onInverseSurface),
      const VerticalSpacing(12, 12),
      BoxDecoration(color: scheme.inverseSurface, borderRadius: BorderRadius.circular(Radii.md)),
    ),
    inlineCode: InlineCodeStyle(
      style: mono.copyWith(color: colors.ink900),
      backgroundColor: colors.ink100,
      radius: const Radius.circular(Radii.sm),
    ),
    link: TextStyle(
      color: colors.primary,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
      decorationColor: colors.primary,
    ),
    placeHolder: block(base.copyWith(color: colors.ink400), VerticalSpacing.zero),
  );
}

/// A rich text editor (flutter_quill) on the white ply, with the web editor's toolbar: marks
/// (bold, italic, underline, strike, code, link), blocks (headings, lists, quote, code block,
/// rule), undo/redo and clearing the formatting.
class RichTextEditor extends StatefulWidget {
  const RichTextEditor({
    required this.controller,
    required this.label,
    this.minHeight = 256,
    super.key,
  });

  final QuillController controller;

  /// Names the editing area for screen readers.
  final String label;
  final double minHeight;

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  final _focus = FocusNode();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // flutter_quill's own texts (its link menu, selection toolbar) need its localizations.
    return Localizations.override(
      context: context,
      delegates: const [FlutterQuillLocalizations.delegate],
      child: ListenableBuilder(
        listenable: _focus,
        builder: (context, child) => Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.ply,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: _focus.hasFocus ? colors.primary : colors.ink300),
            boxShadow: [
              if (_focus.hasFocus)
                BoxShadow(color: colors.primary.withValues(alpha: 0.2), spreadRadius: 3),
            ],
          ),
          child: child,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichTextToolbar(controller: widget.controller),
            Divider(color: colors.ink200),
            Semantics(
              container: true,
              label: widget.label,
              child: QuillEditor(
                controller: widget.controller,
                focusNode: _focus,
                scrollController: _scroll,
                config: QuillEditorConfig(
                  // The page scrolls; the editor grows with its text.
                  scrollable: false,
                  minHeight: widget.minHeight,
                  padding: const EdgeInsets.symmetric(horizontal: Space.page, vertical: Space.md),
                  customStyles: richTextStyles(context),
                  embedBuilders: const [RuleEmbedBuilder()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A flutter_quill `childBuilder` that draws the button with [build]. flutter_quill reads the
/// builder through its untyped base options, so a builder with typed parameters fails its
/// runtime type check; this one takes untyped ones and casts the extra options it is given.
Widget Function(Object?, Object?) _buttonBuilder<E>(Widget Function(E extra) build) =>
    (_, extra) => build(extra as E);

/// The toolbar, built from flutter_quill's buttons (which track the selection's style) in the
/// web editor's order, scrolling sideways on a phone.
class RichTextToolbar extends StatelessWidget {
  const RichTextToolbar({required this.controller, super.key});

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget toggle(Attribute<Object?> attribute, IconData icon, String tooltip) =>
        QuillToolbarToggleStyleButton(
          controller: controller,
          attribute: attribute,
          options: QuillToolbarToggleStyleButtonOptions(
            iconData: icon,
            tooltip: tooltip,
            childBuilder: _buttonBuilder<QuillToolbarToggleStyleButtonExtraOptions>(
              (extra) => ToolbarButton(
                icon: icon,
                tooltip: tooltip,
                selected: extra.isToggled,
                onPressed: extra.onPressed,
              ),
            ),
          ),
        );

    Widget history({required bool undo}) {
      final icon = undo ? LucideIcons.undo2 : LucideIcons.redo2;
      final tooltip = undo ? l10n.richTextEditorUndo : l10n.richTextEditorRedo;
      return QuillToolbarHistoryButton(
        controller: controller,
        isUndo: undo,
        options: QuillToolbarHistoryButtonOptions(
          iconData: icon,
          tooltip: tooltip,
          childBuilder: _buttonBuilder<QuillToolbarHistoryButtonExtraOptions>(
            (extra) => ToolbarButton(
              icon: icon,
              tooltip: tooltip,
              onPressed: extra.canPressed ? extra.onPressed : null,
            ),
          ),
        ),
      );
    }

    final buttons = <Widget>[
      toggle(Attribute.bold, LucideIcons.bold, l10n.richTextEditorBold),
      toggle(Attribute.italic, LucideIcons.italic, l10n.richTextEditorItalic),
      toggle(Attribute.underline, LucideIcons.underline, l10n.richTextEditorUnderline),
      toggle(Attribute.strikeThrough, LucideIcons.strikethrough, l10n.richTextEditorStrike),
      toggle(Attribute.inlineCode, LucideIcons.code, l10n.richTextEditorCode),
      _LinkButton(controller: controller),
      const _Separator(),
      toggle(Attribute.h1, LucideIcons.heading1, l10n.richTextEditorHeading1),
      toggle(Attribute.h2, LucideIcons.heading2, l10n.richTextEditorHeading2),
      toggle(Attribute.h3, LucideIcons.heading3, l10n.richTextEditorHeading3),
      toggle(Attribute.ul, LucideIcons.list, l10n.richTextEditorBulletList),
      toggle(Attribute.ol, LucideIcons.listOrdered, l10n.richTextEditorOrderedList),
      toggle(Attribute.blockQuote, LucideIcons.quote, l10n.richTextEditorBlockquote),
      toggle(Attribute.codeBlock, LucideIcons.squareCode, l10n.richTextEditorCodeBlock),
      ToolbarButton(
        icon: LucideIcons.minus,
        tooltip: l10n.richTextEditorHorizontalRule,
        onPressed: () => insertRule(controller),
      ),
      const _Separator(),
      history(undo: true),
      history(undo: false),
      QuillToolbarClearFormatButton(
        controller: controller,
        options: QuillToolbarClearFormatButtonOptions(
          iconData: LucideIcons.removeFormatting,
          tooltip: l10n.richTextEditorClearFormatting,
          childBuilder: _buttonBuilder<QuillToolbarClearFormatButtonExtraOptions>(
            (extra) => ToolbarButton(
              icon: LucideIcons.removeFormatting,
              tooltip: l10n.richTextEditorClearFormatting,
              onPressed: extra.onPressed,
            ),
          ),
        ),
      ),
    ];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: l10n.richTextEditorToolbarLabel,
      child: ColoredBox(
        color: context.colors.paperCard,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: Space.xs),
          child: Row(children: buttons),
        ),
      ),
    );
  }
}

/// An icon-only toolbar button; with [selected], a toggle that reads as on or off.
class ToolbarButton extends StatelessWidget {
  const ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Null for a plain button.
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      tooltip: tooltip,
      isSelected: selected,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? colors.ink300
              : states.contains(WidgetState.selected)
              ? colors.ink950
              : colors.ink700,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? colors.primary.withValues(alpha: 0.16) : null,
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 20,
    margin: const EdgeInsets.symmetric(horizontal: Space.xs),
    color: context.colors.ink200,
  );
}

/// The link toggle: on inside a link; opens a dialog for the address.
class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.controller});

  final QuillController controller;

  Future<void> _edit(BuildContext context) async {
    final current = controller.getSelectionStyle().attributes[Attribute.link.key]?.value;
    final url = await showDialog<String>(
      context: context,
      builder: (context) => _LinkDialog(initial: current is String ? current : null),
    );
    if (url != null) {
      applyLink(controller, url);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => ToolbarButton(
      icon: LucideIcons.link,
      tooltip: context.l10n.richTextEditorLink,
      selected: QuillTextLink.isSelected(controller),
      onPressed: () => _edit(context),
    ),
  );
}

/// Asks for a link address. Resolves the address, an empty string to remove the link, or null
/// when cancelled.
class _LinkDialog extends StatefulWidget {
  const _LinkDialog({required this.initial});

  /// The current link, if the selection has one.
  final String? initial;

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  late final _url = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.richTextEditorLink),
      content: LabeledField(
        label: l10n.richTextEditorLinkUrl,
        child: TextField(
          controller: _url,
          autofocus: true,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.url],
          decoration: const InputDecoration(hintText: 'https://'),
          onSubmitted: (url) => Navigator.pop(context, url),
        ),
      ),
      actions: [
        if (widget.initial != null)
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: Text(l10n.richTextEditorRemoveLink),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _url.text),
          child: Text(l10n.richTextEditorApplyLink),
        ),
      ],
    );
  }
}
