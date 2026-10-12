import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';

/// The message to show for a failed backend call: connection problems and rate limits get the
/// app's own words, otherwise the backend's message, otherwise [fallback].
String errorMessage(BuildContext context, Object error, {String? fallback}) {
  final l10n = context.l10n;
  if (error is! ApiException) {
    return fallback ?? l10n.commonErrorGeneric;
  }
  return switch (error.failure) {
    ApiFailure.network => l10n.commonErrorNetwork,
    ApiFailure.timeout => l10n.commonErrorTimeout,
    ApiFailure.rateLimited => l10n.authFormErrorRateLimited(
      ((error.retryAfter?.inSeconds ?? 60) / 60).ceil().clamp(1, 1440),
    ),
    ApiFailure.server || ApiFailure.unknown => fallback ?? l10n.commonErrorGeneric,
    _ => error.message ?? fallback ?? l10n.commonErrorGeneric,
  };
}

/// A form-level error: the red pen circle and the message, announced to screen readers.
class FormAlert extends StatelessWidget {
  const FormAlert(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(Space.md),
        decoration: BoxDecoration(
          color: colors.pen.withValues(alpha: 0.07),
          border: Border.all(color: colors.pen.withValues(alpha: 0.45)),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Mark(status: TestStatus.failed, size: 18),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text(
                message,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.pen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A failed load: the red mark, what happened, and a retry button (the web's `ErrorState`).
class ErrorView extends StatelessWidget {
  const ErrorView({required this.error, this.onRetry, this.compact = false, super.key});

  final Object error;
  final VoidCallback? onRetry;

  /// Inside a card or list instead of filling the screen.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final requestId = error is ApiException ? (error as ApiException).requestId : null;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Mark(status: TestStatus.failed, size: 40),
        const SizedBox(height: Space.md),
        Text(l10n.errorPageTitle, style: context.text.headlineSmall),
        const SizedBox(height: Space.sm),
        Text(
          errorMessage(context, error, fallback: l10n.errorPageText),
          style: context.text.bodyMedium?.copyWith(color: context.colors.ink600),
        ),
        if (requestId != null) ...[
          const SizedBox(height: Space.sm),
          SelectableText('#$requestId', style: context.text.bodySmall),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: Space.page),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.errorPageRetry),
          ),
        ],
      ],
    );
    return Semantics(
      liveRegion: true,
      child: compact
          ? Padding(padding: const EdgeInsets.all(Space.card), child: content)
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Space.xl),
                child: content,
              ),
            ),
    );
  }
}

/// Loading placeholder with an accessible label.
class LoadingView extends StatelessWidget {
  const LoadingView({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.loadingLabel,
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? Space.lg : Space.section),
        child: const CircularProgressIndicator(strokeWidth: 2.5),
      ),
    ),
  );
}

/// Grey bars where rows will appear (the web's `LoadingCard`).
class SkeletonRows extends StatelessWidget {
  const SkeletonRows({this.rows = 5, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.ink100;
    Widget bar(double? width) => Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Radii.sm)),
    );
    return Semantics(
      label: context.l10n.loadingLabel,
      child: Column(
        children: [
          for (var index = 0; index < rows; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.page),
              child: Row(
                children: [
                  Expanded(child: bar(null)),
                  const SizedBox(width: Space.page),
                  bar(64),
                  const SizedBox(width: Space.page),
                  bar(40),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// "Nothing here yet", with an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, this.text, this.action, super.key});

  final String title;
  final String? text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.xl),
    child: Column(
      children: [
        Text(title, style: context.text.titleLarge, textAlign: TextAlign.center),
        if (text != null) ...[
          const SizedBox(height: Space.sm),
          Text(
            text!,
            style: context.text.bodyMedium?.copyWith(color: context.colors.ink600),
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[const SizedBox(height: Space.page), action!],
      ],
    ),
  );
}

/// Asks before something that can't be undone. Resolves true when confirmed.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String text,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel)),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: context.colors.pen,
                  foregroundColor: context.colors.ply,
                )
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

enum ToastTone { neutral, success, error }

/// A short message at the bottom of the screen, with a haptic tap for success and errors.
void showToast(BuildContext context, String message, {ToastTone tone = ToastTone.neutral}) {
  final colors = context.colors;
  switch (tone) {
    case ToastTone.success:
      Haptics.success();
    case ToastTone.error:
      Haptics.error();
    case ToastTone.neutral:
      break;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (tone != ToastTone.neutral) ...[
              Mark(
                status: tone == ToastTone.success ? TestStatus.passed : TestStatus.failed,
                size: 18,
                color: tone == ToastTone.success ? colors.folderInkSoft : colors.pen,
                animate: true,
              ),
              const SizedBox(width: Space.sm),
            ],
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
