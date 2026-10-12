import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';

/// A change applied to some messages (the toolbar, a swipe, a star).
sealed class MailAction {
  const MailAction();
}

final class MarkRead extends MailAction {
  const MarkRead(this.value);

  final bool value;
}

final class MarkStarred extends MailAction {
  const MarkStarred(this.value);

  final bool value;
}

final class MarkImportant extends MailAction {
  const MarkImportant(this.value);

  final bool value;
}

final class SetLabel extends MailAction {
  const SetLabel(this.label, {required this.value});

  final MailLabel label;
  final bool value;
}

/// Files the messages in [box]. Moving to the trash what is already there deletes it for good.
final class MoveTo extends MailAction {
  const MoveTo(this.box);

  final MailBox box;
}

final class DeleteMail extends MailAction {
  const DeleteMail();
}

/// Narrows a `?folder=` value to a known folder: [MailFolder.inbox] for anything else.
MailFolder toFolder(String? value) =>
    MailFolder.values.where((folder) => folder.name == value).firstOrNull ?? MailFolder.inbox;

/// Narrows a `?label=` value to a known label, or null.
MailLabel? toLabel(String? value) =>
    MailLabel.values.where((label) => label.name == value).firstOrNull;

bool _hidden(Mail message) => message.box == MailBox.trash || message.box == MailBox.spam;

bool _inFolder(Mail message, MailFolder folder) => switch (folder) {
  MailFolder.starred => message.starred && !_hidden(message),
  MailFolder.important => message.important && !_hidden(message),
  _ => message.box.name == folder.name,
};

List<Mail> _newestFirst(Iterable<Mail> messages) =>
    messages.toList()..sort((a, b) => b.sentAt.compareTo(a.sentAt));

/// The messages of [folder], newest first.
List<Mail> folderMessages(List<Mail> messages, MailFolder folder) =>
    _newestFirst(messages.where((message) => _inFolder(message, folder)));

/// The messages carrying [label], newest first (trash and spam left out).
List<Mail> labelMessages(List<Mail> messages, MailLabel label) => _newestFirst(
  messages.where((message) => message.labels.contains(label) && !_hidden(message)),
);

/// A menu count: the unread messages of [folder], or every draft for Drafts.
int folderCount(List<Mail> messages, MailFolder folder) => folderMessages(
  messages,
  folder,
).where((message) => folder == MailFolder.drafts || !message.read).length;

List<Mail> _update(Mail message, MailAction action) => switch (action) {
  MarkRead(:final value) => [message.copyWith(read: value)],
  MarkStarred(:final value) => [message.copyWith(starred: value)],
  MarkImportant(:final value) => [message.copyWith(important: value)],
  SetLabel(:final label, :final value) => [
    message.copyWith(
      labels: [...message.labels.where((other) => other != label), if (value) label],
    ),
  ],
  // Moving to the trash from the trash deletes for good.
  MoveTo(:final box) =>
    box == MailBox.trash && message.box == MailBox.trash ? [] : [message.copyWith(box: box)],
  DeleteMail() => [],
};

/// Applies [action] to the messages with [ids]; the others are kept as they are.
List<Mail> applyMailAction(List<Mail> messages, Iterable<String> ids, MailAction action) {
  final targets = ids.toSet();
  return [
    for (final message in messages)
      if (targets.contains(message.id)) ..._update(message, action) else message,
  ];
}

/// The compose screen, prefilled for a reply or a forward.
String composeLocation({String? to, String? subject}) {
  final query = {
    if (to != null && to.isNotEmpty) 'to': to,
    if (subject != null && subject.isNotEmpty) 'subject': subject,
  };
  return Uri(path: Routes.appsCompose, queryParameters: query.isEmpty ? null : query).toString();
}

/// One message on its own screen, opened from [folder].
String messageLocation(String id, MailFolder folder) => Uri(
  path: Routes.appsMessage,
  queryParameters: {'id': id, 'folder': folder.name},
).toString();

/// A message written here (a reply, a sent message or a draft), from the mailbox owner.
/// Blank lines in [text] separate paragraphs.
Mail outgoingMail({
  required String id,
  required DateTime sentAt,
  required String to,
  required String subject,
  required String text,
  required MailBox box,
  List<MailLabel> labels = const [],
  List<MailAttachment> attachments = const [],
}) => Mail(
  id: id,
  from: me.name,
  email: me.email,
  to: to,
  sentAt: sentAt,
  subject: subject,
  body: text
      .split(RegExp(r'\n\s*\n'))
      .map((paragraph) => paragraph.trim())
      .where((paragraph) => paragraph.isNotEmpty)
      .toList(),
  box: box,
  labels: labels,
  attachments: attachments,
);

/// One page of a message list: the rows to show and the position among all of them.
typedef MailPage = ({List<Mail> rows, int page, int pages, int from, int to, int total});

/// Ten rows per page, as in the Vue inbox.
const mailPageSize = 10;

/// Page [page] of [list] (clamped to the last page). [MailPage.from] is 1-based; both ends
/// are 0 for an empty list.
MailPage mailPage(List<Mail> list, int page) {
  final pages = list.isEmpty ? 1 : (list.length / mailPageSize).ceil();
  final current = page.clamp(0, pages - 1);
  final start = current * mailPageSize;
  final rows = list.skip(start).take(mailPageSize).toList();
  return (
    rows: rows,
    page: current,
    pages: pages,
    from: rows.isEmpty ? 0 : start + 1,
    to: start + rows.length,
    total: list.length,
  );
}

/// The labels every one of [messages] carries (none when [messages] is empty).
Set<MailLabel> sharedLabels(List<Mail> messages) => {
  for (final label in MailLabel.values)
    if (messages.isNotEmpty && messages.every((message) => message.labels.contains(label))) label,
};

/// A picked file as an attachment: its extension as the type (`file` without one) and its size
/// in whole kilobytes, at least 1.
MailAttachment attachmentOf(String name, int bytes) => MailAttachment(
  name: name,
  kind: name.contains('.') ? name.split('.').last : 'file',
  sizeKb: (bytes / 1024).round().clamp(1, 1 << 31),
);
