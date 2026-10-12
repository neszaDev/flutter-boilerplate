import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_logic.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One entry of a [NavDemo].
@immutable
class NavDemoItem {
  const NavDemoItem({required this.id, required this.label, this.icon, this.disabled = false});

  final String id;

  /// Shown unless [icon] is set; then it names the item for screen readers and the tooltip.
  final String label;
  final IconData? icon;
  final bool disabled;
}

/// A trailing dropdown of a [NavDemo]: its trigger label and groups of entries, a divider
/// between groups.
typedef NavDemoDropdown = ({String label, List<List<String>> groups});

enum NavDemoVariant { plain, tabs, pills }

/// The id the dropdown takes when one of its entries is chosen.
const _dropdownId = 'dropdown';

const _gap = Space.xs;
const _itemPadding = EdgeInsets.symmetric(horizontal: Space.page);

/// Equal-width items on a phone get less padding.
const _justifiedPadding = EdgeInsets.symmetric(horizontal: Space.sm);

/// The width of [text] on one line.
double _measure(String text, TextStyle style, TextScaler scaler) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width.ceilToDouble();
}

/// The style items are measured in: bold, the widest an item gets, in the inherited font.
TextStyle _measureStyle(BuildContext context) =>
    DefaultTextStyle.of(context).style.merge(_NavButton.textStyle(active: true));
const _itemHeight = 44.0;

/// A row (or column) of navigation items in the Bootstrap nav styles: plain links, tabs or
/// pills, optionally filling or splitting the width evenly, and an optional dropdown at the end.
/// Tapping an item (or choosing a dropdown entry) makes it the current one.
class NavDemo extends StatefulWidget {
  const NavDemo({
    required this.label,
    required this.items,
    this.variant = NavDemoVariant.plain,
    this.initialActive,
    this.fill = false,
    this.justified = false,
    this.vertical = false,
    this.dropdown,
    super.key,
  });

  /// Accessible name of the navigation.
  final String label;
  final List<NavDemoItem> items;
  final NavDemoVariant variant;

  /// Id of the item that starts current (none when null).
  final String? initialActive;

  /// Items grow to fill the row, keeping their own widths (rows wrap).
  final bool fill;

  /// Items share the row in equal widths.
  final bool justified;

  /// Stacks the items.
  final bool vertical;
  final NavDemoDropdown? dropdown;

  @override
  State<NavDemo> createState() => _NavDemoState();
}

class _NavDemoState extends State<NavDemo> {
  late String? _active = widget.initialActive;

  void _select(String id) => setState(() => _active = id);

  Widget _item(
    NavDemoItem item, {
    bool center = false,
    bool wrap = false,
    double? textWidth,
    EdgeInsets padding = _itemPadding,
  }) => _NavButton(
    variant: widget.variant,
    label: item.label,
    icon: item.icon,
    active: _active == item.id,
    disabled: item.disabled,
    center: center,
    wrap: wrap,
    textWidth: textWidth,
    padding: padding,
    onTap: () => _select(item.id),
  );

