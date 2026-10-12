import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/router/sign_out.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/brand.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shown while the stored session is read (usually a blink), or when the backend couldn't be
/// reached to check it.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final session = ref.watch(sessionProvider);
    return Scaffold(
      backgroundColor: colors.folder,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Wordmark(onFolder: true, size: 28),
              const SizedBox(height: Space.lg),
              if (session is RestoreFailed) ...[
                Text(
                  l10n.sessionRestoreFailedTitle,
                  style: context.text.headlineSmall?.copyWith(color: colors.folderInk),
                ),
                const SizedBox(height: Space.sm),
                Text(
                  l10n.sessionRestoreFailedText,
                  style: context.text.bodyMedium?.copyWith(color: colors.folderInkSoft),
                ),
                const SizedBox(height: Space.sm),
                Text(
                  errorMessage(context, session.error),
                  style: context.text.bodySmall?.copyWith(color: colors.folderInkSoft),
                ),
                const SizedBox(height: Space.lg),
                Row(
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.folderInk,
                        foregroundColor: colors.folder,
                      ),
                      onPressed: ref.read(sessionProvider.notifier).retryRestore,
                      child: Text(l10n.commonRetry),
                    ),
                    const SizedBox(width: Space.sm),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: colors.folderInk),
                      onPressed: () => signOutToWelcome(ref),
                      child: Text(l10n.dashboardLayoutSignOut),
                    ),
                  ],
                ),
              ] else
                Semantics(
                  label: l10n.sessionRestoring,
                  child: LinearProgressIndicator(
                    color: colors.folderInk,
                    backgroundColor: colors.folderDeep,
                  ),
                ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unknown paths: "This page is absent."
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Mark(status: TestStatus.pending, size: 32, animate: true),
                  const SizedBox(width: Space.sm),
                  Text(l10n.notFoundMark.toUpperCase(), style: context.type.formLabel),
                ],
              ),
              const SizedBox(height: Space.page),
              Text(l10n.notFoundTitle, style: context.text.headlineLarge),
              const SizedBox(height: Space.sm),
              Text(
                l10n.notFoundText,
                style: context.text.bodyLarge?.copyWith(color: context.colors.ink600),
              ),
              const SizedBox(height: Space.lg),
              FilledButton(
                onPressed: () => context.go(Routes.welcome),
                child: Text(l10n.notFoundHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
