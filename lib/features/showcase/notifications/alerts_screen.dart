import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Marksheet alert tones, in place of the Bootstrap colours: a plain note, folder green, the
/// three marks (pass, pencil, red pen for errors only) and two steps of the ink ramp.
enum AlertTone { note, folder, pass, pencil, pen, muted, ink }

/// The tone's name on the page ("Primary", "Error").
String alertToneLabel(AppLocalizations l10n, AlertTone tone) => switch (tone) {
  AlertTone.note => l10n.alertsPageToneNote,
  AlertTone.folder => l10n.alertsPageToneFolder,
  AlertTone.pass => l10n.alertsPageTonePass,
  AlertTone.pencil => l10n.alertsPageTonePencil,
  AlertTone.pen => l10n.alertsPageTonePen,
  AlertTone.muted => l10n.alertsPageToneMuted,
  AlertTone.ink => l10n.alertsPageToneInk,
};

/// `/dashboard/notifications/alerts`: tones, links, longer content, dismissing and timers.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.alertsPageTitle,
      description: Text(l10n.alertsPageDescription),
      children: [
        DemoCard(
          title: l10n.alertsPageTonesTitle,
          description: l10n.alertsPageTonesDescription,
          child: _Stack(
            children: [
              for (final tone in AlertTone.values)
                ToneAlert(
                  tone: tone,
                  child: Text(l10n.alertsPageToneAlert(alertToneLabel(l10n, tone))),
                ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.alertsPageLinksTitle,
          description: l10n.alertsPageLinksDescription,
          child: _Stack(
            children: [
              for (final tone in AlertTone.values)
                ToneAlert(
                  tone: tone,
                  child: _LinkMessage(tone: tone),
                ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.alertsPageContentTitle,
          description: l10n.alertsPageContentDescription,
          child: ToneAlert(
            tone: AlertTone.pass,
            title: l10n.alertsPageContentHeading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.alertsPageContentBody),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.md),
                  child: Divider(color: context.colors.pass.withValues(alpha: 0.3)),
                ),
                Text(l10n.alertsPageContentFooter),
              ],
            ),
          ),
        ),
        DemoCard(
          title: l10n.alertsPageDismissibleTitle,
          description: l10n.alertsPageDismissibleDescription,
          child: const DismissibleAlerts(),
        ),
        DemoCard(
          title: l10n.alertsPageAutoTitle,
          description: l10n.alertsPageAutoDescription,
          child: const CountdownAlerts(),
        ),
      ],
    );
  }
}

/// Alerts one under the other (`flex flex-col gap-3`).
class _Stack extends StatelessWidget {
  const _Stack({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, child) in children.indexed) ...[
        if (index > 0) const SizedBox(height: Space.md),
        child,
      ],
    ],
  );
}

/// Background, border and ink of each tone. Folder green uses the theme's primary so it stays
/// readable on the night card.
({Color background, Color border, Color ink}) _palette(BuildContext context, AlertTone tone) {
  final colors = context.colors;
  ({Color background, Color border, Color ink}) tinted(Color color) =>
      (background: color.withValues(alpha: 0.06), border: color.withValues(alpha: 0.3), ink: color);
  return switch (tone) {
    AlertTone.note => (background: colors.paperCard, border: colors.ink200, ink: colors.ink900),
    AlertTone.folder => tinted(colors.primary),
    AlertTone.pass => tinted(colors.pass),
    AlertTone.pencil => tinted(colors.pencil),
    AlertTone.pen => tinted(colors.pen),
    AlertTone.muted => (background: colors.ink100, border: colors.ink200, ink: colors.ink900),
    AlertTone.ink => (background: colors.ink900, border: colors.ink900, ink: colors.paperCard),
  };
}

IconData _iconFor(AlertTone tone) => switch (tone) {
  AlertTone.note => LucideIcons.messageSquare,
  AlertTone.folder => LucideIcons.bookmark,
  AlertTone.pass => LucideIcons.circleCheck,
  AlertTone.pencil => LucideIcons.clock,
  AlertTone.pen => LucideIcons.circleAlert,
  AlertTone.muted => LucideIcons.info,
  AlertTone.ink => LucideIcons.notebookPen,
};

/// An alert in one of the Marksheet tones: icon, optional bold [title], the message and an
/// optional [action] (a close button) on the right.
class ToneAlert extends StatelessWidget {
  const ToneAlert({
    required this.tone,
    this.title,
    this.child,
    this.action,
    this.live = false,
    super.key,
  });

  final AlertTone tone;
  final String? title;
  final Widget? child;
  final Widget? action;

