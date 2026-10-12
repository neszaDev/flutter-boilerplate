import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

final _docs = Uri.parse('https://github.com/jogboms/flutter_spinkit');

/// The SpinKit loaders, in the Vue demo's order.
enum SpinKitLoader {
  plane,
  bounce,
  wave,
  wander,
  pulse,
  chase,
  swing,
  flow,
  circle,
  grid,
  circleFade,
  fold,
}

String _loaderName(AppLocalizations l10n, SpinKitLoader loader) => switch (loader) {
  SpinKitLoader.plane => l10n.spinnersPageLoaderPlane,
  SpinKitLoader.bounce => l10n.spinnersPageLoaderBounce,
  SpinKitLoader.wave => l10n.spinnersPageLoaderWave,
  SpinKitLoader.wander => l10n.spinnersPageLoaderWander,
  SpinKitLoader.pulse => l10n.spinnersPageLoaderPulse,
  SpinKitLoader.chase => l10n.spinnersPageLoaderChase,
  SpinKitLoader.swing => l10n.spinnersPageLoaderSwing,
  SpinKitLoader.flow => l10n.spinnersPageLoaderFlow,
  SpinKitLoader.circle => l10n.spinnersPageLoaderCircle,
  SpinKitLoader.grid => l10n.spinnersPageLoaderGrid,
  SpinKitLoader.circleFade => l10n.spinnersPageLoaderCircleFade,
  SpinKitLoader.fold => l10n.spinnersPageLoaderFold,
};

/// `/dashboard/plugins/spinners`: the base spinners and the SpinKit set. Every loader stands
/// still when the phone asks for reduced motion.
class SpinnersScreen extends StatelessWidget {
  const SpinnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return AppPage(
      title: l10n.spinnersPageTitle,
      description: Text(l10n.spinnersPageDescription),
      children: [
        DemoCard(
          title: l10n.spinnersPageBaseTitle,
          description: l10n.spinnersPageBaseDescription,
          child: Wrap(
            spacing: Space.lg,
            runSpacing: Space.lg,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _RingSpinner(size: 16, color: colors.primary),
              _RingSpinner(size: 32, color: colors.ink700),
              _RingSpinner(size: 64, color: colors.ink950),
              _GrowSpinner(size: 16, color: colors.ink600),
              _GrowSpinner(size: 32, color: colors.primary),
              _GrowSpinner(size: 64, color: colors.ink950),
            ],
          ),
        ),
        DemoCard(
          title: l10n.spinnersPageSpinkitTitle,
          action: TextButton.icon(
            onPressed: () => unawaited(launchUrl(_docs, mode: LaunchMode.externalApplication)),
            icon: const Icon(LucideIcons.externalLink, size: 16),
            iconAlignment: IconAlignment.end,
            label: Text(l10n.spinnersPageDocs),
          ),
          child: Text(
            l10n.spinnersPageSpinkitText,
            style: context.text.bodyMedium?.copyWith(color: colors.ink700),
          ),
        ),
        const _LoaderGrid(),
      ],
    );
  }
}

