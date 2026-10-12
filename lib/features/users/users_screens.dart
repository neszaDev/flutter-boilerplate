import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/data/paged_list.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_boilerplate/core/widgets/access_denied_view.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/offline_banner.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/users/users_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A role as a small tag.
class RoleBadge extends StatelessWidget {
  const RoleBadge({required this.role, super.key});

  final Role? role;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final admin = role == Role.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 3),
      decoration: BoxDecoration(
        color: admin ? colors.primary.withValues(alpha: 0.12) : colors.ply,
        border: Border.all(color: admin ? colors.primary : colors.ink300),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Text(
        roleLabel(context.l10n, role).toUpperCase(),
        style: context.type.formLabel.copyWith(color: admin ? colors.primary : colors.ink700),
      ),
    );
  }
}

/// `/dashboard/users` (needs [Permission.viewUsers]): search by email, newest first.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final query = value.trim();
      if (query.length <= 254 && query != _query) {
        setState(() => _query = query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = usersListProvider(_query);
    final list = ref.watch(provider);
    final total = list.value?.totalElements;

    if (isForbidden(list.error)) {
      return const AccessDeniedScreen();
    }

    return AppScaffold(
      title: l10n.usersPageTitle,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(provider.notifier).reload(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.page,
                      Space.sm,
                      Space.page,
                      Space.page,
                    ),
                    sliver: SliverList.list(
                      children: [
                        PageHeader(
                          title: l10n.usersPageTitle,
                          description: Text(
                            total == null
                                ? l10n.usersPageDescription
                                : l10n.usersPageDescriptionCount(total),
                          ),
                        ),
                        const SizedBox(height: Space.lg),
                        TextField(
                          controller: _search,
                          onChanged: _onSearch,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            labelText: l10n.usersPageSearchLabel,
                            hintText: l10n.usersPageSearchPlaceholder,
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: Space.lg),
                        SectionTitle(
                          _query.isEmpty
                              ? l10n.usersPageListTitle
                              : l10n.usersPageResultsTitle(_query),
                        ),
                      ],
                    ),
                  ),
                  ...switch (list) {
                    AsyncValue(:final value?) => [
                      SliverToBoxAdapter(
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: Space.page),
                          clipBehavior: Clip.antiAlias,
                          child: value.items.isEmpty
                              ? EmptyState(title: l10n.usersPageEmpty)
                              : Column(
                                  children: [
                                    for (final (index, user) in value.items.indexed) ...[
                                      if (index > 0) Divider(color: context.colors.ink200),
                                      ListTile(
                                        title: Text(user.email, overflow: TextOverflow.ellipsis),
                                        subtitle: user.createdAt == null
                                            ? null
                                            : Text(
                                                l10n.userPageMemberSince(
                                                  context.formatDate(user.createdAt!),
                                                ),
                                              ),
                                        trailing: RoleBadge(role: user.role),
                                        onTap: () => context.push(Routes.user(user.id)),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PagedFooter(
                          state: value,
                          onLoadMore: ref.read(provider.notifier).loadMore,
                        ),
                      ),
                    ],
                    AsyncValue(:final error?) => [
                      SliverToBoxAdapter(
                        child: ErrorView(
                          error: error,
                          compact: true,
                          onRetry: () => ref.invalidate(provider),
                        ),
                      ),
                    ],
                    _ => [
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Space.page),
                          child: SkeletonRows(),
                        ),
                      ),
                    ],
                  },
                  const SliverToBoxAdapter(child: SizedBox(height: Space.section)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `/dashboard/users/:id`: email and role, and deleting the account. Your own account can
/// only be changed by another admin, so there is always one admin left.
class UserScreen extends ConsumerWidget {
  const UserScreen({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(userProvider(id));
    final me = ref.watch(currentUserProvider);
    final access = ref.watch(accessProvider);

    return switch (user) {
      AsyncValue(:final value?) => AppPage(
        appBarTitle: l10n.userPageTitle,
        title: value.email,
        description: Wrap(
          spacing: Space.md,
          runSpacing: Space.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            RoleBadge(role: value.role),
            if (value.createdAt != null)
              Text(l10n.userPageMemberSince(context.formatDateLong(value.createdAt!))),
          ],
        ),
        onRefresh: () async => ref.invalidate(userProvider(id)),
        children: [
          if (value.id == me?.id)
            SheetCard(
              child: Text(
                l10n.userPageSelfNotice,
                style: context.text.bodyMedium?.copyWith(color: context.colors.ink600),
              ),
            )
          else ...[
            if (access.can(Permission.editUsers))
              SheetCard(
                title: l10n.userPageEditTitle,
                child: _EditUserForm(user: value),
              ),
            if (access.can(Permission.deleteUsers))
              SheetCard(
                title: l10n.userPageDeleteTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.userPageDeleteText,
                      style: context.text.bodyMedium?.copyWith(color: context.colors.ink600),
                    ),
                    const SizedBox(height: Space.page),
                    _DeleteUserButton(user: value),
                  ],
                ),
              ),
          ],
        ],
      ),
      AsyncValue(:final error?) when isForbidden(error) => const AccessDeniedScreen(),
      AsyncValue(:final error?) => Scaffold(
        appBar: AppBar(title: Text(l10n.userPageTitle)),
        body: ErrorView(
          error: error,
          onRetry: error is ApiException && error.failure == ApiFailure.notFound
              ? null
              : () => ref.invalidate(userProvider(id)),
        ),
      ),
      _ => Scaffold(
        appBar: AppBar(title: Text(l10n.userPageTitle)),
        body: const LoadingView(),
      ),
    };
  }
}

