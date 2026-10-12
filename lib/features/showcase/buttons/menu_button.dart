import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/demo_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Which edge of the trigger a menu lines up with.
enum MenuAlign { start, end }

/// Where a menu opens against its trigger: the web's `align`, `side`, `sideOffset` and
/// `alignOffset`.
@immutable
class MenuPlacement {
  const MenuPlacement({
    this.align = MenuAlign.start,
    this.above = false,
    this.sideOffset = Space.xs,
    this.alignOffset = 0,
  });

  final MenuAlign align;

  /// Open upwards ("drop up").
  final bool above;

  /// Gap between the trigger and the menu.
  final double sideOffset;

  /// Shift along the aligned edge, towards the end.
  final double alignOffset;
}

/// Width of a menu aligned to the end of its trigger. `MenuAnchor` places a menu by its start
/// corner, so lining its end up with the trigger needs the menu's width up front.
const endAlignedMenuWidth = 208.0;

/// The narrowest menu (the web's `min-w-44`).
const _minMenuWidth = 176.0;

/// The `MenuAnchor` style for [placement].
MenuStyle menuStyleFor(MenuPlacement placement) {
  final end = placement.align == MenuAlign.end;
  return MenuStyle(
    alignment: switch ((end, placement.above)) {
      (false, false) => AlignmentDirectional.bottomStart,
      (true, false) => AlignmentDirectional.bottomEnd,
      // MenuAnchor moves a menu above its trigger when it doesn't fit below, so anchoring it far
      // below the screen makes it always open upwards, the gap kept and the menu on screen.
      (false, true) => const AlignmentDirectional(-1, 1000),
      (true, true) => const AlignmentDirectional(1, 1000),
    },
    minimumSize: const WidgetStatePropertyAll(Size(_minMenuWidth, 0)),
    fixedSize: end ? const WidgetStatePropertyAll(Size.fromWidth(endAlignedMenuWidth)) : null,
  );
}

/// The `MenuAnchor.alignmentOffset` for [placement].
Offset menuOffsetFor(MenuPlacement placement) => Offset(
  placement.align == MenuAlign.end
      ? placement.alignOffset - endAlignedMenuWidth
      : placement.alignOffset,
  placement.sideOffset,
);

/// A menu opened by the trigger [builder] makes; the builder gets the open/close toggle.
class _DemoMenu extends StatelessWidget {
  const _DemoMenu({
    required this.menuChildren,
    required this.placement,
    required this.builder,
  });

  final List<Widget> menuChildren;
  final MenuPlacement placement;
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  @override
  Widget build(BuildContext context) => MenuAnchor(
    style: menuStyleFor(placement),
    alignmentOffset: menuOffsetFor(placement),
    // Keeps the minimum and fixed widths on the menu itself.
    crossAxisUnconstrained: false,
    menuChildren: menuChildren,
    builder: (context, controller, _) => builder(
      context,
      () => controller.isOpen ? controller.close() : controller.open(),
    ),
  );
}

/// A button that opens a menu (the web's `MenuButton`): its label, then a caret.
class MenuButton extends StatelessWidget {
  const MenuButton({
    required this.label,
    required this.menuChildren,
    this.variant = DemoVariant.outline,
    this.size = DemoSize.normal,
    this.caret = true,
    this.placement = const MenuPlacement(),
    super.key,
  });

  final String label;
  final DemoVariant variant;
  final DemoSize size;
  final bool caret;
  final MenuPlacement placement;
  final List<Widget> menuChildren;

  @override
  Widget build(BuildContext context) => _DemoMenu(
    menuChildren: menuChildren,
    placement: placement,
    builder: (context, toggle) => DemoButton(
      label: label,
      variant: variant,
      size: size,
      trailingIcon: caret ? const Icon(LucideIcons.chevronDown) : null,
      onPressed: toggle,
    ),
  );
}

/// The caret half of a split button: an icon button that opens the menu. Put it in a
/// `ButtonGroup` after the action's `DemoButton`.
class MenuCaretButton extends StatelessWidget {
  const MenuCaretButton({
    required this.menuChildren,
    this.variant = DemoVariant.outline,
    this.size = DemoSize.normal,
    this.placement = const MenuPlacement(),
    super.key,
  });

  final DemoVariant variant;
  final DemoSize size;
  final MenuPlacement placement;
  final List<Widget> menuChildren;

  @override
  Widget build(BuildContext context) => _DemoMenu(
    menuChildren: menuChildren,
    placement: placement,
    builder: (context, toggle) => DemoIconButton(
      icon: const Icon(LucideIcons.chevronDown),
      tooltip: context.l10n.menuButtonToggleMenu,
      variant: variant,
      size: size,
      onPressed: toggle,
    ),
  );
}

/// An icon trigger without a caret; [tooltip] names it.
class MenuIconButton extends StatelessWidget {
  const MenuIconButton({
    required this.icon,
    required this.tooltip,
    required this.menuChildren,
    this.variant = DemoVariant.ghost,
    this.size = DemoSize.normal,
    super.key,
  });

  final Widget icon;
  final String tooltip;
  final DemoVariant variant;
  final DemoSize size;
  final List<Widget> menuChildren;

  @override
  Widget build(BuildContext context) => _DemoMenu(
    menuChildren: menuChildren,
    placement: const MenuPlacement(),
    builder: (context, toggle) => DemoIconButton(
      icon: icon,
      tooltip: tooltip,
      variant: variant,
      size: size,
      iconSize: 20,
      onPressed: toggle,
    ),
  );
}

void _noop() {}

/// A plain menu entry; [enabled] false greys it out.
MenuItemButton menuItem(String label, {bool enabled = true, Widget? child}) =>
    MenuItemButton(onPressed: enabled ? _noop : null, child: child ?? Text(label));

/// A menu entry for a destructive action, in red pen.
class DestructiveMenuItem extends StatelessWidget {
  const DestructiveMenuItem(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => MenuItemButton(
    onPressed: _noop,
    style: MenuItemButton.styleFrom(foregroundColor: context.colors.pen),
    child: Text(label),
  );
}

/// A rule between menu entries.
class MenuSeparator extends StatelessWidget {
  const MenuSeparator({super.key});

  @override
  Widget build(BuildContext context) => const Divider(height: Space.page + 1);
}

/// A printed header over menu entries (the web's `DropdownMenuLabel`).
class MenuLabel extends StatelessWidget {
  const MenuLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, Space.xs),
    child: Semantics(header: true, child: FormLabel(text)),
  );
}

/// Entries grouped under a [MenuLabel], announced as one group (the web's `DropdownMenuGroup`).
class MenuGroup extends StatelessWidget {
  const MenuGroup({required this.label, required this.children, super.key});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [MenuLabel(label), ...children],
    ),
  );
}
