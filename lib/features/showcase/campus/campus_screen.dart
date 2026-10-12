import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_providers.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/account_menu.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/app_launcher.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/campus_dialogs.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/profile_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `/dashboard/campus`: the app launcher, the campus profile, the sign-in dialogs and the
/// account menu (the web app's campus home).
class CampusScreen extends ConsumerWidget {
  const CampusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(campusProfileProvider);

    return AppPage(
      title: l10n.campusPageTitle,
      description: Text(l10n.campusPageDescription),
      onRefresh: () => ref.refresh(campusProfileProvider.future),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionTitle(l10n.campusPageLauncherTitle),
            const SizedBox(height: Space.page),
            const AppLauncher(categories: launcherCategories),
          ],
        ),
        ...switch (profile) {
          AsyncValue(:final value?) => [
            ProfileCard(profile: value),
            DemoCard(
              title: l10n.campusPageDialogsTitle,
              description: l10n.campusPageDialogsDescription,
              child: CampusDialogs(email: value.email),
            ),
            DemoCard(
              title: l10n.campusPageAccountTitle,
              description: l10n.campusPageAccountDescription,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: AccountMenu(name: value.name, email: value.email),
              ),
            ),
          ],
          AsyncValue(:final error?) => [
            ErrorView(
              error: error,
              compact: true,
              onRetry: () => ref.invalidate(campusProfileProvider),
            ),
          ],
          _ => [const LoadingView(compact: true)],
        },
      ],
    );
  }
}
