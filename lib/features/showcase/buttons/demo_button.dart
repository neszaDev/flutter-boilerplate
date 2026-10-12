import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';

/// The Marksheet button variants of the showcase, in the order the web app lists them. They
/// stand in for the Bootstrap colour set (primary, secondary, success, …) of the Vue app.
enum DemoVariant { primary, outline, secondary, ghost, destructive, link, inverse, inverseGhost }

/// The variants that sit on card stock, in the order the showcase lists them.
const cardVariants = [
  DemoVariant.primary,
  DemoVariant.outline,
  DemoVariant.secondary,
  DemoVariant.ghost,
  DemoVariant.destructive,
  DemoVariant.link,
];

/// The variants that read as a filled or bordered control (link has no box).
const boxedVariants = [
  DemoVariant.primary,
  DemoVariant.outline,
  DemoVariant.secondary,
  DemoVariant.ghost,
  DemoVariant.destructive,
];

/// The variant's name, as the showcase prints it.
String variantLabel(AppLocalizations l10n, DemoVariant variant) => switch (variant) {
  DemoVariant.primary => l10n.buttonVariantsDefault,
  DemoVariant.outline => l10n.buttonVariantsOutline,
  DemoVariant.secondary => l10n.buttonVariantsSecondary,
  DemoVariant.ghost => l10n.buttonVariantsGhost,
  DemoVariant.destructive => l10n.buttonVariantsDestructive,
  DemoVariant.link => l10n.buttonVariantsLink,
  DemoVariant.inverse => l10n.buttonVariantsInverse,
  DemoVariant.inverseGhost => l10n.buttonVariantsInverseGhost,
};

/// The four button heights. The web's 28–44 px scale moves up one step on the phone, so
/// [normal] is the app's own 44 pt button; the smaller ones keep Material's 48 pt touch area.
enum DemoSize {
  xs(height: 32, padding: 10, fontSize: 12, iconSize: 14, gap: Space.xs),
  sm(height: 36, padding: 12, fontSize: 13, iconSize: 16, gap: 6),
  normal(height: 44, padding: Space.page, fontSize: 14, iconSize: 18, gap: Space.sm),
  lg(height: 52, padding: Space.card, fontSize: 15, iconSize: 20, gap: Space.sm);

  const DemoSize({
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.gap,
  });

  final double height;

  /// Horizontal padding of a labelled button.
  final double padding;
  final double fontSize;
  final double iconSize;

  /// Space between the icon and the label.
  final double gap;
}

/// Corner style: the theme's rounded corners, square, or a pill.
enum DemoShape { rounded, square, pill }

/// Where a button sits in a `ButtonGroup`: outer corners stay round, inner ones square off.
@immutable
class GroupSlot {
  const GroupSlot({required this.first, required this.last, this.vertical = false});

  final bool first;
  final bool last;
  final bool vertical;

  /// The corners of a button of radius [radius] in this slot.
  BorderRadiusGeometry corners(double radius) {
    final start = first ? Radius.circular(radius) : Radius.zero;
    final end = last ? Radius.circular(radius) : Radius.zero;
    return vertical
        ? BorderRadius.vertical(top: start, bottom: end)
        : BorderRadiusDirectional.horizontal(start: start, end: end);
  }

  @override
  bool operator ==(Object other) =>
      other is GroupSlot &&
      other.first == first &&
      other.last == last &&
      other.vertical == vertical;

  @override
  int get hashCode => Object.hash(first, last, vertical);
}

/// Tells the buttons below it where they sit in a group.
class ButtonGroupScope extends InheritedWidget {
  const ButtonGroupScope({required this.slot, required super.child, super.key});

  final GroupSlot slot;

  static GroupSlot? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ButtonGroupScope>()?.slot;

  @override
  bool updateShouldNotify(ButtonGroupScope oldWidget) => slot != oldWidget.slot;
}

