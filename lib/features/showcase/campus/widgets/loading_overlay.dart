import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';

/// The full-screen loading overlay (Vue `CenterLoading`): a dimmed, blurred screen with a
/// centred spinner. Show it with [showLoadingOverlay].
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) => BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
    child: Center(
      child: Semantics(
        container: true,
        liveRegion: true,
        label: context.l10n.campusLoadingLabel,
        child: SizedBox.square(
          dimension: 64,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    ),
  );
}

/// Runs [task] under the [LoadingOverlay], above every route (dialogs included). Taps and the
/// back gesture are blocked until it ends.
Future<T> showLoadingOverlay<T>(BuildContext context, Future<T> Function() task) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final route = RawDialogRoute<void>(
    barrierDismissible: false,
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.35),
    pageBuilder: (_, _, _) => const PopScope(canPop: false, child: LoadingOverlay()),
  );
  unawaited(navigator.push(route));
  try {
    return await task();
  } finally {
    if (route.isActive) {
      navigator.removeRoute(route);
    }
  }
}
