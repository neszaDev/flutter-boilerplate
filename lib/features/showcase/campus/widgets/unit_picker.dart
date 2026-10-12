import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/campus/filters.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A searchable, clearable select (the web's `Combobox`): the field shows the choice; tapping
/// it opens a sheet with a search box and the options.
class UnitPicker extends StatelessWidget {
  const UnitPicker({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final List<FilterOption> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  Future<void> _open(BuildContext context) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _OptionsSheet(title: label, options: options, selected: value),
    );
    if (chosen != null) {
      Haptics.selection();
      onChanged(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final selected = labelOf(options, value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ExcludeSemantics(child: Text(label, style: context.text.titleSmall)),
        ),
        Semantics(
          button: true,
          label: label,
          child: InkWell(
            onTap: enabled ? () => _open(context) : null,
            borderRadius: BorderRadius.circular(Radii.md),
            child: InputDecorator(
              isEmpty: selected == null,
              decoration: InputDecoration(
                enabled: enabled,
                constraints: const BoxConstraints(minHeight: 44),
                suffixIcon: selected != null && enabled
                    ? IconButton(
                        tooltip: l10n.campusFiltersClear,
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () => onChanged(null),
                      )
                    : const ExcludeSemantics(child: Icon(LucideIcons.chevronDown, size: 18)),
              ),
              child: Text(
                selected ?? l10n.campusFiltersChoose,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  color: selected == null || !enabled ? colors.ink600 : colors.ink900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionsSheet extends StatefulWidget {
  const _OptionsSheet({required this.title, required this.options, required this.selected});

  final String title;
  final List<FilterOption> options;
  final String? selected;

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _query.trim().toLowerCase();
    final matches = [
      for (final option in widget.options)
        if (option.label.toLowerCase().contains(query)) option,
    ];
    return Padding(
      // Keep the list above the keyboard while searching.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.md),
            child: Semantics(
              header: true,
              child: Text(widget.title, style: context.text.titleLarge),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.lg),
            child: TextField(
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.campusFiltersSearch,
                prefixIcon: const Icon(LucideIcons.search, size: 18),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: Space.sm),
          Flexible(
            child: matches.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(Space.lg),
                    child: Semantics(
                      container: true,
                      liveRegion: true,
                      child: Text(
                        l10n.campusFiltersNoMatch,
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium?.copyWith(color: context.colors.ink600),
                      ),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: Space.lg),
                    children: [
                      for (final option in matches)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg),
                          title: Text(option.label),
                          selected: option.value == widget.selected,
                          trailing: option.value == widget.selected
                              ? const Icon(LucideIcons.check, size: 18)
                              : null,
                          onTap: () => Navigator.pop(context, option.value),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