  /// Equal widths: labels wrap between words, and a word too long for its share shrinks a little
  /// instead of breaking.
  Widget _justified(BuildContext context) {
    final style = _measureStyle(context);
    final scaler = MediaQuery.textScalerOf(context);
    final items = widget.items;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = (constraints.maxWidth - _gap * (items.length - 1)) / items.length;
        final room = cell - _justifiedPadding.horizontal;
        double? fit(String label) {
          final widest = label
              .split(' ')
              .map((word) => _measure(word, style, scaler))
              .fold<double>(0, (max, width) => width > max ? width : max);
          return widest > room ? widest : null;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, item) in items.indexed) ...[
                if (index > 0) const SizedBox(width: _gap),
                Expanded(
                  child: _item(
                    item,
                    center: true,
                    wrap: true,
                    textWidth: item.icon == null ? fit(item.label) : null,
                    padding: _justifiedPadding,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.variant == NavDemoVariant.tabs && !widget.vertical;
    final dropdown = widget.dropdown;
    final trailing = dropdown == null
        ? null
        : _NavDropdown(
            variant: widget.variant,
            dropdown: dropdown,
            active: _active == _dropdownId,
            onSelected: () => _select(_dropdownId),
          );

    final Widget body;
    if (widget.vertical) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, item) in widget.items.indexed) ...[
            if (index > 0) const SizedBox(height: _gap),
            _item(item),
          ],
          if (trailing != null) ...[const SizedBox(height: _gap), trailing],
        ],
      );
    } else if (widget.justified) {
      body = _justified(context);
    } else if (widget.fill) {
      body = _FillRows(items: widget.items, variant: widget.variant, itemBuilder: _item);
    } else if (tabs) {
      // A phone is too narrow for a row of tabs: they scroll sideways instead of wrapping.
      body = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (index, item) in widget.items.indexed) ...[
              if (index > 0) const SizedBox(width: _gap),
              _item(item),
            ],
            if (trailing != null) ...[const SizedBox(width: _gap), trailing],
          ],
        ),
      );
    } else {
      body = Wrap(
        spacing: _gap,
        runSpacing: _gap,
        children: [for (final item in widget.items) _item(item), ?trailing],
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      // Filled tabs draw a rule under each of their rows.
      child: tabs && !widget.fill ? _TabRule(child: body) : body,
    );
  }
}

/// The rule under a row of tabs; the current tab covers it so it joins the content below.
class _TabRule extends StatelessWidget {
  const _TabRule({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(height: 1, color: context.colors.ink300),
      ),
      child,
    ],
  );
}

/// `flex-wrap` with `flex: auto`: items keep their natural widths, wrap when they don't fit,
/// and each row's spare room is shared among its items. Tabs get a rule under each row.
class _FillRows extends StatelessWidget {
  const _FillRows({required this.items, required this.variant, required this.itemBuilder});

