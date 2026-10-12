import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_placements.dart';

export 'package:flutter_boilerplate/features/showcase/base/base_b_placements.dart';

/// The name of a placement (the web's `BasePlacements` namespace).
String placementName(AppLocalizations l10n, Placement placement) =>
    switch ((placement.side, placement.align)) {
      (PlacementSide.top, PlacementAlign.start) => l10n.basePlacementsTopStart,
      (PlacementSide.top, PlacementAlign.center) => l10n.basePlacementsTopCenter,
      (PlacementSide.top, PlacementAlign.end) => l10n.basePlacementsTopEnd,
      (PlacementSide.bottom, PlacementAlign.start) => l10n.basePlacementsBottomStart,
      (PlacementSide.bottom, PlacementAlign.center) => l10n.basePlacementsBottomCenter,
      (PlacementSide.bottom, PlacementAlign.end) => l10n.basePlacementsBottomEnd,
      (PlacementSide.right, PlacementAlign.start) => l10n.basePlacementsRightStart,
      (PlacementSide.right, PlacementAlign.center) => l10n.basePlacementsRightCenter,
      (PlacementSide.right, PlacementAlign.end) => l10n.basePlacementsRightEnd,
      (PlacementSide.left, PlacementAlign.start) => l10n.basePlacementsLeftStart,
      (PlacementSide.left, PlacementAlign.center) => l10n.basePlacementsLeftCenter,
      (PlacementSide.left, PlacementAlign.end) => l10n.basePlacementsLeftEnd,
    };

/// Where a trigger sits in its row so that its popover or tooltip has room on a phone: at the
/// start for boxes that open on the right, at the end for the left, centred otherwise.
Alignment placementTriggerAlignment(Placement placement) => switch (placement.side) {
  PlacementSide.right => Alignment.centerLeft,
  PlacementSide.left => Alignment.centerRight,
  PlacementSide.top || PlacementSide.bottom => Alignment.center,
};

/// A button that opens a popover with a title and a line of content (the web's `DemoPopover`).
/// A tap on the button toggles it; a tap anywhere else closes it. One that starts open shows
/// once the screen is laid out.
class DemoPopover extends StatefulWidget {
  const DemoPopover({
    required this.label,
    required this.title,
    required this.content,
    this.placement = placementBottom,
    this.initiallyOpen = false,
    super.key,
  });

  /// Button text.
  final String label;
  final String title;

  /// The popover's text (a [Text] or a [RichMessage]).
  final Widget content;

  /// Side and alignment around the button.
  final Placement placement;
  final bool initiallyOpen;

  @override
  State<DemoPopover> createState() => _DemoPopoverState();
}

class _DemoPopoverState extends State<DemoPopover> {
  final _controller = OverlayPortalController();

  /// Taps on the button and on the popover count as inside each other.
  final _group = Object();

  @override
  void initState() {
    super.initState();
    if (widget.initiallyOpen) {
      _controller.show();
    }
  }

  void _toggle() => setState(_controller.toggle);

  void _close() {
    if (_controller.isShowing) {
      setState(_controller.hide);
    }
  }

  @override
  Widget build(BuildContext context) => OverlayPortal.overlayChildLayoutBuilder(
    controller: _controller,
    overlayChildBuilder: (context, info) {
      if (info.childPaintTransform.determinant() == 0) {
        return const SizedBox.shrink();
      }
      final target = MatrixUtils.transformRect(
        info.childPaintTransform,
        Offset.zero & info.childSize,
      );
      return Positioned.fill(
        child: CustomSingleChildLayout(
          delegate: _PopoverLayout(target: target, placement: widget.placement),
          child: TapRegion(
            groupId: _group,
            onTapOutside: (_) => _close(),
            child: _PopoverPanel(title: widget.title, content: widget.content),
          ),
        ),
      );
    },
    child: TapRegion(
      groupId: _group,
      child: Semantics(
        expanded: _controller.isShowing,
        child: FilledButton(onPressed: _toggle, child: Text(widget.label)),
      ),
    ),
  );
}

/// Places the popover next to its button: 240 pt wide (`w-60`), narrower beside the button
/// when that is all the room there is, flipped and shifted to stay on screen.
class _PopoverLayout extends SingleChildLayoutDelegate {
  _PopoverLayout({required this.target, required this.placement});

  final Rect target;
  final Placement placement;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final bounds = constraints.biggest;
    final width = fitWidth(target: target, bounds: bounds, placement: placement, preferred: 240);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: math.max(0, bounds.height - 16),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) => placeBox(
    target: target,
    size: childSize,
    bounds: size,
    placement: placement,
  );

  @override
  bool shouldRelayout(_PopoverLayout oldDelegate) =>
      oldDelegate.target != target || oldDelegate.placement != placement;
}

class _PopoverPanel extends StatelessWidget {
  const _PopoverPanel({required this.title, required this.content});

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 120),
      builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
      child: Semantics(
        container: true,
        role: SemanticsRole.dialog,
        explicitChildNodes: true,
        child: Material(
          color: colors.ply,
          elevation: 4,
          shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
            side: BorderSide(color: colors.ink200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall?.copyWith(color: colors.ink950)),
                const SizedBox(height: 6),
                DefaultTextStyle.merge(
                  style: context.text.bodySmall?.copyWith(color: colors.ink600),
                  child: content,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A Material [Tooltip] around any trigger (the web's `DemoTooltip`), placed on any side and
/// alignment. A long press shows it, as for every tooltip on a phone; the trigger can also show
/// it from a tap with the `show` callback the [builder] gets. One that starts open shows once
/// the screen is laid out; a touch anywhere hides it.
class DemoTooltip extends StatefulWidget {
  const DemoTooltip({
    required this.message,
    required this.builder,
    this.placement = placementTop,
    this.initiallyOpen = false,
    super.key,
  });

  final String message;

  /// Builds the trigger. `show` opens the tooltip until the next touch.
  final Widget Function(BuildContext context, VoidCallback show) builder;
  final Placement placement;
  final bool initiallyOpen;

  @override
  State<DemoTooltip> createState() => _DemoTooltipState();
}

class _DemoTooltipState extends State<DemoTooltip> {
  final _key = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();
    if (widget.initiallyOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _show();
        }
      });
    }
  }

  void _show() => _key.currentState?.ensureTooltipVisible();

  @override
  Widget build(BuildContext context) => Tooltip(
    key: _key,
    message: widget.message,
    positionDelegate: (context) => placeBox(
      target: Rect.fromCenter(
        center: context.target,
        width: context.targetSize.width,
        height: context.targetSize.height,
      ),
      size: context.tooltipSize,
      bounds: context.overlaySize,
      placement: widget.placement,
    ),
    child: Builder(builder: (context) => widget.builder(context, _show)),
  );
}
