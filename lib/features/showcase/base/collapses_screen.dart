import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_collapse.dart';

/// The accordion's sections, in order; the first starts open.
enum _AccordionItem { marks, remarks, retakes }

/// `/dashboard/base/collapses`: a toggled panel with a nested one, a folding card and an
/// accordion where one section is open at a time.
class CollapsesScreen extends StatelessWidget {
  const CollapsesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.collapsesPageTitle,
      description: Text(l10n.collapsesPageDescription),
      children: [
        DemoCard(
          title: l10n.collapsesPageCollapseTitle,
          description: l10n.collapsesPageCollapseDescription,
          child: const _NestedCollapse(),
        ),
        const _CollapsibleCard(),
        DemoCard(
          title: l10n.collapsesPageAccordionTitle,
          description: l10n.collapsesPageAccordionDescription,
          padding: const EdgeInsets.fromLTRB(Space.card, Space.xs, Space.card, Space.xs),
          child: const _Accordion(),
        ),
      ],
    );
  }
}

/// A button that opens a panel; a second button inside opens a nested one.
class _NestedCollapse extends StatefulWidget {
  const _NestedCollapse();

  @override
  State<_NestedCollapse> createState() => _NestedCollapseState();
}

class _NestedCollapseState extends State<_NestedCollapse> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          expanded: _open,
          child: FilledButton(
            onPressed: () => setState(() => _open = !_open),
            child: Text(context.l10n.collapsesPageToggle),
          ),
        ),
        Collapse(
          open: _open,
          child: Padding(
            padding: const EdgeInsets.only(top: Space.md),
            child: _Panel(
              color: colors.ply,
              padding: Space.page,
              child: const _InnerCollapse(),
            ),
          ),
        ),
      ],
    );
  }
}

class _InnerCollapse extends StatefulWidget {
  const _InnerCollapse();

  @override
  State<_InnerCollapse> createState() => _InnerCollapseState();
}

class _InnerCollapseState extends State<_InnerCollapse> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.collapsesPageContents),
        const SizedBox(height: Space.md),
        Semantics(
          expanded: _open,
          child: FilledButton.tonal(
            onPressed: () => setState(() => _open = !_open),
            child: Text(l10n.collapsesPageToggleInner),
          ),
        ),
        Collapse(
          open: _open,
          child: Padding(
            padding: const EdgeInsets.only(top: Space.md),
            child: _Panel(
              color: colors.paperCard,
              padding: Space.md,
              child: Text(l10n.collapsesPageInnerContents),
            ),
          ),
        ),
      ],
    );
  }
}

/// A ruled box around collapsed content.
class _Panel extends StatelessWidget {
  const _Panel({required this.color, required this.padding, required this.child});

  final Color color;
  final double padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: context.colors.ink200),
      borderRadius: BorderRadius.circular(Radii.sm),
    ),
    child: DefaultTextStyle.merge(
      style: context.text.bodyMedium?.copyWith(color: context.colors.ink700),
      child: child,
    ),
  );
}

/// A card whose header folds the body away; it starts open.
class _CollapsibleCard extends StatelessWidget {
  const _CollapsibleCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: Space.card, vertical: Space.xs),
        childrenPadding: EdgeInsets.zero,
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        title: Semantics(
          header: true,
          child: Text(l10n.collapsesPageCardTitle, style: context.text.titleLarge),
        ),
        children: [
          Divider(color: colors.ink200),
          Padding(
            padding: const EdgeInsets.all(Space.card),
            child: Text(
              l10n.collapsesPageCardText,
              style: context.text.bodyMedium?.copyWith(color: colors.ink700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sections where opening one closes the others; the open one can be closed too.
class _Accordion extends StatefulWidget {
  const _Accordion();

  @override
  State<_Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<_Accordion> {
  final _controllers = {for (final item in _AccordionItem.values) item: ExpansibleController()};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _opened(_AccordionItem opened) {
    for (final MapEntry(key: item, value: controller) in _controllers.entries) {
      if (item != opened && controller.isExpanded) {
        controller.collapse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, item) in _AccordionItem.values.indexed) ...[
          if (index > 0) Divider(color: colors.ink200),
          ExpansionTile(
            controller: _controllers[item],
            initiallyExpanded: item == _AccordionItem.marks,
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: Space.page),
            expandedAlignment: AlignmentDirectional.centerStart,
            onExpansionChanged: (expanded) {
              if (expanded) {
                _opened(item);
              }
            },
            title: Text(
              switch (item) {
                _AccordionItem.marks => l10n.collapsesPageAccordionMarksTitle,
                _AccordionItem.remarks => l10n.collapsesPageAccordionRemarksTitle,
                _AccordionItem.retakes => l10n.collapsesPageAccordionRetakesTitle,
              },
              style: context.text.titleSmall?.copyWith(fontSize: 15, color: colors.ink950),
            ),
            children: [
              Text(
                switch (item) {
                  _AccordionItem.marks => l10n.collapsesPageAccordionMarksText,
                  _AccordionItem.remarks => l10n.collapsesPageAccordionRemarksText,
                  _AccordionItem.retakes => l10n.collapsesPageAccordionRetakesText,
                },
                style: context.text.bodyMedium?.copyWith(color: colors.ink700),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
