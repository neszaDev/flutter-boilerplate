import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';

/// Hand-drawn marks: a tick for passed, a pen circle for failed, a pencil box for pending.
/// The same strokes as the web app's `Mark.tsx`, on its 24×24 grid.
Path _strokeFor(TestStatus status) => switch (status) {
  TestStatus.passed =>
    Path()
      ..moveTo(3.4, 13.2)
      ..cubicTo(5.3, 14.7, 7, 16.8, 8.4, 19.5)
      ..cubicTo(11.2, 12.6, 15.4, 7.2, 20.8, 3.6),
  TestStatus.failed =>
    Path()
      ..moveTo(13.4, 3.3)
      ..cubicTo(7.4, 2.6, 3, 6.6, 3.1, 12.1)
      ..cubicTo(3.2, 17.5, 7.3, 21, 12.3, 20.8)
      ..cubicTo(17.6, 20.6, 21, 16.7, 20.8, 11.7)
      ..cubicTo(20.6, 6.9, 17, 3.6, 11.9, 3.5)
      ..cubicTo(10.4, 3.5, 9.1, 3.8, 8, 4.4),
  TestStatus.pending =>
    Path()
      ..moveTo(5.1, 5.3)
      ..lineTo(18.9, 4.9)
      ..lineTo(19.2, 18.9)
      ..lineTo(4.9, 19.2)
      ..lineTo(4.8, 5.4),
};

double _widthFor(TestStatus status) => switch (status) {
  TestStatus.passed => 2.6,
  TestStatus.failed => 2.2,
  TestStatus.pending => 1.8,
};

/// The mark for a test status. Decorative: pair it with the status text (it is excluded from
/// semantics).
class Mark extends StatefulWidget {
  const Mark({
    required this.status,
    this.size = 20,
    this.color,
    this.animate = false,
    this.delay = Duration.zero,
    super.key,
  });

  final TestStatus status;
  final double size;

  /// Overrides the status colour (e.g. on the folder-green cover).
  final Color? color;

  /// Draw the stroke on like a pen when it first appears. Static under reduced motion.
  final bool animate;
  final Duration delay;

  @override
  State<Mark> createState() => _MarkState();
}

class _MarkState extends State<Mark> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    value: widget.animate ? 0 : 1,
  );
  late final _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
  Timer? _start;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.animate || _controller.isCompleted || _start != null) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    _start = Timer(widget.delay, () {
      if (mounted) {
        unawaited(_controller.forward());
      }
    });
  }

  @override
  void dispose() {
    _start?.cancel();
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color =
        widget.color ??
        switch (widget.status) {
          TestStatus.passed => colors.pass,
          TestStatus.failed => colors.pen,
          TestStatus.pending => colors.pencil,
        };
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _MarkPainter(
            path: _strokeFor(widget.status),
            strokeWidth: _widthFor(widget.status),
            color: color,
            progress: _progress,
          ),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({
    required this.path,
    required this.strokeWidth,
    required this.color,
    required this.progress,
  }) : super(repaint: progress);

  final Path path;
  final double strokeWidth;
  final Color color;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final value = progress.value;
    if (value >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    // Draw the first `value` of the stroke's length, like the web app's `pathLength="1"` dash.
    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, metric) => sum + metric.length);
    var remaining = total * value;
    for (final metric in metrics) {
      if (remaining <= 0) {
        break;
      }
      final length = remaining.clamp(0, metric.length).toDouble();
      canvas.drawPath(metric.extractPath(0, length), paint);
      remaining -= length;
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.path != path || old.color != color || old.strokeWidth != strokeWidth;
}
