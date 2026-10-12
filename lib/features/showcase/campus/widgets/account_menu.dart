import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/sign_out.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/campus/labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The account menu of the Vue header (`TheHeaderDropdownAccnt`): tapping the person's photo
/// opens a menu with who is signed in and a sign-out item.
class AccountMenu extends ConsumerWidget {
  const AccountMenu({required this.name, required this.email, super.key});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    return MenuAnchor(
      menuChildren: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 224, maxWidth: 280),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, Space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.text.titleSmall?.copyWith(color: colors.ink950)),
                const SizedBox(height: 2),
                Text(email, style: context.text.bodySmall, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
        const Divider(),
        MenuItemButton(
          leadingIcon: const Icon(LucideIcons.logOut, size: 18),
          onPressed: () => signOutToWelcome(ref),
          child: Text(l10n.campusAccountMenuSignOut),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: l10n.campusAccountMenuOpen(name),
        padding: EdgeInsets.zero,
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        icon: CircleAvatar(
          radius: 24,
          backgroundColor: colors.folder,
          foregroundColor: colors.folderInk,
          child: Text(
            initials(name).characters.first,
            style: context.text.titleLarge?.copyWith(color: colors.folderInk),
          ),
        ),
      ),
    );
  }
}
