import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/campus/filters.dart';
import 'package:flutter_boilerplate/features/showcase/campus/rows.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Key/value rows for one text in several languages (Vue `MultiLanguage`). With [editable],
/// each row has add and remove buttons; the list may end up empty, then an add button shows.
class MultiLanguageFields extends StatefulWidget {
  const MultiLanguageFields({required this.editable, this.caption, super.key});

  final bool editable;

  /// Optional heading above the rows.
  final String? caption;

  @override
  State<MultiLanguageFields> createState() => _MultiLanguageFieldsState();
}

class _MultiLanguageFieldsState extends State<MultiLanguageFields> {
  var _rows = defaultRows();
  var _nextId = 0;
  final _keys = <String, TextEditingController>{};
  final _values = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final controller in [..._keys.values, ..._values.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(
    Map<String, TextEditingController> controllers,
    String id,
    String text,
  ) => controllers.putIfAbsent(id, () => TextEditingController(text: text));

  void _add() => setState(() => _rows = addRow(_rows, 'row-new-${_nextId++}'));

  void _remove(String id) {
    setState(() => _rows = removeRow(_rows, id));
    // Dispose once the removed row's fields are gone from the tree.
    final key = _keys.remove(id);
    final value = _values.remove(id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      key?.dispose();
      value?.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final caption = widget.caption;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (caption != null) ...[
          Semantics(
            header: true,
            child: Text(
              caption,
              style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: Space.md),
        ],
        for (final (index, row) in _rows.indexed) ...[
          if (index > 0) const SizedBox(height: Space.page),
          LanguageKeyRow(
            key: ValueKey(row.id),
            row: index + 1,
            controller: _controller(_keys, row.id, row.key),
            editable: widget.editable,
            onChanged: (text) => setState(() => _rows = updateRow(_rows, row.id, key: text)),
            onAdd: _add,
            onRemove: () => _remove(row.id),
          ),
          const SizedBox(height: Space.sm),
          AddonField(
            key: ValueKey('${row.id}-value'),
            addon: l10n.campusContentValue,
            label: l10n.campusContentValueLabel('${index + 1}'),
            controller: _controller(_values, row.id, row.value),
            onChanged: (text) => setState(() => _rows = updateRow(_rows, row.id, value: text)),
          ),
        ],
        if (widget.editable && _rows.isEmpty)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: _add,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(l10n.campusContentAdd),
            ),
          ),
        const SizedBox(height: Space.page),
        RowsPreview(rows: _rows),
      ],
    );
  }
}

/// A text field with a printed addon on its left (the web's `InputGroupAddon`). [label] names
/// it for screen readers.
class AddonField extends StatelessWidget {
  const AddonField({
    required this.addon,
    required this.label,
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final String addon;
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: Space.md, end: Space.sm),
            child: Text(addon, style: context.type.formLabel),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minHeight: 44),
      ),
    ),
  );
}

/// The language key of a row, with its add and remove buttons when [editable].
class LanguageKeyRow extends StatelessWidget {
  const LanguageKeyRow({
    required this.row,
    required this.controller,
    required this.editable,
    required this.onChanged,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  /// Row number, for the accessible names.
  final int row;
  final TextEditingController controller;
  final bool editable;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: AddonField(
            addon: l10n.campusContentKey,
            label: l10n.campusContentKeyLabel('$row'),
            controller: controller,
            onChanged: onChanged,
          ),
        ),
        if (editable) ...[
          const SizedBox(width: Space.sm),
          IconButton.outlined(
            tooltip: l10n.campusContentAdd,
            onPressed: onAdd,
            style: IconButton.styleFrom(
              foregroundColor: colors.pass,
              side: BorderSide(color: colors.ink300),
            ),
            icon: const Icon(LucideIcons.listPlus, size: 18),
          ),
          const SizedBox(width: Space.xs),
          IconButton.outlined(
            tooltip: l10n.campusContentRemove('$row'),
            onPressed: onRemove,
            style: IconButton.styleFrom(
              foregroundColor: colors.pen,
              side: BorderSide(color: colors.ink300),
            ),
            icon: const Icon(LucideIcons.trash2, size: 18),
          ),
        ],
      ],
    );
  }
}

/// The rows as the backend stores them (`[{ key, value }]`), for the data preview.
class RowsPreview extends StatelessWidget {
  const RowsPreview({required this.rows, super.key});

  final List<LanguageRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormLabel(context.l10n.campusContentDataTitle, color: colors.ink700),
        const SizedBox(height: Space.sm),
        Container(
          constraints: const BoxConstraints(maxHeight: 192),
          decoration: BoxDecoration(
            color: colors.paper,
            border: Border.all(color: colors.ink200),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
            child: Text(
              prettyJson([for (final row in rows) row.toJson()]),
              style: context.type.code.copyWith(fontSize: 12, color: colors.ink700),
            ),
          ),
        ),
      ],
    );
  }
}