/// One card per SpinKit loader, two or three to a row.
class _LoaderGrid extends StatelessWidget {
  const _LoaderGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 3 : 2;
        const gap = Space.page;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final loader in SpinKitLoader.values)
              SizedBox(
                width: width,
                child: DemoCard(
                  title: _loaderName(l10n, loader),
                  child: SizedBox(
                    height: 88,
                    child: Center(child: SpinKitDemo(loader: loader)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A SpinKit loader in folder green, 40 pt. Decorative: its card names it. Under reduced motion
/// it shows one still frame.
class SpinKitDemo extends StatelessWidget {
  const SpinKitDemo({required this.loader, super.key});

  final SpinKitLoader loader;

  static const size = 40.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;
    final still = MediaQuery.disableAnimationsOf(context);
    final Widget spinner = switch (loader) {
      // These two start from nothing; their still frame is drawn here.
      SpinKitLoader.pulse when still => _StillPulse(color: color),
      SpinKitLoader.fold when still => _StillFold(color: color),
      SpinKitLoader.plane => SpinKitRotatingPlain(color: color, size: size),
      SpinKitLoader.bounce => SpinKitDoubleBounce(color: color, size: size),
      SpinKitLoader.wave => SpinKitWave(color: color, size: size),
      SpinKitLoader.wander => SpinKitWanderingCubes(color: color, size: size),
      SpinKitLoader.pulse => SpinKitPulse(color: color, size: size),
      // SpinKit 2's six chasing dots; flutter_spinkit has only the older two-dot version, which
      // is SpinKit 2's "swing".
      SpinKitLoader.chase => _ChasingDots(color: color),
      SpinKitLoader.swing => SpinKitChasingDots(color: color, size: size),
      SpinKitLoader.flow => SpinKitThreeBounce(color: color, size: size * 0.65),
      SpinKitLoader.circle => SpinKitCircle(color: color, size: size),
      SpinKitLoader.grid => SpinKitCubeGrid(color: color, size: size),
      SpinKitLoader.circleFade => SpinKitFadingCircle(color: color, size: size),
      SpinKitLoader.fold => SpinKitFoldingCube(color: color, size: size * 0.8),
    };
    return ExcludeSemantics(
      // A disabled ticker freezes the loader on its first frame.
      child: TickerMode(enabled: !still, child: spinner),
    );
  }
}

/// The border spinner (Material's ring), announced as loading.
class _RingSpinner extends StatelessWidget {
  const _RingSpinner({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        // A still three-quarter ring under reduced motion.
        value: MediaQuery.disableAnimationsOf(context) ? 0.75 : null,
        strokeWidth: math.max(2, size / 12),
        color: color,
        backgroundColor: Colors.transparent,
        semanticsLabel: context.l10n.spinnersPageLoading,
      ),
    ),
  );
}

/// The "grow" spinner: a dot that swells and fades (CoreUI's `spinner-grow`), announced as
/// loading. A full dot under reduced motion.
class _GrowSpinner extends StatefulWidget {
  const _GrowSpinner({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<_GrowSpinner> createState() => _GrowSpinnerState();
}

class _GrowSpinnerState extends State<_GrowSpinner> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: context.l10n.spinnersPageLoading,
    child: SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // 0 → 50 %: swells from nothing and appears; 50 → 100 %: fades out at full size.
          final t = _controller.value;
          final scale = t < 0.5 ? t * 2 : 1.0;
          final opacity = t < 0.5 ? t * 2 : 2 - t * 2;
          return Opacity(
            opacity: opacity.clamp(0, 1),
            child: Transform.scale(
              scale: scale,
              child: DecoratedBox(
                decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
              ),
            ),
          );
        },
      ),
    ),
  );
}

/// SpinKit 2's "chase": six dots that run round the circle one after another, shrinking half
/// way, while the whole circle turns.
class _ChasingDots extends StatefulWidget {
  const _ChasingDots({required this.color});

  final Color color;

  @override
  State<_ChasingDots> createState() => _ChasingDotsState();
}

class _ChasingDotsState extends State<_ChasingDots> with SingleTickerProviderStateMixin {
  // 10 s holds a whole number of turns (2.5 s) and dot cycles (2 s).
  late final _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: SpinKitDemo.size,
    child: CustomPaint(
      painter: _ChasePainter(progress: _controller, color: widget.color),
    ),
  );
}

class _ChasePainter extends CustomPainter {
  _ChasePainter({required this.progress, required this.color}) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;

  static const _dots = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final seconds = progress.value * 10;
    final turn = (seconds % 2.5) / 2.5 * 2 * math.pi;
    final paint = Paint()..color = color;
    final center = size.center(Offset.zero);
    final radius = size.width * 0.125;
    for (var index = 0; index < _dots; index++) {
      // Each dot runs 0.1 s behind the one before it (the CSS `animation-delay`).
      final phase = ((seconds - 1.1 + index * 0.1) % 2) / 2;
      final travel = phase < 0.8 ? Curves.easeInOut.transform(phase / 0.8) : 1.0;
      final scale = phase < 0.5
          ? 1 - 0.6 * Curves.easeInOut.transform(phase / 0.5)
          : 0.4 + 0.6 * Curves.easeInOut.transform((phase - 0.5) / 0.5);
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(turn + travel * 2 * math.pi)
        // The dot sits in the top-left corner of its turning square.
        ..drawCircle(Offset(radius - center.dx, radius - center.dy), radius * scale, paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ChasePainter old) => old.color != color;
}

/// The pulse at rest: a full dot.
class _StillPulse extends StatelessWidget {
  const _StillPulse({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: SpinKitDemo.size,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

/// The folding cube at rest: four squares turned on a corner.
class _StillFold extends StatelessWidget {
  const _StillFold({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    // The same 32 pt square as the moving cube: four 15 pt cubes 2 pt apart.
    const cube = SpinKitDemo.size * 0.8 / 2;
    final square = SizedBox.square(
      dimension: cube - 1,
      child: ColoredBox(color: color),
    );
    return Transform.rotate(
      angle: math.pi / 4,
      child: SizedBox.square(
        dimension: cube * 2,
        child: Wrap(spacing: 2, runSpacing: 2, children: [square, square, square, square]),
      ),
    );
  }
}