class _EditUserForm extends ConsumerStatefulWidget {
  const _EditUserForm({required this.user});

  final UserProfile user;

  @override
  ConsumerState<_EditUserForm> createState() => _EditUserFormState();
}

class _EditUserFormState extends ConsumerState<_EditUserForm> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.user.email);
  late Role _role = widget.user.role ?? Role.user;
  bool _busy = false;
  String? _formError;
  String? _emailError;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() {
      _formError = null;
      _emailError = null;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(usersRepositoryProvider)
          .update(widget.user.id, email: _email.text, role: _role);
      ref
        ..invalidate(userProvider(widget.user.id))
        ..invalidate(usersListProvider);
      if (mounted) {
        showToast(context, l10n.userFormSaved, tone: ToastTone.success);
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (error.failure == ApiFailure.conflict) {
          _emailError = l10n.userFormErrorEmailTaken;
        } else {
          _emailError = error.fieldErrors['email'];
          _formError = errorMessage(context, error, fallback: l10n.userFormErrorGeneric);
        }
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_formError != null) ...[FormAlert(_formError!), const SizedBox(height: Space.page)],
          LabeledField(
            label: l10n.userFormEmailLabel,
            child: TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(errorText: _emailError),
              validator: validator(l10n, userEmailRule),
            ),
          ),
          const SizedBox(height: Space.page),
          LabeledField(
            label: l10n.userFormRoleLabel,
            child: SegmentedButton<Role>(
              showSelectedIcon: false,
              segments: [
                for (final role in Role.values)
                  ButtonSegment(value: role, label: Text(roleLabel(l10n, role))),
              ],
              selected: {_role},
              onSelectionChanged: (selection) => setState(() => _role = selection.first),
            ),
          ),
          const SizedBox(height: Space.md),
          Text(l10n.userFormSignOutHint, style: context.text.bodySmall),
          const SizedBox(height: Space.page),
          BusyButton(label: l10n.userFormSaveButton, busy: _busy, onPressed: _save),
        ],
      ),
    );
  }
}

class _DeleteUserButton extends ConsumerStatefulWidget {
  const _DeleteUserButton({required this.user});

  final UserProfile user;

  @override
  ConsumerState<_DeleteUserButton> createState() => _DeleteUserButtonState();
}

class _DeleteUserButtonState extends ConsumerState<_DeleteUserButton> {
  bool _busy = false;

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await confirm(
      context,
      title: l10n.userFormConfirmTitle(widget.user.email),
      text: l10n.userFormConfirmText,
      confirmLabel: l10n.userFormConfirmDelete,
      cancelLabel: l10n.userFormConfirmCancel,
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(usersRepositoryProvider).delete(widget.user.id);
      ref.invalidate(usersListProvider);
      if (mounted) {
        showToast(context, l10n.userFormDeleted(widget.user.email), tone: ToastTone.success);
        context.pop();
      }
    } on ApiException catch (error) {
      if (mounted) {
        showToast(
          context,
          errorMessage(context, error, fallback: l10n.userFormErrorGeneric),
          tone: ToastTone.error,
        );
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    style: FilledButton.styleFrom(
      backgroundColor: context.colors.pen,
      foregroundColor: context.colors.ply,
    ),
    onPressed: _busy ? null : _delete,
    icon: const Icon(Icons.delete_outline),
    label: Text(context.l10n.userFormDeleteButton),
  );
}