  /// Announce the alert when it appears or changes (the web's `polite` status).
  final bool live;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context, tone);
    final textStyle = context.text.bodyMedium?.copyWith(color: palette.ink);
    return Semantics(
      container: true,
      liveRegion: live,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.background,
          border: Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Padding(
          // A close button sits in the corner at full tap size; the text keeps its own padding.
          padding: EdgeInsets.only(left: 14, right: action == null ? 14 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Icon(_iconFor(tone), size: 16, color: palette.ink),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: DefaultTextStyle.merge(
                    style: textStyle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (title != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: child == null ? 0 : Space.xs),
                            child: Text(
                              title!,
                              style: textStyle?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ?child,
                      ],
                    ),
                  ),
                ),
              ),
              if (action != null)
                IconButtonTheme(
                  data: IconButtonThemeData(
                    style: IconButton.styleFrom(foregroundColor: palette.ink),
                  ),
                  child: action!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "{tone} alert with a link to the test results." The link opens the test results tab.
class _LinkMessage extends StatefulWidget {
  const _LinkMessage({required this.tone});

  final AlertTone tone;

  @override
  State<_LinkMessage> createState() => _LinkMessageState();
}

class _LinkMessageState extends State<_LinkMessage> {
  late final _recognizer = TapGestureRecognizer()..onTap = () => context.go(Routes.testResults);

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RichMessage(
      l10n.alertsPageToneLink(alertToneLabel(l10n, widget.tone)),
      tags: {
        'link': (text) => TextSpan(
          text: text,
          recognizer: _recognizer,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      },
    );
  }
}

/// The close icon of an alert.
class _CloseIcon extends StatelessWidget {
  const _CloseIcon({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.alertsPageClose,
    icon: const Icon(LucideIcons.x, size: 18),
    onPressed: onPressed,
  );
}

/// Two alerts that can be dismissed (one with a close icon, one with its own "Close" button,
/// both with a swipe) and a button that brings both back.
class DismissibleAlerts extends StatefulWidget {
  const DismissibleAlerts({super.key});

  @override
  State<DismissibleAlerts> createState() => _DismissibleAlertsState();
}

class _DismissibleAlertsState extends State<DismissibleAlerts> {
  var _first = true;
  var _second = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_first) ...[
          Dismissible(
            key: const ValueKey('alerts.dismissible.first'),
            onDismissed: (_) => setState(() => _first = false),
            child: ToneAlert(
              tone: AlertTone.muted,
              live: true,
              action: _CloseIcon(onPressed: () => setState(() => _first = false)),
              child: Text(l10n.alertsPageDismissibleText),
            ),
          ),
          const SizedBox(height: Space.md),
        ],
        if (_second) ...[
          Dismissible(
            key: const ValueKey('alerts.dismissible.second'),
            onDismissed: (_) => setState(() => _second = false),
            child: ToneAlert(
              tone: AlertTone.muted,
              live: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.alertsPageDismissibleCustomText),
                  const SizedBox(height: Space.sm),
                  OutlinedButton(
                    onPressed: () => setState(() => _second = false),
                    child: Text(l10n.alertsPageClose),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.md),
        ],
        FilledButton.tonal(
          onPressed: () => setState(() {
            _first = true;
            _second = true;
          }),
          child: Text(l10n.alertsPageShowDismissible),
        ),
      ],
    );
  }
}

/// Two alerts that dismiss themselves after a countdown, one showing the seconds left and one
/// a progress bar; closing either stops the countdown, and the button starts it again. They
/// share one countdown, which starts as soon as the screen shows.
class CountdownAlerts extends StatefulWidget {
  const CountdownAlerts({this.seconds = 10, super.key});

  /// Length of the countdown.
  final int seconds;

  @override
  State<CountdownAlerts> createState() => _CountdownAlertsState();
}

class _CountdownAlertsState extends State<CountdownAlerts> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    _remaining = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remaining -= 1;
      });
      if (_remaining <= 0) {
        timer.cancel();
      }
    });
  }

  void _close() {
    _timer?.cancel();
    setState(() => _remaining = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final ratio = widget.seconds == 0 ? 0.0 : _remaining / widget.seconds;
    const tabular = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_remaining > 0) ...[
          ToneAlert(
            tone: AlertTone.pencil,
            live: true,
            action: _CloseIcon(onPressed: _close),
            child: RichMessage(
              l10n.alertsPageCountdownBold(_remaining),
              style: tabular,
              tags: {
                'strong': (text) => TextSpan(
                  text: text,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              },
            ),
          ),
          const SizedBox(height: Space.md),
          ToneAlert(
            tone: AlertTone.folder,
            live: true,
            action: _CloseIcon(onPressed: _close),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.alertsPageCountdownPlain(_remaining), style: tabular),
                const SizedBox(height: Space.sm),
                LinearProgressIndicator(
                  value: ratio,
                  semanticsLabel: l10n.alertsPageTimeLeft,
                  semanticsValue: NumberFormat.percentPattern(context.localeName).format(ratio),
                  color: colors.primary,
                  backgroundColor: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Radii.sm),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
        ],
        FilledButton.tonal(
          onPressed: () => setState(_start),
          child: Text(l10n.alertsPageShowTimer),
        ),
      ],
    );
  }
}
