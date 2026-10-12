import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The folder's name in the mail menu.
String folderName(AppLocalizations l10n, MailFolder folder) => switch (folder) {
  MailFolder.inbox => l10n.emailNavFolderInbox,
  MailFolder.starred => l10n.emailNavFolderStarred,
  MailFolder.sent => l10n.emailNavFolderSent,
  MailFolder.drafts => l10n.emailNavFolderDrafts,
  MailFolder.archive => l10n.emailNavFolderArchive,
  MailFolder.trash => l10n.emailNavFolderTrash,
  MailFolder.important => l10n.emailNavFolderImportant,
  MailFolder.spam => l10n.emailNavFolderSpam,
};

/// The label's name.
String labelName(AppLocalizations l10n, MailLabel label) => switch (label) {
  MailLabel.home => l10n.emailNavLabelHome,
  MailLabel.job => l10n.emailNavLabelJob,
  MailLabel.clients => l10n.emailNavLabelClients,
  MailLabel.news => l10n.emailNavLabelNews,
};

/// "7 kB", "2.5 MB" ("2,5 Mo" in French).
String attachmentSize(AppLocalizations l10n, int sizeKb) {
  final number = NumberFormat.decimalPattern(l10n.localeName)..maximumFractionDigits = 1;
  return sizeKb >= 1024
      ? l10n.messagePageSizeMb(number.format(sizeKb / 1024))
      : l10n.messagePageSizeKb(number.format(sizeKb));
}

/// The coloured dot of a label (decorative: the label's name always goes with it).
class LabelDot extends StatelessWidget {
  const LabelDot(this.label, {this.size = 10, super.key});

  final MailLabel label;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: label.color(context.colors), shape: BoxShape.circle),
    ),
  );
}

/// A small upper-case tag: a label of a message or the type of an attachment.
class MailTag extends StatelessWidget {
  const MailTag({required this.text, this.label, super.key});

  final String text;

  /// Adds the label's dot before [text].
  final MailLabel? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: colors.ply,
        border: Border.all(color: colors.ink300),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[LabelDot(label!, size: 8), const SizedBox(width: 6)],
          Text(
            text.toUpperCase(),
            style: context.type.formLabel.copyWith(
              fontSize: 10.5,
              letterSpacing: 0.84,
              color: colors.ink700,
            ),
          ),
        ],
      ),
    );
  }
}

/// The labels of a message as small tags; nothing when it has none.
class LabelTags extends StatelessWidget {
  const LabelTags(this.labels, {super.key});

  final List<MailLabel> labels;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: Space.xs,
      runSpacing: Space.xs,
      children: [
        for (final label in labels) MailTag(text: labelName(context.l10n, label), label: label),
      ],
    );
  }
}

/// The labels menu (Vue `LabelDropdown`): toggles a label on the selected messages or the
/// draft. [checked] are the labels every target already has.
class LabelMenuButton extends StatelessWidget {
  const LabelMenuButton({
    required this.checked,
    required this.onToggle,
    this.enabled = true,
    super.key,
  });

  final Set<MailLabel> checked;
  final ValueChanged<MailLabel> onToggle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopupMenuButton<MailLabel>(
      key: const Key('mail.labels'),
      enabled: enabled,
      tooltip: l10n.emailNavLabelsMenu,
      icon: const Icon(LucideIcons.tag, size: 20),
      onSelected: onToggle,
      itemBuilder: (context) => [
        _MenuHeader(l10n.emailNavLabelsTitle),
        ...labelItems(context, checked),
      ],
    );
  }
}

/// One checkable item per label, "Add label Job" with the label's dot.
List<PopupMenuEntry<T>> labelItems<T extends Object>(BuildContext context, Set<MailLabel> checked) {
  final l10n = context.l10n;
  return [
    for (final label in MailLabel.values)
      CheckedPopupMenuItem<T>(
        value: label as T,
        checked: checked.contains(label),
        child: Row(
          children: [
            LabelDot(label),
            const SizedBox(width: Space.sm),
            Flexible(child: Text(l10n.emailNavAddLabel(labelName(l10n, label)))),
          ],
        ),
      ),
  ];
}

/// A heading inside a popup menu.
class _MenuHeader<T> extends PopupMenuEntry<T> {
  const _MenuHeader(this.text);

  final String text;

  @override
  double get height => 32;

  @override
  bool represents(T? value) => false;

  @override
  State<_MenuHeader<T>> createState() => _MenuHeaderState<T>();
}

