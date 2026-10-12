import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_widgets.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/apps/email/inbox[?folder=…|?label=…]`: the Vue inbox. The folder menu is in the
/// app bar; select messages (checkbox or long-press) to act on them from the app bar, swipe a
/// row to archive or delete it, tap it to read it. Ten rows per page.
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  var _folder = MailFolder.inbox;
  MailLabel? _label;
  var _page = 0;
  final _selected = <String>{};
  var _readQuery = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_readQuery) {
      _readQuery = true;
      final query = GoRouterState.of(context).uri.queryParameters;
      _folder = toFolder(query['folder']);
      _label = toLabel(query['label']);
    }
  }

  List<Mail> _list(List<Mail> messages) =>
      _label == null ? folderMessages(messages, _folder) : labelMessages(messages, _label!);

  /// A new folder or label starts with a fresh selection and the first page.
  void _open({MailFolder? folder, MailLabel? label}) => setState(() {
    _folder = folder ?? MailFolder.inbox;
    _label = label;
    _page = 0;
    _selected.clear();
  });

  void _act(Iterable<String> ids, MailAction action) {
    final l10n = context.l10n;
    final count = ids.length;
    ref.read(mailboxProvider.notifier).apply(ids, action);
    if (action is! MoveTo) {
      return;
    }
    setState(() => _selected.removeAll(ids));
    final message = switch (action.box) {
      MailBox.archive => l10n.inboxPageArchived(count),
      _ when _folder == MailFolder.trash && _label == null => l10n.inboxPageDeleted(count),
      _ => l10n.inboxPageTrashed(count),
    };
    showToast(context, message, tone: ToastTone.success);
  }

  void _openMessage(Mail message) {
    ref.read(mailboxProvider.notifier).apply([message.id], const MarkRead(true));
    context.push(messageLocation(message.id, _folder)).ignore();
  }

  void _toggle(Mail message) => setState(() {
    if (!_selected.remove(message.id)) {
      _selected.add(message.id);
    }
  });

  /// Swiping applies [action]; the row slides away only when the message leaves this list
  /// (archiving a starred message keeps it under Starred).
  Future<bool> _confirmSwipe(Mail message, MailAction action) async {
    final after = applyMailAction(ref.read(mailboxProvider), [message.id], action);
    if (_list(after).any((other) => other.id == message.id)) {
      _act([message.id], action);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final messages = ref.watch(mailboxProvider);
    final list = _list(messages);
    final page = mailPage(list, _page);
    final targets = list.where((message) => _selected.contains(message.id)).toList();
    final visibleIds = page.rows.map((message) => message.id);
    final allVisible = page.rows.isNotEmpty && visibleIds.every(_selected.contains);
    final someVisible = visibleIds.any(_selected.contains);
    final title = _label == null ? folderName(l10n, _folder) : labelName(l10n, _label!);
    final selecting = targets.isNotEmpty;

    return PopScope(
      // Back clears the selection first.
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(_selected.clear);
        }
      },
      child: Scaffold(
        appBar: selecting
            ? AppBar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                leading: IconButton(
                  key: const Key('inbox.clearSelection'),
                  tooltip: l10n.mailToolbarClearSelection,
                  onPressed: () => setState(_selected.clear),
                  icon: const Icon(LucideIcons.x),
                ),
                title: Text(l10n.mailToolbarSelected(targets.length)),
                actions: [
                  MailActionBar(
                    targets: targets,
                    onAction: (action) => _act([for (final message in targets) message.id], action),
                  ),
                ],
              )
            : AppBar(
                titleSpacing: 0,
                title: _FolderMenu(
                  folder: _label == null ? _folder : null,
                  label: _label,
                  title: title,
                  count: _label == null ? folderCount(messages, _folder) : 0,
                  onFolder: (folder) => _open(folder: folder),
                  onLabel: (label) => _open(label: label),
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('inbox.compose'),
          onPressed: () => context.push(Routes.appsCompose).ignore(),
          icon: const Icon(LucideIcons.squarePen, size: 20),
          label: Text(l10n.emailNavNewEmail),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              MailPager(
                leading: Checkbox(
                  key: const Key('inbox.selectAll'),
                  tristate: true,
                  semanticLabel: l10n.mailToolbarSelectAll,
                  value: allVisible ? true : (someVisible ? null : false),
                  onChanged: page.rows.isEmpty
                      ? null
                      : (_) => setState(() {
                          if (allVisible) {
                            _selected.removeAll(visibleIds);
                          } else {
                            _selected.addAll(visibleIds);
                          }
                        }),
                ),
                label: page.total == 0
                    ? l10n.inboxPageRangeEmpty
                    : l10n.inboxPageRange('${page.from}', '${page.to}', '${page.total}'),
                onPrevious: page.page > 0 ? () => setState(() => _page = page.page - 1) : null,
                onNext: page.page < page.pages - 1
                    ? () => setState(() => _page = page.page + 1)
                    : null,
              ),
              Expanded(
                child: page.rows.isEmpty
                    ? SingleChildScrollView(
                        child: EmptyState(
                          title: l10n.inboxPageEmptyTitle,
                          text: l10n.inboxPageEmptyText(title),
                        ),
                      )
                    : ListView.separated(
                        key: const Key('inbox.list'),
                        // Room for the floating button over the last row.
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: page.rows.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final message = page.rows[index];
                          return _SwipeRow(
                            key: ValueKey(message.id),
                            message: message,
                            confirm: _confirmSwipe,
                            onSwiped: (action) => _act([message.id], action),
                            child: _MailRow(
                              message: message,
                              selected: _selected.contains(message.id),
                              onOpen: () => _openMessage(message),
                              onToggle: () => _toggle(message),
                              onAction: (action) => _act([message.id], action),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The app bar title: the open folder or label, a menu of every folder (with its count) and
/// label. The phone's counterpart of the web's `EmailNav` sidebar.
class _FolderMenu extends ConsumerWidget {
  const _FolderMenu({
    required this.folder,
    required this.label,
    required this.title,
    required this.count,
    required this.onFolder,
    required this.onLabel,
  });

  final MailFolder? folder;
  final MailLabel? label;
  final String title;
  final int count;
  final ValueChanged<MailFolder> onFolder;
  final ValueChanged<MailLabel> onLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final messages = ref.watch(mailboxProvider);

    return PopupMenuButton<Object>(
      key: const Key('inbox.folders'),
      tooltip: l10n.emailNavLabel,
      position: PopupMenuPosition.under,
      onSelected: (value) {
        switch (value) {
          case final MailFolder folder:
            onFolder(folder);
          case final MailLabel label:
            onLabel(label);
        }
      },
      itemBuilder: (context) => [
        for (final item in MailFolder.values)
          PopupMenuItem<Object>(
            value: item,
            child: _MenuRow(
              leading: Icon(item.icon, size: 18),
              text: folderName(l10n, item),
              selected: item == folder,
              count: folderCount(messages, item),
              strongCount: item == MailFolder.inbox,
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<Object>(
          enabled: false,
          height: 32,
          child: Semantics(header: true, child: FormLabel(l10n.emailNavLabelsTitle)),
        ),
        for (final item in MailLabel.values)
          PopupMenuItem<Object>(
            value: item,
            child: _MenuRow(
              leading: LabelDot(item),
              text: labelName(l10n, item),
              selected: item == label,
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.page, vertical: Space.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(title, style: context.text.titleLarge, overflow: TextOverflow.ellipsis),
            ),
            if (count > 0) ...[const SizedBox(width: Space.sm), _CountBadge(count, strong: true)],
            const SizedBox(width: Space.xs),
            Icon(LucideIcons.chevronDown, size: 18, color: colors.ink600),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.leading,
    required this.text,
    required this.selected,
    this.count = 0,
    this.strongCount = false,
  });

  final Widget leading;
  final String text;
  final bool selected;
  final int count;
  final bool strongCount;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: Row(
      children: [
        SizedBox(width: 24, child: Center(child: leading)),
        const SizedBox(width: Space.md),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
          ),
        ),
        if (count > 0) _CountBadge(count, strong: strongCount),
      ],
    ),
  );
}

/// An unread count, read out as "4 unread".
class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count, {this.strong = false});

  final int count;

  /// Filled (the inbox), otherwise outlined.
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: context.l10n.emailNavCount(count),
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          decoration: BoxDecoration(
            color: strong ? colors.primary : null,
            border: Border.all(color: strong ? colors.primary : colors.ink300),
            borderRadius: BorderRadius.circular(Radii.xl),
          ),
          child: Text(
            '$count',
            style: context.type.table.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: strong ? colors.onPrimary : colors.ink700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Swipe right to archive, left to delete.
class _SwipeRow extends StatelessWidget {
  const _SwipeRow({
    required this.message,
    required this.confirm,
    required this.onSwiped,
    required this.child,
    super.key,
  });

  final Mail message;
  final Future<bool> Function(Mail message, MailAction action) confirm;
  final ValueChanged<MailAction> onSwiped;
  final Widget child;

  static MailAction _action(DismissDirection direction) => direction == DismissDirection.startToEnd
      ? const MoveTo(MailBox.archive)
      : const MoveTo(MailBox.trash);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Dismissible(
      key: ValueKey('swipe-${message.id}'),
      confirmDismiss: (direction) => confirm(message, _action(direction)),
      onDismissed: (direction) => onSwiped(_action(direction)),
      background: _SwipeBackground(
        color: colors.primary,
        foreground: colors.onPrimary,
        icon: LucideIcons.archive,
        text: l10n.mailToolbarArchive,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeBackground(
        color: colors.pen,
        foreground: colors.ply,
        icon: LucideIcons.trash2,
        text: l10n.mailToolbarDelete,
        alignment: Alignment.centerRight,
      ),
      child: child,
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.foreground,
    required this.icon,
    required this.text,
    required this.alignment,
  });

  final Color color;
  final Color foreground;
  final IconData icon;
  final String text;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
    color: color,
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: Space.lg),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: foreground, size: 20),
        const SizedBox(width: Space.sm),
        Text(
          text,
          style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

/// One message: the checkbox, the star, then sender (or recipient), time, subject, tags and
/// the first line of the body. Unread messages are bold with a dot.
class _MailRow extends StatelessWidget {
  const _MailRow({
    required this.message,
    required this.selected,
    required this.onOpen,
    required this.onToggle,
    required this.onAction,
  });

  final Mail message;
  final bool selected;
  final VoidCallback onOpen;
  final VoidCallback onToggle;
  final ValueChanged<MailAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final unread = !message.read;
    final who = message.outgoing
        ? l10n.inboxPageTo(
            message.to == null || message.to!.isEmpty ? l10n.inboxPageNoRecipient : message.to!,
          )
        : message.from;

    return Material(
      color: selected ? colors.ink100 : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.xs, Space.xs, 0, Space.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: selected,
              semanticLabel: l10n.inboxPageSelectMessage(message.subject),
              onChanged: (_) => onToggle(),
            ),
            IconButton(
              tooltip: l10n.inboxPageStarMessage(message.subject),
              isSelected: message.starred,
              onPressed: () => onAction(MarkStarred(!message.starred)),
              icon: Icon(Icons.star_border_rounded, color: colors.ink400),
              selectedIcon: Icon(Icons.star_rounded, color: colors.primary),
            ),
            Expanded(
              child: MergeSemantics(
                child: Semantics(
                  // The swipe actions and the read toggle, for screen readers and switch access.
                  customSemanticsActions: {
                    CustomSemanticsAction(label: l10n.mailToolbarArchive): () =>
                        onAction(const MoveTo(MailBox.archive)),
                    CustomSemanticsAction(label: l10n.mailToolbarDelete): () =>
                        onAction(const MoveTo(MailBox.trash)),
                    CustomSemanticsAction(
                      label: unread ? l10n.mailToolbarMarkRead : l10n.mailToolbarMarkUnread,
                    ): () =>
                        onAction(MarkRead(unread)),
                  },
                  child: InkWell(
                    key: Key('inbox.open.${message.id}'),
                    onTap: onOpen,
                    onLongPress: onToggle,
                    borderRadius: BorderRadius.circular(Radii.md),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(Space.xs, Space.sm, Space.page, Space.sm),
                      child: _MailSummary(message: message, who: who),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MailSummary extends StatelessWidget {
  const _MailSummary({required this.message, required this.who});

  final Mail message;
  final String who;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final unread = !message.read;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 2,
      children: [
        Row(
          children: [
            if (unread) ...[
              Semantics(
                label: l10n.inboxPageUnread,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: Space.sm),
            ],
            Expanded(
              child: Text(
                who,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
                  color: unread ? colors.ink950 : colors.ink700,
                ),
              ),
            ),
            const SizedBox(width: Space.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                context.formatDateTime(message.sentAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.table.copyWith(fontSize: 12, color: colors.ink600),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              message.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                color: unread ? colors.ink950 : colors.ink900,
              ),
            ),
            if (message.attachments.isNotEmpty)
              Semantics(
                label: l10n.inboxPageHasAttachments,
                child: Icon(LucideIcons.paperclip, size: 14, color: colors.ink600),
              ),
            if (message.labels.isNotEmpty) LabelTags(message.labels),
          ],
        ),
        Text(
          message.body.firstOrNull ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}
