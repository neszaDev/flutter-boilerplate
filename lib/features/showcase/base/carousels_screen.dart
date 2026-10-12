import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_carousel.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/base/carousels`: three slides with arrows, indicators and autoplay.
class CarouselsScreen extends StatelessWidget {
  const CarouselsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.carouselsPageTitle,
      description: Text(l10n.carouselsPageDescription),
      children: [
        DemoCard(
          title: l10n.carouselsPageCardTitle,
          description: l10n.carouselsPageCardDescription,
          child: DemoCarousel(
            picture: Semantics(
              image: true,
              label: l10n.carouselsPageSlideLogoAlt,
              excludeSemantics: true,
              // The web shows the campus crest picture; the app ships no copy of it yet.
              child: FittedBox(
                child: Icon(LucideIcons.school, size: 160, color: context.colors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
