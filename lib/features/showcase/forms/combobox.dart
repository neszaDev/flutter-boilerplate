import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One option of a [Combobox].
@immutable
class ComboboxOption {
  const ComboboxOption({required this.value, required this.label, this.disabled = false});

  final String value;
  final String label;

  /// Shown, but cannot be picked.
  final bool disabled;
}

/// Toggles [value] in [selection]: adds it at the end, or removes it when already selected. A
/// single selection holds at most one value, and choosing it again keeps it.
List<String> toggleSelection(List<String> selection, String value, {required bool multiple}) {
  if (!multiple) {
    return [value];
  }
  return selection.contains(value)
      ? [
          for (final selected in selection)
            if (selected != value) selected,
        ]
      : [...selection, value];
}

/// The options matching a search: the label contains [query], or the value starts with it,
/// ignoring case (the web's command list searches labels and values).
List<ComboboxOption> filterOptions(List<ComboboxOption> options, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) {
    return options;
  }
  return [
    for (final option in options)
      if (option.label.toLowerCase().contains(needle) ||
          option.value.toLowerCase().startsWith(needle))
        option,
  ];
}

/// A select with a search box (the web's `Combobox`). Tapping the field opens a sheet with the
/// search and the options. With [multiple], the chosen options sit in the field as chips that
/// can be removed one by one; disabled options stay visible but cannot be picked.
class Combobox extends StatefulWidget {
  const Combobox({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.multiple = false,
    this.clearable = false,
    this.placeholder,
    this.searchPlaceholder,
    this.enabled = true,
    super.key,
  });

  /// Titles the sheet (the field itself is named by its LabeledField).
  final String label;
  final List<ComboboxOption> options;

  /// Selected option values.
  final List<String> value;
  final ValueChanged<List<String>> onChanged;
  final bool multiple;

  /// Show a button that clears the selection.
  final bool clearable;

  /// Shown while nothing is selected (and after the chips of a multiple selection).
  final String? placeholder;
  final String? searchPlaceholder;
  final bool enabled;

  @override
  State<Combobox> createState() => _ComboboxState();
}

class _ComboboxState extends State<Combobox> {
  bool _open = false;

  List<ComboboxOption> get _selected => [
    for (final value in widget.value) ...widget.options.where((option) => option.value == value),
  ];

  Future<void> _openSheet() async {
    setState(() => _open = true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ComboboxSheet(
        label: widget.label,
        options: widget.options,
        value: widget.value,
        multiple: widget.multiple,
        searchPlaceholder: widget.searchPlaceholder,
        onChanged: widget.onChanged,
      ),
    );
    if (mounted) {
      setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final selected = _selected;
    final placeholder = ExcludeSemantics(
      child: Text(
        widget.placeholder ?? l10n.comboboxPlaceholder,
        style: context.text.bodyMedium?.copyWith(color: colors.ink400),
      ),
    );

    final Widget content;
    if (selected.isEmpty) {
      content = placeholder;
    } else if (!widget.multiple) {
      content = ExcludeSemantics(child: Text(selected.first.label, style: context.text.bodyMedium));
    } else {
      content = Semantics(
        container: true,
        explicitChildNodes: true,
        label: l10n.comboboxSelected,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final option in selected)
              InputChip(
                label: Text(option.label),
                isEnabled: widget.enabled,
                deleteIcon: const Icon(LucideIcons.x, size: 14),
                deleteButtonTooltipMessage: l10n.comboboxRemove(option.label),
                onDeleted: () => widget.onChanged(
                  toggleSelection(widget.value, option.value, multiple: true),
                ),
              ),
            placeholder,
          ],
        ),
      );
    }

    // Put the field in a LabeledField, which names it for screen readers.
    return Semantics(
      button: true,
      value: selected.map((option) => option.label).join(', '),
      child: InkWell(
        onTap: widget.enabled ? _openSheet : null,
        borderRadius: BorderRadius.circular(Radii.md),
        child: InputDecorator(
          isFocused: _open,
          decoration: InputDecoration(
            enabled: widget.enabled,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Space.md,
              vertical: widget.multiple && selected.isNotEmpty ? Space.xs : 12,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.clearable && selected.isNotEmpty)
                  IconButton(
                    tooltip: l10n.comboboxClear,
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: widget.enabled ? () => widget.onChanged(const []) : null,
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: Space.md),
                  child: Icon(LucideIcons.chevronsUpDown, size: 18, color: colors.ink600),
                ),
              ],
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// The search box and the options, in a bottom sheet.
class _ComboboxSheet extends StatefulWidget {
  const _ComboboxSheet({
    required this.label,
    required this.options,
    required this.value,
    required this.multiple,
    required this.searchPlaceholder,
    required this.onChanged,
  });

  final String label;
  final List<ComboboxOption> options;
  final List<String> value;
  final bool multiple;
  final String? searchPlaceholder;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_ComboboxSheet> createState() => _ComboboxSheetState();
}

class _ComboboxSheetState extends State<_ComboboxSheet> {
  final _search = TextEditingController();
  late List<String> _value = widget.value;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _choose(String value) {
    final next = toggleSelection(_value, value, multiple: widget.multiple);
    widget.onChanged(next);
    if (!widget.multiple) {
      Navigator.pop(context);
      return;
    }
    // Like the web: the search empties after a pick, ready for the next one.
    setState(() {
      _value = next;
      _search.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final searchLabel = widget.searchPlaceholder ?? l10n.comboboxSearch;
    final options = filterOptions(widget.options, _search.text);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.sm, Space.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(widget.label, style: context.text.titleLarge),
                    ),
                  ),
                  if (widget.multiple)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.comboboxDone),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.page),
              child: Semantics(
                label: searchLabel,
                child: TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: searchLabel,
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Space.sm),
            if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.comboboxEmpty,
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(color: context.colors.ink600),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: Space.page),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final checked = _value.contains(option.value);
                    if (widget.multiple) {
                      return CheckboxListTile(
                        value: checked,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(option.label),
                        onChanged: option.disabled ? null : (_) => _choose(option.value),
                      );
                    }
                    return ListTile(
                      title: Text(option.label),
                      enabled: !option.disabled,
                      selected: checked,
                      trailing: checked ? const Icon(LucideIcons.check, size: 18) : null,
                      onTap: () => _choose(option.value),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
