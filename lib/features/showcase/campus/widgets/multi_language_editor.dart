import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/campus/rich_text_html.dart';
import 'package:flutter_boilerplate/features/showcase/campus/rows.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/multi_language_fields.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A language key and a rich-text editor per row (Vue `MLEditor`). With [editable], rows can be
/// added and removed; removing the last one brings back an empty Thai row. Each row's value is
/// the HTML the web app saves.
class MultiLanguageEditor extends StatefulWidget {
  const MultiLanguageEditor({required this.caption, required this.editable, super.key});

  final String caption;
  final bool editable;

  @override
  State<MultiLanguageEditor> createState() => _MultiLanguageEditorState();
}

class _MultiLanguageEditorState extends State<MultiLanguageEditor> {
  var _rows = defaultRows();
  var _nextId = 0;
  final _keys = <String, TextEditingController>{};
  final _texts = <String, QuillController>{};

  @override
  void dispose() {
    for (final controller in _keys.values) {
      controller.dispose();
    }
    for (final controller in _texts.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _newId() => 'row-new-${_nextId++}';

  TextEditingController _key(LanguageRow row) =>
      _keys.putIfAbsent(row.id, () => TextEditingController(text: row.key));

  QuillController _text(LanguageRow row) => _texts.putIfAbsent(row.id, () {
    final controller = QuillController.basic();
    var saved = row.value;
    controller.addListener(() {
      // The controller also notifies selection moves; only edits change the HTML.
      final html = deltaToHtml(controller.document.toDelta().toJson());
      if (html != saved && mounted) {
        saved = html;
        setState(() => _rows = updateRow(_rows, row.id, value: html));
      }
    });
    return controller;
  });

  void _remove(String id) {
    setState(() => _rows = removeRow(_rows, id, refillId: _newId()));
    final key = _keys.remove(id);
    final text = _texts.remove(id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      key?.dispose();
      text?.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            widget.caption,
            style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: Space.md),
        for (final (index, row) in _rows.indexed) ...[
          if (index > 0) const SizedBox(height: Space.card),
          LanguageKeyRow(
            key: ValueKey(row.id),
            row: index + 1,
            controller: _key(row),
            editable: widget.editable,
            onChanged: (text) => setState(() => _rows = updateRow(_rows, row.id, key: text)),
            onAdd: () => setState(() => _rows = addRow(_rows, _newId())),
            onRemove: () => _remove(row.id),
          ),
          const SizedBox(height: Space.sm),
          RichTextField(
            key: ValueKey('${row.id}-text'),
            label: l10n.campusContentTextLabel('${index + 1}'),
            controller: _text(row),
          ),
        ],
        const SizedBox(height: Space.page),
        RowsPreview(rows: _rows),
      ],
    );
  }
}

/// A small rich-text editor: a formatting toolbar over a Quill editor, in a field's frame.
class RichTextField extends StatefulWidget {
  const RichTextField({required this.label, required this.controller, super.key});

  /// Read by screen readers.
  final String label;
  final QuillController controller;

  @override
  State<RichTextField> createState() => _RichTextFieldState();
}

class _RichTextFieldState extends State<RichTextField> {
  final _focus = FocusNode();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_redraw);
  }

  @override
  void dispose() {
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _redraw() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final focused = _focus.hasFocus;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.ply,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: focused ? Theme.of(context).colorScheme.primary : colors.ink300,
          width: focused ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Toolbar(controller: widget.controller),
          Divider(color: colors.ink200),
          Semantics(
            label: widget.label,
            textField: true,
            child: QuillEditor(
              controller: widget.controller,
              focusNode: _focus,
              scrollController: _scroll,
              config: QuillEditorConfig(
                scrollable: false,
                minHeight: 96,
                padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.md),
                customStyles: _styles(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DefaultStyles _styles(BuildContext context) {
    final base = DefaultStyles.getInstance(context);
    final body = context.text.bodyMedium ?? const TextStyle();
    final paragraph = base.paragraph;
    return DefaultStyles(
      paragraph: paragraph == null
          ? null
          : DefaultTextBlockStyle(
              body,
              paragraph.horizontalSpacing,
              paragraph.verticalSpacing,
              paragraph.lineSpacing,
              paragraph.decoration,
            ),
    );
  }
}

/// Bold, italic, underline, strikethrough and the two lists, as toggles.
class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller});

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label: l10n.campusContentToolbarLabel,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final style = controller.getSelectionStyle().attributes;
          final list = style[Attribute.list.key]?.value;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Space.xs),
            child: Row(
              children: [
                _ToggleButton(
                  tooltip: l10n.campusContentBold,
                  icon: LucideIcons.bold,
                  selected: style.containsKey(Attribute.bold.key),
                  onPressed: () => _toggle(Attribute.bold, style),
                ),
                _ToggleButton(
                  tooltip: l10n.campusContentItalic,
                  icon: LucideIcons.italic,
                  selected: style.containsKey(Attribute.italic.key),
                  onPressed: () => _toggle(Attribute.italic, style),
                ),
                _ToggleButton(
                  tooltip: l10n.campusContentUnderline,
                  icon: LucideIcons.underline,
                  selected: style.containsKey(Attribute.underline.key),
                  onPressed: () => _toggle(Attribute.underline, style),
                ),
                _ToggleButton(
                  tooltip: l10n.campusContentStrike,
                  icon: LucideIcons.strikethrough,
                  selected: style.containsKey(Attribute.strikeThrough.key),
                  onPressed: () => _toggle(Attribute.strikeThrough, style),
                ),
                _ToggleButton(
                  tooltip: l10n.campusContentBulletList,
                  icon: LucideIcons.list,
                  selected: list == Attribute.ul.value,
                  onPressed: () => controller.formatSelection(
                    list == Attribute.ul.value ? Attribute.clone(Attribute.ul, null) : Attribute.ul,
                  ),
                ),
                _ToggleButton(
                  tooltip: l10n.campusContentOrderedList,
                  icon: LucideIcons.listOrdered,
                  selected: list == Attribute.ol.value,
                  onPressed: () => controller.formatSelection(
                    list == Attribute.ol.value ? Attribute.clone(Attribute.ol, null) : Attribute.ol,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggle(Attribute<bool?> attribute, Map<String, Attribute<Object?>> style) =>
      controller.formatSelection(
        style.containsKey(attribute.key) ? Attribute.clone(attribute, null) : attribute,
      );
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      isSelected: selected,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: selected ? scheme.primary : null,
        backgroundColor: selected ? scheme.primary.withValues(alpha: 0.14) : null,
      ),
      icon: Icon(icon, size: 18),
    );
  }
}
