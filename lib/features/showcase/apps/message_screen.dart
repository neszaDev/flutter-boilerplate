import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_widgets.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/apps/email/message?id=…&folder=…`: the Vue message view. The app bar acts on
/// the message, previous/next walk the folder, and a reply box sits under the message. Without
/// an id it shows the folder's newest message.
class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({super.key});

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  String? _id;
  var _folder = MailFolder.inbox;
  var _readQuery = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_readQuery) {
      _readQuery = true;
      final query = GoRouterState.of(context).uri.queryParameters;
      _id = query['id'];
      _folder = toFolder(query['folder']);
    }
  }

  /// Back to the folder: the inbox screen under this one, or a fresh one.
  void _backToFolder() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Uri(path: Routes.appsInbox, queryParameters: {'folder': _folder.name}).toString());
    }
  }

  void _show(Mail target) {
    ref.read(mailboxProvider.notifier).apply([target.id], const MarkRead(true));
    setState(() => _id = target.id);
  }

  void _act(Mail message, MailAction action) {
    final l10n = context.l10n;
    ref.read(mailboxProvider.notifier).apply([message.id], action);
    if (action is MoveTo) {
      showToast(
        context,
        action.box == MailBox.archive
            ? l10n.messagePageArchived
            : (message.box == MailBox.trash ? l10n.messagePageDeleted : l10n.messagePageTrashed),
        tone: ToastTone.success,
      );
      _backToFolder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final messages = ref.watch(mailboxProvider);
    final list = folderMessages(messages, _folder);
    final message = _id == null
        ? list.firstOrNull
        : messages.where((candidate) => candidate.id == _id).firstOrNull;

    if (message == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.messagePageTitle)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Space.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.mailQuestionMark, size: 28, color: context.colors.ink400),
                EmptyState(
                  title: l10n.messagePageNotFoundTitle,
                  text: l10n.messagePageNotFoundText,
                  action: OutlinedButton.icon(
                    key: const Key('message.back'),
                    onPressed: _backToFolder,
                    icon: const Icon(LucideIcons.arrowLeft, size: 18),
                    label: Text(l10n.messagePageBackToFolder(folderName(l10n, _folder))),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final index = list.indexWhere((candidate) => candidate.id == message.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.messagePageTitle),
        actions: [
          MailActionBar(targets: [message], onAction: (action) => _act(message, action)),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            MailPager(
              label: index == -1 ? '' : l10n.messagePagePosition('${index + 1}', '${list.length}'),
              onPrevious: index > 0 ? () => _show(list[index - 1]) : null,
              onNext: index != -1 && index < list.length - 1 ? () => _show(list[index + 1]) : null,
            ),
            Expanded(
              child: ListView(
                key: const Key('message.body'),
                padding: const EdgeInsets.fromLTRB(Space.page, Space.page, Space.page, Space.xl),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Space.card),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Space.lg,
                        children: [
                          _Header(message: message),
                          _Body(message: message),
                          if (message.attachments.isNotEmpty) _Attachments(message: message),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.lg),
                  _ReplyForm(key: ValueKey(message.id), message: message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subject, labels, sender, recipient and date, over a rule.
class _Header extends StatelessWidget {
  const _Header({required this.message});

  final Mail message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final small = context.text.bodySmall?.copyWith(color: colors.ink600);
    final sentAt = message.sentAt.toLocal();
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.ink200)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: Space.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Space.sm,
          children: [
            Semantics(
              header: true,
              child: Text(message.subject, style: context.text.headlineSmall),
            ),
            if (message.labels.isNotEmpty) LabelTags(message.labels),
            Wrap(
              spacing: Space.sm,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text(
                  message.from,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.ink950,
                  ),
                ),
                Text(
                  message.email,
                  style: context.text.bodyMedium?.copyWith(color: colors.ink600),
                ),
              ],
            ),
            if (message.to != null && message.to!.isNotEmpty)
              Text(l10n.messagePageTo(message.to!), style: small),
            RichMessage(
              l10n.messagePageSentAt(
                DateFormat.yMMMMEEEEd(l10n.localeName).format(sentAt),
                context.formatTime(sentAt),
              ),
              style: small,
              tags: {
                'strong': (text) => TextSpan(
                  text: text,
                  style: TextStyle(fontWeight: FontWeight.w600, color: colors.ink900),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The paragraphs and the quoted passage.
class _Body extends StatelessWidget {
  const _Body({required this.message});

  final Mail message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.text.bodyMedium?.copyWith(height: 1.65);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Space.page,
      children: [
        for (final paragraph in message.body) Text(paragraph, style: style),
        if (message.quote != null)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: colors.ink300, width: 2)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: Space.page),
              child: Text(message.quote!, style: style?.copyWith(color: colors.ink600)),
            ),
          ),
      ],
    );
  }
}

enum _AttachmentAction { preview, share, download }

/// The attached files: type, name and size, with preview, share and download in a menu (the
/// files are samples, so each says so).
class _Attachments extends StatelessWidget {
  const _Attachments({required this.message});

  final Mail message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: FormLabel(l10n.messagePageAttachments(message.attachments.length)),
        ),
        const SizedBox(height: Space.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colors.ink200),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Column(
            children: [
              for (final (index, file) in message.attachments.indexed) ...[
                if (index > 0) const Divider(),
                _AttachmentRow(file: file),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.file});

  final MailAttachment file;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void unavailable() => showToast(context, l10n.messagePageAttachmentUnavailable(file.name));
    return InkWell(
      onTap: unavailable,
      child: Padding(
        padding: const EdgeInsets.only(left: Space.md),
        child: Row(
          children: [
            MailTag(text: file.kind),
            const SizedBox(width: Space.md),
            Expanded(
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(color: context.colors.ink950),
                    ),
                    Text(
                      attachmentSize(l10n, file.sizeKb),
                      style: context.type.table.copyWith(
                        fontSize: 13,
                        color: context.colors.ink600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<_AttachmentAction>(
              tooltip: l10n.messagePageAttachmentActions(file.name),
              onSelected: (_) => unavailable(),
              itemBuilder: (context) => [
                for (final (action, icon, text) in [
                  (_AttachmentAction.preview, LucideIcons.eye, l10n.messagePagePreview(file.name)),
                  (_AttachmentAction.share, LucideIcons.share2, l10n.messagePageShare(file.name)),
                  (
                    _AttachmentAction.download,
                    LucideIcons.download,
                    l10n.messagePageDownload(file.name),
                  ),
                ])
                  PopupMenuItem(
                    value: action,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(icon, size: 20),
                      title: Text(text),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The reply box under a message: sending it files the reply under Sent.
class _ReplyForm extends ConsumerStatefulWidget {
  const _ReplyForm({required this.message, super.key});

  final Mail message;

  @override
  ConsumerState<_ReplyForm> createState() => _ReplyFormState();
}

class _ReplyFormState extends ConsumerState<_ReplyForm> {
  final _form = GlobalKey<FormState>();
  final _reply = TextEditingController();
  var _submitted = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  void _send() {
    setState(() => _submitted = true);
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }
    final l10n = context.l10n;
    final mailbox = ref.read(mailboxProvider.notifier);
    mailbox.add(
      outgoingMail(
        id: mailbox.newId(),
        sentAt: DateTime.now().toUtc(),
        to: widget.message.email,
        subject: l10n.mailToolbarReplySubject(widget.message.subject),
        text: _reply.text,
        box: MailBox.sent,
      ),
    );
    _form.currentState?.reset();
    _reply.clear();
    setState(() => _submitted = false);
    FocusScope.of(context).unfocus();
    showToast(context, l10n.messagePageReplySent, tone: ToastTone.success);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _form,
      autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label: l10n.messagePageReplyLabel,
            child: TextFormField(
              key: const Key('message.reply'),
              controller: _reply,
              minLines: 5,
              maxLines: 12,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: l10n.messagePageReplyPlaceholder),
              validator: validator(l10n, Rules.required),
            ),
          ),
          const SizedBox(height: Space.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton(
              key: const Key('message.sendReply'),
              onPressed: _send,
              child: Text(l10n.messagePageSendReply),
            ),
          ),
        ],
      ),
    );
  }
}
