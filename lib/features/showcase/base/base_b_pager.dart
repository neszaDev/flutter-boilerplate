import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_page_items.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Button sizes of a pagination bar: the drawn square (the web's `icon-sm`, `icon`, `icon-lg`).
/// Every button is tappable across its whole slot (see [_slotWidth]).
enum PagerSize {
  small(32),
  normal(36),
  large(44);

  const PagerSize(this.extent);

  final double extent;
}

/// The height every slot is tappable over, and the width it gets when there is room.
const double _slotTarget = 44;

/// The width of one slot when [count] slots share [width]: the full 44 pt tap target when they
/// fit, else narrower to keep the bar on one line, but never narrower than the drawn square.
double _slotWidth(PagerSize size, double width, int count) => math.min(
  math.max(size.extent, _slotTarget),
  math.max(size.extent, (width / count).floorToDouble()),
);

/// How many slots a bar takes: arrows, page numbers and ellipses.
int _slotCount(PageItems items, {required bool wide}) =>
    items.items.length + (items.beforeDots ? 1 : 0) + (items.afterDots ? 1 : 0) + (wide ? 4 : 2);

/// The narrowest a bar can be on one line (without its first/last arrows).
double pagerMinWidth({required int page, required int pages, PagerSize size = PagerSize.normal}) =>
    _slotCount(pageItems(activePage: page, pages: pages), wide: false) * size.extent;

/// A CoreUI-style pagination bar: first/previous arrows, up to five slots of page numbers and
/// ellipses, next/last arrows. Arrows at the ends are disabled; the first/last arrows are dropped
/// when the bar would not fit on one line (on phones).
class Pager extends StatelessWidget {
  const Pager({
    required this.label,
    required this.page,
    required this.pages,
    required this.onPage,
    this.size = PagerSize.normal,
    this.alignment = WrapAlignment.start,
    super.key,
  });

  /// Accessible name of the bar.
  final String label;

  /// The current page (1-based).
  final int page;
  final int pages;

  /// Called with the page to go to.
  final ValueChanged<int> onPage;
  final PagerSize size;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = pageItems(activePage: page, pages: pages);
    final atStart = page == 1;
    final atEnd = page == pages;

    void go(int target) {
      if (target != page) {
        onPage(target);
      }
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wideCount = _slotCount(items, wide: true);
          final wide = constraints.maxWidth >= wideCount * math.max(size.extent, _slotTarget);
          final slot = _slotWidth(
            size,
            constraints.maxWidth,
            wide ? wideCount : _slotCount(items, wide: false),
          );

          Widget arrow(String text, IconData icon, int target, {required bool disabled}) =>
              _PagerSlot(
                size: size,
                width: slot,
                label: text,
                tooltip: text,
                onTap: disabled ? null : () => go(target),
                child: Icon(icon, size: 16),
              );

          Widget dots() => ExcludeSemantics(
            child: SizedBox(
              width: slot,
              height: _slotTarget,
              child: Icon(LucideIcons.ellipsis, size: 16, color: context.colors.ink600),
            ),
          );

          return Wrap(
            alignment: alignment,
            children: [
              if (wide)
                arrow(l10n.paginationsPageFirst, LucideIcons.chevronsLeft, 1, disabled: atStart),
              arrow(
                l10n.paginationsPagePrevious,
                LucideIcons.chevronLeft,
                page - 1,
                disabled: atStart,
              ),
              if (items.beforeDots) dots(),
              for (final number in items.items)
                _PagerSlot(
                  size: size,
                  width: slot,
                  label: l10n.paginationsPagePage('$number'),
                  current: number == page,
                  onTap: () => go(number),
                  child: Text(
                    '$number',
                    style: context.text.labelLarge?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: number == page ? context.colors.ink950 : context.colors.ink700,
                    ),
                  ),
                ),
              if (items.afterDots) dots(),
              arrow(l10n.paginationsPageNext, LucideIcons.chevronRight, page + 1, disabled: atEnd),
              if (wide)
                arrow(l10n.paginationsPageLast, LucideIcons.chevronsRight, pages, disabled: atEnd),
            ],
          );
        },
      ),
    );
  }
}

/// One button of the bar: a square of the size's extent, outlined when it is the current page,
/// tappable over its whole slot. Disabled (dimmed, not tappable) without [onTap].
class _PagerSlot extends StatelessWidget {
  const _PagerSlot({
    required this.size,
    required this.width,
    required this.label,
    required this.onTap,
    required this.child,
    this.current = false,
    this.tooltip,
  });

  final PagerSize size;
  final double width;
  final String label;
  final VoidCallback? onTap;
  final bool current;
  final String? tooltip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget slot = Semantics(
      button: true,
      enabled: onTap != null,
      selected: current,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.md),
          child: SizedBox(
            width: width,
            height: _slotTarget,
            child: Center(
              child: Container(
                width: size.extent,
                height: size.extent,
                alignment: Alignment.center,
                decoration: current
                    ? BoxDecoration(
                        color: colors.ply,
                        border: Border.all(color: colors.ink300),
                        borderRadius: BorderRadius.circular(Radii.md),
                      )
                    : null,
                child: IconTheme.merge(
                  data: IconThemeData(color: colors.ink700),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (tooltip != null) {
      slot = Tooltip(message: tooltip, excludeFromSemantics: true, child: slot);
    }
    return slot;
  }
}

const _pages = 10;

/// The two Vue pagination cards (sizes and alignment), all six bars sharing one current page.
class PagerDemos extends StatefulWidget {
  const PagerDemos({super.key});

  @override
  State<PagerDemos> createState() => _PagerDemosState();
}

class _PagerDemosState extends State<PagerDemos> {
  int _page = 3;

  void _go(int page) => setState(() => _page = page);

  Widget _example(String title, {PagerSize size = PagerSize.normal, WrapAlignment? alignment}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: FormLabel(title)),
          const SizedBox(height: Space.sm),
          Pager(
            label: title,
            page: _page,
            pages: _pages,
            onPage: _go,
            size: size,
            alignment: alignment ?? WrapAlignment.start,
          ),
        ],
      );

  /// Both cards print the page; only the first announces changes.
  Widget _current({required bool live}) => Padding(
    padding: const EdgeInsets.only(top: Space.lg),
    child: Semantics(
      liveRegion: live,
      child: Text(
        context.l10n.paginationsPageCurrent('$_page'),
        style: context.text.bodySmall?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: l10n.paginationsPageSizeTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _example(l10n.paginationsPageSizeDefault),
              const SizedBox(height: Space.lg),
              _example(l10n.paginationsPageSizeSmall, size: PagerSize.small),
              // The large bar only shows where it fits on one line (not on the narrowest phones).
              LayoutBuilder(
                builder: (context, constraints) =>
                    constraints.maxWidth <
                        pagerMinWidth(page: _page, pages: _pages, size: PagerSize.large)
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: Space.lg),
                        child: _example(l10n.paginationsPageSizeLarge, size: PagerSize.large),
                      ),
              ),
              _current(live: true),
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        DemoCard(
          title: l10n.paginationsPageAlignTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _example(l10n.paginationsPageAlignStart),
              const SizedBox(height: Space.lg),
              _example(l10n.paginationsPageAlignCenter, alignment: WrapAlignment.center),
              const SizedBox(height: Space.lg),
              _example(l10n.paginationsPageAlignEnd, alignment: WrapAlignment.end),
              _current(live: false),
            ],
          ),
        ),
      ],
    );
  }
}
