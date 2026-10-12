import 'package:flutter/material.dart';

/// The web app's `secondary` button: a filled button on the light ink wash.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({required this.onPressed, required this.child, super.key});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
