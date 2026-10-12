import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';

/// A form row: the printed label (with an optional aside such as "Optional"), then the control.
/// Hints and errors go in the control's own `InputDecoration` (`helperText` / `errorText`) so
/// screen readers announce them with the field.
class LabeledField extends StatelessWidget {
  const LabeledField({required this.label, required this.child, this.aside, super.key});

  final String label;
  final String? aside;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ExcludeSemantics(
          child: Row(
            children: [
              Expanded(child: Text(label, style: context.text.titleSmall)),
              if (aside != null) Text(aside!, style: context.text.bodySmall),
            ],
          ),
        ),
      ),
      // The printed label above is hidden from screen readers; the control carries it instead.
      Semantics(label: label, child: child),
    ],
  );
}

/// A primary button that shows a spinner and ignores taps while [busy].
class BusyButton extends StatelessWidget {
  const BusyButton({
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (busy)
          SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.ink600,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if (busy || icon != null) const SizedBox(width: Space.sm),
        Text(label),
      ],
    ),
  );
}