OutlinedBorder _shapeFor(DemoShape shape, GroupSlot? slot) => switch ((shape, slot)) {
  (DemoShape.square, _) => const RoundedRectangleBorder(),
  (DemoShape.pill, null) => const StadiumBorder(),
  (DemoShape.pill, final slot?) => RoundedRectangleBorder(borderRadius: slot.corners(999)),
  (DemoShape.rounded, _) => RoundedRectangleBorder(
    borderRadius: slot?.corners(Radii.md) ?? BorderRadius.circular(Radii.md),
  ),
};

/// [color] a step darker: the held "pressed" look of a filled button.
Color deeper(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - 0.08).clamp(0.0, 1.0)).toColor();
}

/// The colours of [variant] over the theme's button styles; [active] holds the pressed look.
ButtonStyle _variantStyle(BuildContext context, DemoVariant variant, {required bool active}) {
  final colors = context.colors;
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (variant) {
    // The theme's FilledButton is the primary button.
    DemoVariant.primary => FilledButton.styleFrom(
      backgroundColor: active ? (dark ? deeper(colors.primary) : colors.folderDeep) : null,
    ),
    DemoVariant.outline => OutlinedButton.styleFrom(
      foregroundColor: colors.ink900,
      backgroundColor: active ? colors.paperCard : null,
      side: active ? BorderSide(color: colors.ink400) : null,
    ),
    DemoVariant.secondary => FilledButton.styleFrom(
      backgroundColor: active ? colors.ink200 : colors.ink100,
      foregroundColor: colors.ink900,
      disabledBackgroundColor: colors.ink100,
      disabledForegroundColor: colors.ink400,
    ),
    DemoVariant.ghost => TextButton.styleFrom(
      backgroundColor: active ? colors.ink100 : null,
      foregroundColor: active ? colors.ink900 : null,
    ),
    DemoVariant.destructive => FilledButton.styleFrom(
      backgroundColor: active ? deeper(colors.pen) : colors.pen,
      foregroundColor: colors.ply,
      disabledBackgroundColor: colors.pen.withValues(alpha: 0.5),
      disabledForegroundColor: colors.ply,
    ),
    DemoVariant.link => TextButton.styleFrom(
      foregroundColor: colors.primary,
      disabledForegroundColor: colors.primary.withValues(alpha: 0.5),
      overlayColor: Colors.transparent,
    ),
    DemoVariant.inverse => FilledButton.styleFrom(
      backgroundColor: colors.folderInk,
      foregroundColor: colors.folder,
      disabledBackgroundColor: colors.folderInk.withValues(alpha: 0.5),
      disabledForegroundColor: colors.folder.withValues(alpha: 0.7),
    ),
    DemoVariant.inverseGhost => TextButton.styleFrom(
      foregroundColor: colors.folderInk,
      overlayColor: colors.folderInk,
      disabledForegroundColor: colors.folderInk.withValues(alpha: 0.5),
    ),
  };
}

/// The full style of a labelled showcase button. Fields left null fall back to the theme.
ButtonStyle demoButtonStyle(
  BuildContext context, {
  required DemoVariant variant,
  DemoSize size = DemoSize.normal,
  DemoShape shape = DemoShape.rounded,
  bool active = false,
  bool expand = false,
  GroupSlot? slot,
}) {
  final link = variant == DemoVariant.link;
  final text = context.text.labelLarge?.copyWith(fontSize: size.fontSize);
  final base = ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(expand ? double.infinity : 0, size.height)),
    // A link has no box, except inside a group where it lines up with its neighbours.
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: link && slot == null ? 0 : size.padding),
    ),
    textStyle: link
        ? WidgetStateProperty.resolveWith(
            (states) => text?.copyWith(
              decoration: active || states.contains(WidgetState.pressed)
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          )
        : WidgetStatePropertyAll(text),
    iconSize: WidgetStatePropertyAll(size.iconSize),
    shape: WidgetStatePropertyAll(_shapeFor(shape, slot)),
    // Joined buttons touch; outside a group, small ones keep the 48 pt touch area.
    tapTargetSize: slot == null ? null : MaterialTapTargetSize.shrinkWrap,
  );
  return _variantStyle(context, variant, active: active).merge(base);
}

