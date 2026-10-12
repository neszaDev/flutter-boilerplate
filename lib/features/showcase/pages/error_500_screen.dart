import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/pages/error_preview.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/pages/500`: a preview of the page shown when the server fails (the app's error
/// view), with the code, the search box and a retry button.
class Error500Screen extends StatelessWidget {
  const Error500Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.error500PageTitle,
      description: Text(l10n.error500PageDescription),
      children: const [ErrorPreviewFrame(child: _ServerErrorCard())],
    );
  }
}

/// The error card. "Try again" reloads the preview: the red mark is drawn again and, since a
/// preview always fails, the card says so.
class _ServerErrorCard extends StatefulWidget {
  const _ServerErrorCard();

  @override
  State<_ServerErrorCard> createState() => _ServerErrorCardState();
}

class _ServerErrorCardState extends State<_ServerErrorCard> {
  static const _reload = Duration(milliseconds: 800);

  var _attempt = 0;
  var _retrying = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _retry() {
    setState(() => _retrying = true);
    _timer = Timer(_reload, () {
      setState(() {
        _retrying = false;
        _attempt += 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Mark(
              key: ValueKey(_attempt),
              status: TestStatus.failed,
              size: 48,
              animate: _attempt > 0,
            ),
            const SizedBox(width: Space.page),
            Text(
              l10n.error500PageCode,
              style: context.text.displayLarge?.copyWith(
                fontSize: 48,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.card),
        Semantics(
          header: true,
          child: Text(l10n.error500PageCardTitle, style: context.text.headlineSmall),
        ),
        const SizedBox(height: Space.sm),
        Text(
          l10n.error500PageCardText,
          style: context.text.bodyLarge?.copyWith(color: colors.ink600),
        ),
        const SizedBox(height: Space.card),
        const ErrorPreviewSearch(),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.md,
          children: [
            BusyButton(
              label: l10n.error500PageRetry,
              icon: LucideIcons.rotateCcw,
              busy: _retrying,
              onPressed: _retry,
            ),
            OutlinedButton(
              onPressed: () => context.go(Routes.dashboard),
              child: Text(l10n.error500PageHome),
            ),
          ],
        ),
        const SizedBox(height: Space.sm),
        Semantics(
          container: true,
          liveRegion: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 20),
            child: Text(
              _attempt > 0 && !_retrying ? l10n.error500PageRetryResult : '',
              style: context.text.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
