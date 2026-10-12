import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_colors.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';

/// A ruled list of rows on a white sheet; [flush] drops the outer frame so it sits edge to edge
/// inside a card.
class ListGroup extends StatelessWidget {
  const ListGroup({required this.children, this.label, this.flush = false, super.key});

  /// [ListGroupItem]s.
  final List<Widget> children;

  /// Accessible name of the list.
  final String? label;
  final bool flush;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rule = BorderSide(color: colors.ink200);
    final radius = BorderRadius.circular(flush ? 0 : Radii.sm);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.ply,
          border: flush ? Border.symmetric(horizontal: rule) : Border.fromBorderSide(rule),
          borderRadius: radius,
          boxShadow: flush ? null : plyShadow(context),
        ),
        child: Padding(
          padding: flush ? const EdgeInsets.symmetric(vertical: 1) : const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: radius,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, child) in children.indexed) ...[
                    if (index > 0) Divider(color: colors.ink200),
                    child,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One row of a [ListGroup]: plain, or a link when [onTap] is set. [active] marks the current
/// row (folder green), [disabled] greys it out and stops taps, [tone] washes it in a tone.
class ListGroupItem extends StatelessWidget {
  const ListGroupItem({
    required this.child,
    this.onTap,
    this.active = false,
    this.disabled = false,
    this.tone,
    this.link = true,
    this.padding = const EdgeInsets.symmetric(horizontal: Space.page, vertical: Space.md),
    super.key,
  });

  final Widget child;

  /// Turns the row into a link (or a button when [link] is false).
  final VoidCallback? onTap;
  final bool active;
  final bool disabled;
  final Tone? tone;

  /// Announces a tappable row as a link rather than a button.
  final bool link;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final toneColors = tone == null ? null : ToneColors.of(context, tone!);
    final interactive = onTap != null;
    final Color? background = active ? colors.folder : toneColors?.softBackground;
    final foreground = active
        ? colors.folderInk
        : disabled
        ? colors.ink400
        : toneColors?.softText ?? colors.ink900;
    final content = Padding(
      padding: padding,
      child: DefaultTextStyle.merge(
        style: context.text.bodyMedium?.copyWith(color: foreground),
        child: child,
      ),
    );
    final Widget row;
    if (interactive && !disabled) {
      final pressed = toneColors?.softPressed ?? colors.paperCard;
      row = InkWell(
        onTap: onTap,
        overlayColor: WidgetStateProperty.resolveWith(
          (states) =>
              !active &&
                  (states.contains(WidgetState.pressed) || states.contains(WidgetState.focused))
              ? pressed
              : null,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: double.infinity),
          child: content,
        ),
      );
    } else {
      row = content;
    }
    return Semantics(
      container: true,
      link: interactive && link,
      button: interactive && !link,
      // A link marks the current page; a button row says whether it is the selected one.
      selected: interactive ? (link ? (active ? true : null) : active) : null,
      enabled: interactive || disabled ? !disabled : null,
      // `Ink` paints on the list's Material, so the press ripple shows over the fill.
      child: Ink(color: background, child: row),
    );
  }
}

/// One button of a [ButtonListGroup].
typedef ButtonListEntry = ({String id, String label, bool disabled});

/// A list group made of buttons: pressing one selects it (shown as the active row).
class ButtonListGroup extends StatefulWidget {
  const ButtonListGroup({required this.label, required this.items, super.key});

  /// Accessible name of the list.
  final String label;
  final List<ButtonListEntry> items;

  @override
  State<ButtonListGroup> createState() => _ButtonListGroupState();
}

class _ButtonListGroupState extends State<ButtonListGroup> {
  String? _selected;

  @override
  Widget build(BuildContext context) => ListGroup(
    label: widget.label,
    children: [
      for (final item in widget.items)
        ListGroupItem(
          link: false,
          active: _selected == item.id,
          disabled: item.disabled,
          onTap: () => setState(() => _selected = item.id),
          child: Text(item.label),
        ),
    ],
  );
}
