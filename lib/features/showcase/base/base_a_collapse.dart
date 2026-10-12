import 'dart:async';

import 'package:flutter/material.dart';

/// Content that slides open and shut in place (the web's `CollapsibleContent`). Closed content
/// leaves the tree, so screen readers skip it and nested state starts over, as on the web.
class Collapse extends StatefulWidget {
  const Collapse({required this.open, required this.child, super.key});

  final bool open;
  final Widget child;

  @override
  State<Collapse> createState() => _CollapseState();
}

class _CollapseState extends State<Collapse> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: widget.open ? 1 : 0,
  );
  late final _size = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void didUpdateWidget(Collapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open == oldWidget.open) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.open ? 1 : 0;
    } else {
      unawaited(widget.open ? _controller.forward() : _controller.reverse());
    }
  }

  @override
  void dispose() {
    _size.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => _controller.isDismissed
        ? const SizedBox(width: double.infinity)
        : ExcludeSemantics(
            excluding: !widget.open,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _size.value,
                child: child,
              ),
            ),
          ),
    child: widget.child,
  );
}
