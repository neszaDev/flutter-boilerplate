import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The dashed frame around an error page preview, with the page's card inside.
class ErrorPreviewFrame extends StatelessWidget {
  const ErrorPreviewFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomPaint(
      foregroundPainter: _DashedBorder(color: colors.ink300, radius: Radii.sm),
      child: Container(
        decoration: BoxDecoration(
          color: colors.paper,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xl),
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 512),
          child: Card(
            child: Padding(padding: const EdgeInsets.all(Space.lg), child: child),
          ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dash = 6.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final outline = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(0.5));
    for (final PathMetric metric in outline.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        canvas.drawPath(metric.extractPath(start, start + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color || old.radius != radius;
}

/// The error pages' "What are you looking for?" box. In this preview nothing is searched:
/// submitting says so, with the words typed.
class ErrorPreviewSearch extends StatefulWidget {
  const ErrorPreviewSearch({super.key});

  @override
  State<ErrorPreviewSearch> createState() => _ErrorPreviewSearchState();
}

class _ErrorPreviewSearchState extends State<ErrorPreviewSearch> {
  final _query = TextEditingController();
  String? _searched;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _submit() => setState(() => _searched = _query.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final searched = _searched;
    // The visible box has no printed label; the merged label names it for screen readers.
    final field = MergeSemantics(
      child: Semantics(
        label: l10n.errorPreviewSearchLabel,
        child: TextField(
          key: const Key('errorPreview.search'),
          controller: _query,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: l10n.errorPreviewSearchPlaceholder,
            prefixIcon: Icon(LucideIcons.search, size: 18, color: colors.ink400),
          ),
        ),
      ),
    );
    final button = FilledButton(onPressed: _submit, child: Text(l10n.errorPreviewSearchSubmit));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 400
              ? Row(
                  children: [
                    Expanded(child: field),
                    const SizedBox(width: Space.sm),
                    button,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    field,
                    const SizedBox(height: Space.sm),
                    button,
                  ],
                ),
        ),
        const SizedBox(height: Space.sm),
        Semantics(
          container: true,
          liveRegion: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 20),
            child: Text(
              switch (searched) {
                null => '',
                '' => l10n.errorPreviewSearchPreviewEmpty,
                _ => l10n.errorPreviewSearchPreviewResult(searched),
              },
              style: context.text.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
