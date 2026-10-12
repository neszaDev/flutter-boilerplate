import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/pages/error_preview.dart';
import 'package:go_router/go_router.dart';

/// `/dashboard/pages/404`: a preview of the page shown when a link leads nowhere (the app's
/// not-found screen), with the code and the search box.
class Error404Screen extends StatelessWidget {
  const Error404Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return AppPage(
      title: l10n.error404PageTitle,
      description: Text(l10n.error404PageDescription),
      children: [
        ErrorPreviewFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Mark(status: TestStatus.pending, size: 32, animate: true),
                  const SizedBox(width: Space.sm),
                  FormLabel(l10n.error404PageMark),
                ],
              ),
              const SizedBox(height: Space.page),
              Text(
                l10n.error404PageCode,
                style: context.text.displayLarge?.copyWith(
                  fontSize: 48,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: Space.sm),
              Semantics(
                header: true,
                child: Text(l10n.error404PageCardTitle, style: context.text.headlineLarge),
              ),
              const SizedBox(height: Space.sm),
              Text(
                l10n.error404PageCardText,
                style: context.text.bodyLarge?.copyWith(color: colors.ink600),
              ),
              const SizedBox(height: Space.lg),
              const ErrorPreviewSearch(),
              const SizedBox(height: Space.sm),
              OutlinedButton(
                onPressed: () => context.go(Routes.dashboard),
                child: Text(l10n.error404PageHome),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