void _noop() {}

/// A labelled showcase button: the Material button that matches [variant], sized and shaped
/// like the web app's `Button`. In a `ButtonGroup` it joins its neighbours.
class DemoButton extends StatelessWidget {
  const DemoButton({
    required this.label,
    this.variant = DemoVariant.primary,
    this.size = DemoSize.normal,
    this.shape = DemoShape.rounded,
    this.active = false,
    this.enabled = true,
    this.expand = false,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    super.key,
  });

  final String label;
  final DemoVariant variant;
  final DemoSize size;
  final DemoShape shape;

  /// Holds the pressed look (the web's `aria-pressed` "active state").
  final bool active;
  final bool enabled;

  /// Fill the width of the container.
  final bool expand;
  final Widget? icon;
  final Widget? trailingIcon;

  /// Defaults to doing nothing: the examples only need to look and feel enabled.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final slot = ButtonGroupScope.maybeOf(context);
    final style = demoButtonStyle(
      context,
      variant: variant,
      size: size,
      shape: shape,
      active: active,
      expand: expand,
      slot: slot,
    );
    final text = Text(label, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[icon!, SizedBox(width: size.gap)],
        // Alone, a long label fades out instead of overflowing; a group scrolls instead.
        if (slot == null) Flexible(child: text) else text,
        if (trailingIcon != null) ...[SizedBox(width: size.gap), trailingIcon!],
      ],
    );
    final pressed = enabled ? (onPressed ?? _noop) : null;
    final Widget button = switch (variant) {
      DemoVariant.primary ||
      DemoVariant.secondary ||
      DemoVariant.destructive ||
      DemoVariant.inverse => FilledButton(onPressed: pressed, style: style, child: child),
      DemoVariant.outline => OutlinedButton(onPressed: pressed, style: style, child: child),
      DemoVariant.ghost ||
      DemoVariant.link ||
      DemoVariant.inverseGhost => TextButton(onPressed: pressed, style: style, child: child),
    };
    return active ? MergeSemantics(child: Semantics(toggled: true, child: button)) : button;
  }
}

/// An icon-only showcase button, square at [size]'s height. [tooltip] names it.
class DemoIconButton extends StatelessWidget {
  const DemoIconButton({
    required this.icon,
    required this.tooltip,
    this.variant = DemoVariant.outline,
    this.size = DemoSize.normal,
    this.iconSize,
    this.onPressed,
    super.key,
  });

  final Widget icon;
  final String tooltip;
  final DemoVariant variant;
  final DemoSize size;

  /// Overrides [size]'s icon size.
  final double? iconSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final slot = ButtonGroupScope.maybeOf(context);
    final (background, foreground) = switch (variant) {
      DemoVariant.primary => (colors.primary, colors.onPrimary),
      DemoVariant.outline => (colors.ply, colors.ink900),
      DemoVariant.secondary => (colors.ink100, colors.ink900),
      DemoVariant.ghost => (null, colors.ink700),
      DemoVariant.destructive => (colors.pen, colors.ply),
      DemoVariant.link => (null, colors.primary),
      DemoVariant.inverse => (colors.folderInk, colors.folder),
      DemoVariant.inverseGhost => (null, colors.folderInk),
    };
    final style = IconButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      side: variant == DemoVariant.outline ? BorderSide(color: colors.ink300) : null,
      minimumSize: Size.square(size.height),
      maximumSize: Size.square(size.height),
      padding: EdgeInsets.zero,
      iconSize: iconSize ?? size.iconSize,
      shape: _shapeFor(DemoShape.rounded, slot),
      tapTargetSize: slot == null ? null : MaterialTapTargetSize.shrinkWrap,
    );
    return IconButton(
      onPressed: onPressed ?? _noop,
      tooltip: tooltip,
      style: style,
      icon: icon,
    );
  }
}
