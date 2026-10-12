import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_pager.dart';

/// `/dashboard/base/paginations`: pagination bars in three sizes and three alignments, all
/// sharing one current page.
class PaginationsScreen extends StatelessWidget {
  const PaginationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.paginationsPageTitle,
      description: Text(l10n.paginationsPageDescription),
      children: const [PagerDemos()],
    );
  }
}
