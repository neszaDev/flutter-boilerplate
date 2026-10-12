import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/tables/page_window.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _button = 44.0;

/// Page buttons for a client-side list (CoreUI's `CPagination`): first/last, previous/next
/// and a window of page numbers. Where the numbers don't fit (a narrow phone), it shows
/// "Page 2 of 5" between the arrows instead.
class TablePagination extends StatelessWidget {
  const TablePagination({
    required this.page,
    required this.pages,
    required this.onPageChange,
    this.doubleArrows = true,
    super.key,
  });

  /// Current page, one-based.
  final int page;
  final int pages;
  final ValueChanged<int> onPageChange;

  /// Show the first and last page buttons.
  final bool doubleArrows;

  @override
  Widget build(BuildContext context) {
    if (pages <= 1) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final first = page <= 1;
    final last = page >= pages;
    Widget arrow(
      int target, {
      required bool disabled,
      required String label,
      required IconData icon,
    }) => IconButton(
      tooltip: label,
      onPressed: disabled ? null : () => onPageChange(target),
      icon: Icon(icon, size: 18),
    );

    final leading = [
      if (doubleArrows)
        arrow(1, disabled: first, label: l10n.dataTableFirstPage, icon: LucideIcons.chevronsLeft),
      arrow(
        page - 1,
        disabled: first,
        label: l10n.dataTablePreviousPage,
        icon: LucideIcons.chevronLeft,
      ),
    ];
    final trailing = [
      arrow(
        page + 1,
        disabled: last,
        label: l10n.dataTableNextPage,
        icon: LucideIcons.chevronRight,
      ),
      if (doubleArrows)
        arrow(
          pages,
          disabled: last,
          label: l10n.dataTableLastPage,
          icon: LucideIcons.chevronsRight,
        ),
    ];
    final slots = pageWindow(page: page, pages: pages);

    return Semantics(
      container: true,
      label: l10n.dataTablePaginationLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fits =
              (leading.length + trailing.length + slots.length) * _button <= constraints.maxWidth;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...leading,
              if (fits)
                for (final slot in slots)
                  _PageSlot(slot: slot, current: page, onPageChange: onPageChange)
              else
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.sm),
                    child: Text(
                      l10n.dataTablePageOf('$page', '$pages'),
                      style: context.type.table.copyWith(color: context.colors.ink700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ...trailing,
            ],
          );
        },
      ),
    );
  }
}

class _PageSlot extends StatelessWidget {
  const _PageSlot({required this.slot, required this.current, required this.onPageChange});

  /// A page number, or null for a gap.
  final int? slot;
  final int current;
  final ValueChanged<int> onPageChange;

  @override
  Widget build(BuildContext context) {
    final page = slot;
    if (page == null) {
      return ExcludeSemantics(
        child: SizedBox.square(
          dimension: _button,
          child: Icon(LucideIcons.ellipsis, size: 16, color: context.colors.ink400),
        ),
      );
    }
    final selected = page == current;
    final label = Text(
      '$page',
      semanticsLabel: context.l10n.dataTableGoToPage('$page'),
      style: context.type.table.copyWith(fontWeight: selected ? FontWeight.w700 : null),
    );
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.square(_button)),
      maximumSize: const WidgetStatePropertyAll(Size.square(_button)),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      foregroundColor: WidgetStatePropertyAll(context.colors.ink900),
    );
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: selected
            ? OutlinedButton(style: style, onPressed: () => onPageChange(page), child: label)
            : TextButton(style: style, onPressed: () => onPageChange(page), child: label),
      ),
    );
  }
}
