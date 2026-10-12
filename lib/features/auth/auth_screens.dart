import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/brand.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_boilerplate/core/widgets/offline_banner.dart';
import 'package:flutter_boilerplate/features/auth/auth_form.dart';
import 'package:go_router/go_router.dart';

/// `/sign-in`.
class SignInScreen extends StatelessWidget {
  const SignInScreen({this.from, super.key});

  /// Where to return after signing in (kept across the switch to sign-up).
  final String? from;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _AuthLayout(
      title: l10n.signInPageTitle,
      subtitle: l10n.signInPageSubtitle,
      form: const AuthForm(mode: AuthMode.signIn),
      switchPrompt: l10n.signInPageSwitchPrompt,
      switchLabel: l10n.signInPageSwitchLink,
      onSwitch: () => context.go(_withFrom(Routes.signUp, from)),
    );
  }
}

/// `/sign-up`.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({this.from, super.key});

  final String? from;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _AuthLayout(
      title: l10n.signUpPageTitle,
      subtitle: l10n.signUpPageSubtitle,
      form: const AuthForm(mode: AuthMode.signUp),
      switchPrompt: l10n.signUpPageSwitchPrompt,
      switchLabel: l10n.signUpPageSwitchLink,
      onSwitch: () => context.go(_withFrom(Routes.signIn, from)),
    );
  }
}

String _withFrom(String path, String? from) =>
    from == null ? path : Uri(path: path, queryParameters: {'from': from}).toString();

/// The folder band with the key to the marks, then the form on card stock.
class _AuthLayout extends StatelessWidget {
  const _AuthLayout({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.switchPrompt,
    required this.switchLabel,
    required this.onSwitch,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final String switchPrompt;
  final String switchLabel;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: colors.folder,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.xs, Space.xs, Space.xs, Space.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: l10n.authLayoutBackHome,
                          color: colors.folderInk,
                          icon: const BackButtonIcon(),
                          onPressed: () => context.go(Routes.welcome),
                        ),
                        const Spacer(),
                        const LocaleSwitcher(onFolder: true),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.md),
                      child: Row(
                        children: [
                          for (final status in TestStatus.values.reversed) ...[
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.paperCard,
                                borderRadius: BorderRadius.circular(Radii.md),
                              ),
                              child: Mark(status: _keyOrder(status), size: 26, animate: true),
                            ),
                            const SizedBox(width: Space.sm),
                          ],
                          const SizedBox(width: Space.xs),
                          Expanded(
                            child: Text(
                              l10n.authLayoutAsideTitle,
                              style: context.text.titleMedium?.copyWith(
                                color: colors.folderInk,
                                fontWeight: FontWeight.w800,
                              ),
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
          const OfflineBanner(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(Space.lg, Space.xl, Space.lg, Space.xl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(title, style: context.text.headlineMedium),
                        ),
                        const SizedBox(height: Space.sm),
                        Text(
                          subtitle,
                          style: context.text.bodyMedium?.copyWith(color: colors.ink600),
                        ),
                        const SizedBox(height: Space.xl),
                        form,
                        const SizedBox(height: Space.lg),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(switchPrompt, style: context.text.bodyMedium),
                            TextButton(onPressed: onSwitch, child: Text(switchLabel)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Passed, failed, pending: the order of the key on the web.
  static TestStatus _keyOrder(TestStatus status) => switch (status) {
    TestStatus.failed => TestStatus.passed,
    TestStatus.passed => TestStatus.failed,
    TestStatus.pending => TestStatus.pending,
  };
}
