import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_overlays.dart';

/// `/dashboard/base/popovers`: small panels of extra content opened from a button, on every side
/// and alignment.
class PopoversScreen extends StatelessWidget {
  const PopoversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.popoversPageTitle,
      description: Text(l10n.popoversPageDescription),
      children: [
        DemoCard(
          title: l10n.popoversPageBasicTitle,
          description: l10n.popoversPageBasicDescription,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.md),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: DemoPopover(
                      label: l10n.popoversPageClickMe,
                      title: l10n.popoversPageBasicHeader,
                      content: Text(l10n.popoversPageBasicContent),
                    ),
                  ),
                ),
                const SizedBox(width: Space.page),
                Expanded(
                  child: Center(
                    child: DemoPopover(
                      label: l10n.popoversPageClickMe,
                      title: l10n.popoversPageOpenHeader,
                      initiallyOpen: true,
                      content: RichMessage(
                        l10n.popoversPageOpenContent,
                        tags: {
                          'strong': (text) => TextSpan(
                            text: text,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        DemoCard(
          title: l10n.popoversPagePlacementTitle,
          description: l10n.popoversPagePlacementDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final placement in placements)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.sm),
                  child: Align(
                    alignment: placementTriggerAlignment(placement),
                    child: DemoPopover(
                      label: placementName(l10n, placement),
                      title: l10n.popoversPagePlacementHeader,
                      placement: placement,
                      content: Text(
                        l10n.popoversPagePlacementContent(placementName(l10n, placement)),
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
