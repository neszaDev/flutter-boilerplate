import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/demo_button.dart';

/// Buttons joined into one control (the web's `ButtonGroup`): inner corners square off and
/// shared borders overlap. [children] are `DemoButton`s, `DemoIconButton`s or menu triggers.
///
/// A row that is wider than the screen scrolls sideways instead of overflowing.
class ButtonGroup extends StatelessWidget {
  const ButtonGroup({
    required this.label,
    required this.children,
    this.vertical = false,
    super.key,
  });

  /// Accessible name of the group.
  final String label;
  final bool vertical;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final items = [
      for (final (index, child) in children.indexed)
        ButtonGroupScope(
          slot: GroupSlot(
            first: index == 0,
            last: index == children.length - 1,
            vertical: vertical,
          ),
          // Each button moves back one pixel per neighbour so the borders overlap.
          child: index == 0
              ? child
              : Transform.translate(
                  offset: vertical
                      ? Offset(0, -index.toDouble())
                      : Offset(rtl ? index.toDouble() : -index.toDouble(), 0),
                  child: child,
                ),
        ),
    ];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: vertical
          ? IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: items,
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(mainAxisSize: MainAxisSize.min, children: items),
            ),
    );
  }
}

/// One labelled row of examples (the web's `DemoRow`): the printed label, then the examples
/// wrapping under it. Put rows in [DemoRows] to rule them apart.
class DemoRow extends StatelessWidget {
  const DemoRow({
    required this.label,
    required this.children,
    this.spacing = Space.md,
    this.background,
    super.key,
  });

  final String label;
  final double spacing;

  /// Paints the examples on this colour (e.g. the folder green).
  final Color? background;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final examples = Wrap(
      spacing: spacing,
      runSpacing: spacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormLabel(label),
        const SizedBox(height: Space.md),
        if (background == null)
          examples
        else
          DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Padding(padding: const EdgeInsets.all(Space.page), child: examples),
          ),
      ],
    );
  }
}

/// [DemoRow]s with a rule between each.
class DemoRows extends StatelessWidget {
  const DemoRows({required this.rows, super.key});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, row) in rows.indexed) ...[
        if (index > 0) const Divider(height: Space.xl + 1),
        row,
      ],
    ],
  );
}
