import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_overlays.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_secondary_button.dart';
import 'package:go_router/go_router.dart';

/// `/dashboard/base/tooltips`: short labels on buttons and links, shown on a long press or a
/// tap, on every side and alignment.
class TooltipsScreen extends StatelessWidget {
  const TooltipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.tooltipsPageTitle,
      description: Text(l10n.tooltipsPageDescription),
      children: [
        DemoCard(
          title: l10n.tooltipsPageBasicTitle,
          description: l10n.tooltipsPageBasicDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: DemoTooltip(
                          message: l10n.tooltipsPageBasicContent,
                          builder: (context, show) => SecondaryButton(
                            onPressed: show,
                            child: Text(l10n.tooltipsPageHoverMe),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.page),
                    Expanded(
                      child: Center(
                        child: DemoTooltip(
                          message: l10n.tooltipsPageOpenContent,
                          initiallyOpen: true,
                          builder: (context, show) => SecondaryButton(
                            onPressed: show,
                            child: Text(l10n.tooltipsPageHoverMe),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.page),
              RichMessage(
                l10n.tooltipsPageLinkSentence,
                style: context.text.bodyMedium?.copyWith(color: context.colors.ink700),
                tags: {
                  'link': (text) => WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: DemoTooltip(
                      message: l10n.tooltipsPageLinkContent,
                      builder: (context, show) => _InlineLink(
                        text: text,
                        onTap: () => context.go(Routes.testResults),
                      ),
                    ),
                  ),
                },
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.tooltipsPagePlacementTitle,
          description: l10n.tooltipsPagePlacementDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final placement in placements)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.sm),
                  child: Align(
                    alignment: placementTriggerAlignment(placement),
                    child: DemoTooltip(
                      message: l10n.tooltipsPagePlacementContent(placementName(l10n, placement)),
                      placement: placement,
                      builder: (context, show) => FilledButton(
                        onPressed: show,
                        child: Text(placementName(l10n, placement)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A link inside a sentence: underlined, in the folder green.
class _InlineLink extends StatelessWidget {
  const _InlineLink({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;
    return Semantics(
      link: true,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: context.text.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: color,
          ),
        ),
      ),
    );
  }
}