  final List<NavDemoItem> items;
  final NavDemoVariant variant;
  final Widget Function(NavDemoItem item, {bool center, bool wrap}) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final style = _measureStyle(context);
    final scaler = MediaQuery.textScalerOf(context);
    final widths = [
      for (final item in items)
        (item.icon != null ? 16.0 : _measure(item.label, style, scaler)) + _itemPadding.horizontal,
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = fillRows(widths, constraints.maxWidth, gap: _gap);
        var next = 0;
        final children = <Widget>[];
        for (final (rowIndex, row) in rows.indexed) {
          if (rowIndex > 0) {
            children.add(const SizedBox(height: _gap));
          }
          final cells = <Widget>[];
          for (final (index, width) in row.indexed) {
            if (index > 0) {
              cells.add(const SizedBox(width: _gap));
            }
            cells.add(
              SizedBox(width: width, child: itemBuilder(items[next++], center: true, wrap: true)),
            );
          }
          final line = IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
          );
          children.add(variant == NavDemoVariant.tabs ? _TabRule(child: line) : line);
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.variant,
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
    this.disabled = false,
    this.center = false,
    this.wrap = false,
    this.textWidth,
    this.padding = _itemPadding,
    this.trailing,
    this.dropdownOpen,
  });

  final NavDemoVariant variant;
  final String label;
  final IconData? icon;
  final bool active;
  final bool disabled;
  final bool center;
  final bool wrap;

  /// Lays the label out at this width and scales it down to fit (a word too long for the item).
  final double? textWidth;
  final EdgeInsets padding;
  final VoidCallback onTap;

  /// Shown after the label (the dropdown's chevron).
  final Widget? trailing;

  /// Whether the dropdown this button opens is open; null for a plain item.
  final bool? dropdownOpen;

  static TextStyle textStyle({required bool active}) =>
      TextStyle(fontSize: 15, fontWeight: active ? FontWeight.w600 : FontWeight.w500, height: 1.3);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final link = scheme.primary;
    const radius = Radius.circular(Radii.md);

    final (Color foreground, Color? background) = switch ((variant, active && !disabled)) {
      _ when disabled => (colors.ink400, null),
      (NavDemoVariant.plain, true) => (colors.ink950, null),
      (NavDemoVariant.tabs, true) => (colors.ink950, colors.paperCard),
      (NavDemoVariant.pills, true) => (colors.folderInk, colors.folder),
      _ => (link, dropdownOpen == true ? colors.ink100 : null),
    };
    final borderRadius = variant == NavDemoVariant.tabs
        ? const BorderRadius.vertical(top: radius)
        : const BorderRadius.all(radius);
    final tabBorder = variant == NavDemoVariant.tabs && active && !disabled
        ? Border(
            top: BorderSide(color: colors.ink300),
            left: BorderSide(color: colors.ink300),
            right: BorderSide(color: colors.ink300),
          )
        : null;

    final text = Text(
      label,
      textAlign: center ? TextAlign.center : TextAlign.start,
      maxLines: wrap ? null : 1,
      softWrap: wrap,
      style: textStyle(
        active: active && !disabled && variant == NavDemoVariant.plain,
      ).copyWith(color: foreground),
    );
    final content = Row(
      mainAxisSize: center ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (icon != null)
          Icon(icon, size: 16, color: foreground)
        else if (textWidth != null)
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(width: textWidth, child: text),
            ),
          )
        else if (wrap)
          Flexible(child: text)
        else
          text,
        if (trailing != null) ...[
          const SizedBox(width: 6),
          IconTheme.merge(
            data: IconThemeData(color: foreground, size: 16),
            child: trailing!,
          ),
        ],
      ],
    );

    Widget button = Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          color: background,
          border: tabBorder,
          borderRadius: borderRadius,
        ),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: borderRadius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _itemHeight, minWidth: _itemHeight),
            child: Padding(
              padding: padding.add(const EdgeInsets.symmetric(vertical: Space.xs)),
              child: Align(
                alignment: center ? Alignment.center : AlignmentDirectional.centerStart,
                widthFactor: center ? null : 1,
                heightFactor: 1,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
    if (icon != null) {
      button = Tooltip(message: label, excludeFromSemantics: true, child: button);
    }
    return Semantics(
      container: true,
      button: true,
      enabled: !disabled,
      selected: active,
      expanded: dropdownOpen,
      label: icon != null ? label : null,
      child: button,
    );
  }
}

class _NavDropdown extends StatefulWidget {
  const _NavDropdown({
    required this.variant,
    required this.dropdown,
    required this.active,
    required this.onSelected,
  });

  final NavDemoVariant variant;
  final NavDemoDropdown dropdown;
  final bool active;
  final VoidCallback onSelected;

  @override
  State<_NavDropdown> createState() => _NavDropdownState();
}

class _NavDropdownState extends State<_NavDropdown> {
  final _controller = MenuController();
  bool _open = false;

  @override
  Widget build(BuildContext context) => MenuAnchor(
    controller: _controller,
    onOpen: () => setState(() => _open = true),
    onClose: () => setState(() => _open = false),
    alignmentOffset: const Offset(0, Space.xs),
    menuChildren: [
      for (final (index, group) in widget.dropdown.groups.indexed) ...[
        if (index > 0) const Divider(),
        for (final entry in group)
          MenuItemButton(
            onPressed: widget.onSelected,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 128),
              child: Text(entry),
            ),
          ),
      ],
    ],
    child: _NavButton(
      variant: widget.variant,
      label: widget.dropdown.label,
      active: widget.active,
      dropdownOpen: _open,
      trailing: const Icon(LucideIcons.chevronDown),
      onTap: () => _controller.isOpen ? _controller.close() : _controller.open(),
    ),
  );
}
