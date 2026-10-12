import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_providers.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/filter_panels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `/dashboard/campus/filters`: the organisation filter and the course option filter, each with
/// the selection it emits.
class CampusFiltersScreen extends ConsumerWidget {
  const CampusFiltersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final units = ref.watch(orgUnitsProvider);

    return AppPage(
      title: l10n.campusFiltersPageTitle,
      description: Text(l10n.campusFiltersPageDescription),
      children: switch (units) {
        AsyncValue(:final value?) => [
          DemoCard(
            title: l10n.campusFiltersPageOrganizationTitle,
            description: l10n.campusFiltersPageOrganizationDescription,
            child: OrganizationFilterPanel(units: value),
          ),
          DemoCard(
            title: l10n.campusFiltersPageOptionTitle,
            description: l10n.campusFiltersPageOptionDescription,
            child: CourseOptionPanel(universities: value.organizations),
          ),
        ],
        AsyncValue(:final error?) => [
          ErrorView(error: error, compact: true, onRetry: () => ref.invalidate(orgUnitsProvider)),
        ],
        _ => [const LoadingView(compact: true)],
      },
    );
  }
}
