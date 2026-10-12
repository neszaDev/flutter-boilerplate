import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/users/users_screens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `/dashboard/account`: the details on your card.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const SizedBox.shrink();
    }
    final details = <(String, Widget)>[
      (l10n.accountPageEmailLabel, SelectableText(user.email)),
      (
        l10n.accountPageRoleLabel,
        Align(
          alignment: Alignment.centerLeft,
          child: RoleBadge(role: user.role),
        ),
      ),
      if (user.createdAt != null)
        (l10n.accountPageMemberSinceLabel, Text(context.formatDateLong(user.createdAt!))),
      (l10n.accountPageIdLabel, Text('${user.id}', style: context.type.table)),
    ];

    return AppPage(
      title: l10n.accountPageTitle,
      description: Text(l10n.accountPageDescription),
      onRefresh: ref.read(sessionProvider.notifier).refreshProfile,
      children: [
        Card(
          child: Column(
            children: [
              for (final (index, (label, value)) in details.indexed) ...[
                if (index > 0) Divider(color: context.colors.ink200),
                MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.card,
                      vertical: Space.page,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FormLabel(label),
                        const SizedBox(height: Space.sm),
                        DefaultTextStyle.merge(
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.colors.ink950,
                          ),
                          child: value,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