class _MenuHeaderState<T> extends State<_MenuHeader<T>> {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, Space.xs),
    child: Semantics(header: true, child: FormLabel(widget.text)),
  );
}

enum _More { star, important, reply, replyAll, forward }

/// The toolbar of the web's `MailToolbar` for an app bar: read/unread, archive and delete as
/// buttons, then star, important, reply, reply all, forward and the labels in a menu.
class MailActionBar extends StatelessWidget {
  const MailActionBar({required this.targets, required this.onAction, super.key});

  /// The messages the actions apply to.
  final List<Mail> targets;
  final ValueChanged<MailAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final none = targets.isEmpty;
    final allRead = !none && targets.every((message) => message.read);
    final allStarred = !none && targets.every((message) => message.starred);
    final allImportant = !none && targets.every((message) => message.important);
    final labels = sharedLabels(targets);
    // Reply, reply all and forward need exactly one message.
    final single = targets.length == 1 ? targets.first : null;

    void more(Object value) {
      switch (value) {
        case _More.star:
          onAction(MarkStarred(!allStarred));
        case _More.important:
          onAction(MarkImportant(!allImportant));
        case _More.reply || _More.replyAll when single != null:
          context
              .push(
                composeLocation(
                  to: single.email,
                  subject: l10n.mailToolbarReplySubject(single.subject),
                ),
              )
              .ignore();
        case _More.forward when single != null:
          context
              .push(composeLocation(subject: l10n.mailToolbarForwardSubject(single.subject)))
              .ignore();
        case final MailLabel label:
          onAction(SetLabel(label, value: !labels.contains(label)));
      }
    }

    PopupMenuItem<Object> link(_More value, IconData icon, String text) => PopupMenuItem<Object>(
      value: value,
      enabled: single != null,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, size: 20),
        title: Text(text),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const Key('mail.read'),
          tooltip: allRead ? l10n.mailToolbarMarkUnread : l10n.mailToolbarMarkRead,
          onPressed: none ? null : () => onAction(MarkRead(!allRead)),
          icon: Icon(allRead ? LucideIcons.mail : LucideIcons.mailOpen, size: 20),
        ),
        IconButton(
          key: const Key('mail.archive'),
          tooltip: l10n.mailToolbarArchive,
          onPressed: none ? null : () => onAction(const MoveTo(MailBox.archive)),
          icon: const Icon(LucideIcons.archive, size: 20),
        ),
        IconButton(
          key: const Key('mail.delete'),
          tooltip: l10n.mailToolbarDelete,
          onPressed: none ? null : () => onAction(const MoveTo(MailBox.trash)),
          icon: const Icon(LucideIcons.trash2, size: 20),
        ),
        PopupMenuButton<Object>(
          key: const Key('mail.more'),
          enabled: !none,
          tooltip: l10n.mailToolbarLabel,
          onSelected: more,
          itemBuilder: (context) => [
            CheckedPopupMenuItem<Object>(
              value: _More.star,
              checked: allStarred,
              child: Text(l10n.mailToolbarStar),
            ),
            CheckedPopupMenuItem<Object>(
              value: _More.important,
              checked: allImportant,
              child: Text(l10n.mailToolbarImportant),
            ),
            const PopupMenuDivider(),
            link(_More.reply, LucideIcons.reply, l10n.mailToolbarReply),
            link(_More.replyAll, LucideIcons.replyAll, l10n.mailToolbarReplyAll),
            link(_More.forward, LucideIcons.forward, l10n.mailToolbarForward),
            const PopupMenuDivider(),
            _MenuHeader<Object>(l10n.emailNavLabelsTitle),
            ...labelItems<Object>(context, labels),
          ],
        ),
      ],
    );
  }
}

/// A position ("1–10 of 13") with previous and next buttons, under the app bar.
class MailPager extends StatelessWidget {
  const MailPager({required this.label, this.onPrevious, this.onNext, this.leading, super.key});

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// Before the position, e.g. the select-all box.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.ink200)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs),
        child: Row(
          children: [
            ?leading,
            const Spacer(),
            Text(
              label,
              style: context.type.table.copyWith(fontSize: 13, color: context.colors.ink600),
            ),
            const SizedBox(width: Space.xs),
            IconButton(
              key: const Key('mail.previous'),
              tooltip: l10n.mailToolbarPrevious,
              onPressed: onPrevious,
              icon: const Icon(LucideIcons.chevronLeft, size: 20),
            ),
            IconButton(
              key: const Key('mail.next'),
              tooltip: l10n.mailToolbarNext,
              onPressed: onNext,
              icon: const Icon(LucideIcons.chevronRight, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
