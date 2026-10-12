import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_data.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_logic.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _slides = CarouselSlide.values;
const _slideMove = Duration(milliseconds: 450);

/// The Vue carousel: three slides (two with captions, one with a picture), arrows, indicators
/// and autoplay. It loops both ways and can be swiped. Autoplay holds while a finger is on the
/// slides or focus is inside, can be stopped with its own button, and is off by default when
/// the phone asks for reduced motion.
class DemoCarousel extends StatefulWidget {
  const DemoCarousel({required this.picture, super.key});

  /// The picture on the third slide.
  final Widget picture;

  @override
  State<DemoCarousel> createState() => _DemoCarouselState();
}

class _DemoCarouselState extends State<DemoCarousel> {
  final _controller = PageController(initialPage: carouselStartPage(_slides.length));
  late int _page = carouselStartPage(_slides.length);
  bool _held = false;
  bool? _choice;
  Timer? _timer;

  int get _selected => carouselSlideOf(_page, _slides.length);

  bool get _reducedMotion => MediaQuery.disableAnimationsOf(context);

  bool get _playing => _choice ?? !_reducedMotion;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Runs the autoplay timer while playing and not held; any change restarts the interval.
  void _syncTimer() {
    _timer?.cancel();
    _timer = _playing && !_held ? Timer.periodic(carouselInterval, (_) => _next()) : null;
  }

  void _goTo(int page) {
    if (!_controller.hasClients) {
      return;
    }
    if (_reducedMotion) {
      _controller.jumpToPage(page);
    } else {
      unawaited(_controller.animateToPage(page, duration: _slideMove, curve: Curves.easeOutCubic));
    }
  }

  void _next() => _goTo(_page + 1);

  void _previous() => _goTo(_page - 1);

  void _setHeld(bool held) {
    if (held != _held) {
      setState(() => _held = held);
      _syncTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final count = _slides.length;
    final onDark = _slides[_selected] == CarouselSlide.first;
    final playing = _playing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          explicitChildNodes: true,
          label: l10n.carouselsPageCarouselLabel,
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: _setHeld,
            child: Listener(
              onPointerDown: (_) => _setHeld(true),
              onPointerUp: (_) => _setHeld(false),
              onPointerCancel: (_) => _setHeld(false),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Radii.lg),
                child: SizedBox(
                  height: 256,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _controller,
                        onPageChanged: (page) => setState(() => _page = page),
                        itemBuilder: (context, page) {
                          final index = carouselSlideOf(page, count);
                          return Semantics(
                            container: true,
                            label: l10n.carouselsPageSlideLabel('${index + 1}', '$count'),
                            child: _Slide(slide: _slides[index], picture: widget.picture),
                          );
                        },
                      ),
                      Positioned(
                        left: Space.md,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _Arrow(
                            icon: LucideIcons.chevronLeft,
                            tooltip: l10n.carouselsPagePrevious,
                            onPressed: _previous,
                          ),
                        ),
                      ),
                      Positioned(
                        right: Space.md,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _Arrow(
                            icon: LucideIcons.chevronRight,
                            tooltip: l10n.carouselsPageNext,
                            onPressed: _next,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var index = 0; index < count; index++)
                              _Indicator(
                                label: l10n.carouselsPageGoTo('${index + 1}'),
                                current: index == _selected,
                                onDark: onDark,
                                onTap: () => _goTo(
                                  carouselPageFor(from: _page, slide: index, count: count),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            Expanded(
              child: Semantics(
                liveRegion: !playing,
                child: Text(
                  l10n.carouselsPageSlideLabel('${_selected + 1}', '$count'),
                  style: context.text.bodySmall?.copyWith(color: colors.ink600, fontSize: 14),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _choice = !playing);
                _syncTimer();
              },
              icon: Icon(playing ? LucideIcons.pause : LucideIcons.play, size: 16),
              label: Text(playing ? l10n.carouselsPagePause : l10n.carouselsPagePlay),
            ),
          ],
        ),
      ],
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide, required this.picture});

  final CarouselSlide slide;
  final Widget picture;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final (background, foreground) = switch (slide) {
      CarouselSlide.first => (colors.folder, colors.folderInk),
      CarouselSlide.blank => (colors.ink200, colors.ink950),
      CarouselSlide.logo => (colors.paperCard, colors.ink950),
    };
    final caption = switch (slide) {
      CarouselSlide.first => (l10n.carouselsPageSlideFirstTitle, l10n.carouselsPageSlideFirstText),
      CarouselSlide.blank => (l10n.carouselsPageSlideBlankTitle, l10n.carouselsPageSlideBlankText),
      CarouselSlide.logo => null,
    };
    return ColoredBox(
      color: background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (slide == CarouselSlide.first)
            ExcludeSemantics(
              child: CustomPaint(
                painter: _RulePainter(colors.folderInk.withValues(alpha: 0.14)),
              ),
            ),
          if (slide == CarouselSlide.logo)
            Center(
              child: FractionallySizedBox(heightFactor: 0.8, child: picture),
            ),
          if (caption != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(56, 0, 56, 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      caption.$1,
                      textAlign: TextAlign.center,
                      style: context.text.headlineSmall?.copyWith(
                        color: foreground,
                        fontSize: 20,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      caption.$2,
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ruled lines every 32 pt, like the card stock of the cover.
class _RulePainter extends CustomPainter {
  _RulePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = 31.0; y < size.height; y += 32) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_RulePainter old) => old.color != color;
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton.outlined(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: colors.ply,
        foregroundColor: colors.ink900,
        side: BorderSide(color: colors.ink300),
      ),
      icon: Icon(icon, size: 18),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.label,
    required this.current,
    required this.onDark,
    required this.onTap,
  });

  final String label;
  final bool current;
  final bool onDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = switch ((onDark, current)) {
      (true, true) => colors.folderInk,
      (true, false) => colors.folderInk.withValues(alpha: 0.45),
      (false, true) => colors.ink950,
      (false, false) => colors.ink400,
    };
    return Semantics(
      button: true,
      selected: current,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 4,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ),
      ),
    );
  }
}
