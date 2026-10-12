import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/data/paged_list.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/utils/file_size.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/offline_banner.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/files/file_upload.dart';
import 'package:flutter_boilerplate/features/files/files_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/files`: upload from documents, the camera or photos; open, share or delete.
class FilesScreen extends ConsumerWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final list = ref.watch(filesListProvider);
    final upload = ref.watch(uploadProgressProvider);

    Future<void> refresh() => ref.read(filesListProvider.notifier).reload();

    return AppScaffold(
      title: l10n.filesPageTitle,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.lg),
                    sliver: SliverList.list(
                      children: [
                        PageHeader(
                          title: l10n.filesPageTitle,
                          description: Text(l10n.filesPageDescription),
                        ),
                        const SizedBox(height: Space.lg),
                        SheetCard(
                          title: l10n.filesPageUploadTitle,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(l10n.filesPageFileHint, style: context.text.bodySmall),
                              const SizedBox(height: Space.page),
                              if (upload != null) ...[
                                Text(
                                  l10n.filesPageUploading(upload.name),
                                  style: context.text.bodyMedium,
                                ),
                                const SizedBox(height: Space.sm),
                                LinearProgressIndicator(value: upload.value),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: ref.read(uploadProgressProvider.notifier).cancel,
                                    child: Text(l10n.commonCancel),
                                  ),
                                ),
                              ] else
                                Wrap(
                                  spacing: Space.sm,
                                  runSpacing: Space.sm,
                                  children: [
                                    FilledButton.icon(
                                      key: const Key('files.chooseFile'),
                                      onPressed: () =>
                                          pickAndUpload(context, ref, FileSource.documents),
                                      icon: const Icon(LucideIcons.upload, size: 18),
                                      label: Text(l10n.filesPageChooseFile),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          pickAndUpload(context, ref, FileSource.camera),
                                      icon: const Icon(LucideIcons.camera, size: 18),
                                      label: Text(l10n.filesPageTakePhoto),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          pickAndUpload(context, ref, FileSource.gallery),
                                      icon: const Icon(LucideIcons.image, size: 18),
                                      label: Text(l10n.filesPageChoosePhoto),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Space.lg),
                        SectionTitle(l10n.filesPageListTitle),
                        const SizedBox(height: Space.sm),
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
                              ? EmptyState(title: l10n.filesPageEmpty)
                              : Column(
                                  children: [
                                    for (final (index, file) in value.items.indexed) ...[
                                      if (index > 0)
                                        Divider(color: context.colors.ink200, indent: 72),
                                      _FileRow(file: file),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PagedFooter(
                          state: value,
                          onLoadMore: ref.read(filesListProvider.notifier).loadMore,
                        ),
                      ),
                    ],
                    AsyncValue(:final error?) => [
                      SliverToBoxAdapter(
                        child: ErrorView(error: error, onRetry: refresh, compact: true),
                      ),
                    ],
                    _ => [
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Space.page),
                          child: SkeletonRows(rows: 4),
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

enum _FileAction { open, delete }

class _FileRow extends ConsumerWidget {
  const _FileRow({required this.file});

  final StoredFile file;

  IconData get _icon => switch (file.contentType) {
    final String type when type.startsWith('image/') => LucideIcons.image,
    'application/pdf' => LucideIcons.fileText,
    _ => LucideIcons.file,
  };

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await confirm(
      context,
      title: l10n.filesPageConfirmTitle(file.name),
      text: l10n.filesPageConfirmText,
      confirmLabel: l10n.filesPageConfirmDelete,
      cancelLabel: l10n.filesPageConfirmCancel,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    try {
      await ref.read(filesRepositoryProvider).delete(file.id);
      ref.invalidate(filesListProvider);
      if (context.mounted) {
        showToast(context, l10n.filesPageDeleted(file.name), tone: ToastTone.success);
      }
    } on ApiException catch (error) {
      if (context.mounted) {
        showToast(context, errorMessage(context, error), tone: ToastTone.error);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final details = [
      formatFileSize(file.size, context.localeName),
      if (file.createdAt != null) context.formatDate(file.createdAt!),
    ].join(' · ');
    return ListTile(
      contentPadding: const EdgeInsets.only(left: Space.page, right: Space.xs),
      leading: CircleAvatar(
        backgroundColor: context.colors.ink100,
        foregroundColor: context.colors.ink700,
        child: Icon(_icon, size: 20),
      ),
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(details, style: context.type.table.copyWith(fontSize: 13)),
      onTap: () => openFile(context, ref, file),
      trailing: PopupMenuButton<_FileAction>(
        tooltip: l10n.filesPageColumnActions,
        onSelected: (action) => switch (action) {
          _FileAction.open => openFile(context, ref, file),
          _FileAction.delete => _delete(context, ref),
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _FileAction.open,
            child: ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l10n.filesPageOpenButton),
            ),
          ),
          PopupMenuItem(
            value: _FileAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: context.colors.pen),
              title: Text(l10n.filesPageDeleteLabel(file.name)),
            ),
          ),
        ],
      ),
    );
  }
}
