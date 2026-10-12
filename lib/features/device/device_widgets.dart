import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';

/// A label and its value on one row, for readings and device facts.
class ValueRow extends StatelessWidget {
  const ValueRow({required this.label, required this.value, this.hint, super.key});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.text.titleSmall),
                if (hint != null) Text(hint!, style: context.text.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.type.table.copyWith(fontSize: 15, color: context.colors.ink950),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Three axis readings (x, y, z) side by side.
class AxisReadings extends StatelessWidget {
  const AxisReadings({required this.values, this.digits = 2, super.key});

  /// Null while waiting for the first sample.
  final (double, double, double)? values;
  final int digits;

  @override
  Widget build(BuildContext context) {
    final readings = values;
    // Noise around zero would print as "-0.00".
    String format(double value) => (value.abs() < 0.005 ? 0.0 : value).toStringAsFixed(digits);
    return Row(
      children: [
        for (final (axis, value) in [
          ('x', readings?.$1),
          ('y', readings?.$2),
          ('z', readings?.$3),
        ])
          Expanded(
            child: Semantics(
              label: '$axis ${value == null ? '' : format(value)}',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormLabel(axis),
                  const SizedBox(height: Space.xs),
                  Text(
                    value == null ? '—' : format(value),
                    style: context.type.figure.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A message under a demo: what went wrong and, when the fix is in system settings, a button.
class DeviceNotice extends StatelessWidget {
  const DeviceNotice({required this.message, this.action, this.error = false, super.key});

  final String message;
  final Widget? action;
  final bool error;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: context.text.bodyMedium?.copyWith(
            color: error ? context.colors.pen : context.colors.ink600,
          ),
        ),
        if (action != null) ...[const SizedBox(height: Space.sm), action!],
      ],
    ),
  );
}
