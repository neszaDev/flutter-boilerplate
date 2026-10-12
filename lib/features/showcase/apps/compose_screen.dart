import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/apps/compose_validation.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_widgets.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox_controller.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Rule;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/apps/email/compose[?to=…&subject=…]`: the Vue compose view. Recipients,
/// subject, a rich-text body with its formatting toolbar, attachments and labels, then send
/// (to Sent), save as draft (to Drafts) or discard. A reply or a forward opens it prefilled.
class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _form = GlobalKey<FormState>();
  final _fields = {for (final field in ComposeField.values) field: TextEditingController()};
  final _body = QuillController.basic();
  final _bodyFocus = FocusNode();
  final _bodyScroll = ScrollController();
  final _files = <MailAttachment>[];
  final _labels = <MailLabel>[];
  var _submitted = false;
  var _readQuery = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_readQuery) {
      _readQuery = true;
      final query = GoRouterState.of(context).uri.queryParameters;
      _fields[ComposeField.to]!.text = query['to'] ?? '';
      _fields[ComposeField.subject]!.text = query['subject'] ?? '';
    }
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    _body.dispose();
    _bodyFocus.dispose();
    _bodyScroll.dispose();
    super.dispose();
  }

  String _value(ComposeField field) => _fields[field]!.text;

  /// Files the message under [box], as written.
  void _file(MailBox box) {
    final l10n = context.l10n;
    final mailbox = ref.read(mailboxProvider.notifier);
    final subject = _value(ComposeField.subject).trim();
    mailbox.add(
      outgoingMail(
        id: mailbox.newId(),
        sentAt: DateTime.now().toUtc(),
        to: splitAddresses(_value(ComposeField.to)).join(', '),
        subject: subject.isEmpty ? l10n.composePageNoSubject : subject,
        // Every line of the editor is a paragraph, as the web's blocks are.
        text: _body.document.toPlainText().split('\n').join('\n\n'),
        box: box,
        labels: [..._labels],
        attachments: [..._files],
      ),
    );
  }

  void _clear() {
    _form.currentState?.reset();
    for (final controller in _fields.values) {
      controller.clear();
    }
    _clearBody();
    setState(() {
      _files.clear();
      _labels.clear();
      _submitted = false;
    });
  }

  void _clearBody() {
    _body
      ..document = Document()
      ..toggledStyle = const Style();
  }

  void _send() {
    setState(() => _submitted = true);
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }
    _file(MailBox.sent);
    _clear();
    FocusScope.of(context).unfocus();
    showToast(context, context.l10n.composePageSent, tone: ToastTone.success);
  }

  void _saveDraft() {
    _file(MailBox.drafts);
    _clear();
    showToast(context, context.l10n.composePageDraftSaved, tone: ToastTone.success);
  }

  void _discard() {
    _clear();
    showToast(context, context.l10n.composePageDiscarded);
  }

  Future<void> _attach() async {
    final l10n = context.l10n;
    try {
      final picked = await FilePicker.pickFiles();
      final attachments = [
        for (final file in picked)
          attachmentOf(file.name, file.lengthSync() ?? await file.length() ?? 0),
      ];
      if (mounted) {
        setState(() => _files.addAll(attachments));
      }
    } on PlatformException {
      if (mounted) {
        showToast(context, l10n.commonErrorGeneric, tone: ToastTone.error);
      }
    }
  }

  void _toggleLabel(MailLabel label) => setState(() {
    if (!_labels.remove(label)) {
      _labels.add(label);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      ComposeField.to: (l10n.composePageToLabel, l10n.composePageToPlaceholder),
      ComposeField.cc: (l10n.composePageCcLabel, l10n.composePageCcPlaceholder),
      ComposeField.bcc: (l10n.composePageBccLabel, l10n.composePageBccPlaceholder),
      ComposeField.subject: (l10n.composePageSubjectLabel, l10n.composePageSubjectPlaceholder),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.composePageHeading)),
      body: SafeArea(
        top: false,
        child: Form(
          key: _form,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          // A column, not a lazy list: every field stays built, so validation sees them all.
          child: SingleChildScrollView(
            key: const Key('compose.form'),
            padding: const EdgeInsets.fromLTRB(Space.page, Space.page, Space.page, Space.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final MapEntry(key: field, value: (label, hint)) in labels.entries) ...[
                  LabeledField(
                    label: label,
                    child: Semantics(
                      label: label,
                      child: TextFormField(
                        key: Key('compose.${field.name}'),
                        controller: _fields[field],
                        keyboardType: field == ComposeField.subject
                            ? TextInputType.text
                            : TextInputType.emailAddress,
                        autocorrect: field == ComposeField.subject,
                        textCapitalization: field == ComposeField.subject
                            ? TextCapitalization.sentences
                            : TextCapitalization.none,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(hintText: hint),
                        validator: validator(l10n, composeRule(field)),
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.md),
                ],
                const SizedBox(height: Space.sm),
                ExcludeSemantics(child: FormLabel(l10n.composePageBodyLabel)),
                const SizedBox(height: Space.sm),
                _BodyEditor(
                  controller: _body,
                  focusNode: _bodyFocus,
                  scrollController: _bodyScroll,
                  labels: _labels.toSet(),
                  onClear: _clearBody,
                  onAttach: _attach,
                  onToggleLabel: _toggleLabel,
                ),
                if (_labels.isNotEmpty) ...[
                  const SizedBox(height: Space.md),
                  LabelTags(_labels),
                ],
                if (_files.isNotEmpty) ...[
                  const SizedBox(height: Space.md),
                  _AttachmentList(
                    files: _files,
                    onRemove: (index) => setState(() => _files.removeAt(index)),
                  ),
                ],
                const SizedBox(height: Space.lg),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: [
                    FilledButton.icon(
                      key: const Key('compose.send'),
                      onPressed: _send,
                      icon: const Icon(LucideIcons.send, size: 18),
                      label: Text(l10n.composePageSend),
                    ),
                    OutlinedButton(
                      key: const Key('compose.draft'),
                      onPressed: _saveDraft,
                      child: Text(l10n.composePageDraft),
                    ),
                    TextButton(
                      key: const Key('compose.discard'),
                      onPressed: _discard,
                      child: Text(l10n.composePageDiscard),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The message body: the formatting toolbar over a rich-text editor.
class _BodyEditor extends StatelessWidget {
  const _BodyEditor({
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.labels,
    required this.onClear,
    required this.onAttach,
    required this.onToggleLabel,
  });

  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final Set<MailLabel> labels;
  final VoidCallback onClear;
  final VoidCallback onAttach;
  final ValueChanged<MailLabel> onToggleLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.text.bodyMedium!.copyWith(height: 1.6, color: colors.ink900);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.ply,
        border: Border.all(color: colors.ink300),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Inside the editor's tap region: formatting keeps the keyboard up.
          TextFieldTapRegion(
            child: Semantics(
              container: true,
              label: l10n.composePageToolbarLabel,
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => _FormatBar(
                  controller: controller,
                  labels: labels,
                  onClear: onClear,
                  onAttach: onAttach,
                  onToggleLabel: onToggleLabel,
                ),
              ),
            ),
          ),
          const Divider(),
          Semantics(
            label: l10n.composePageBodyLabel,
            textField: true,
            multiline: true,
            child: DefaultTextStyle.merge(
              style: text,
              child: QuillEditor(
                key: const Key('compose.body'),
                controller: controller,
                focusNode: focusNode,
                scrollController: scrollController,
                config: QuillEditorConfig(
                  scrollable: false,
                  minHeight: 220,
                  padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      text,
                      HorizontalSpacing.zero,
                      const VerticalSpacing(6, 0),
                      VerticalSpacing.zero,
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bold, italic, underline, lists and indent, then clear, attach and the labels menu. A
/// pressed button shows the format at the cursor.
class _FormatBar extends StatelessWidget {
  const _FormatBar({
    required this.controller,
    required this.labels,
    required this.onClear,
    required this.onAttach,
    required this.onToggleLabel,
  });

  final QuillController controller;
  final Set<MailLabel> labels;
  final VoidCallback onClear;
  final VoidCallback onAttach;
  final ValueChanged<MailLabel> onToggleLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final attributes = controller.getSelectionStyle().attributes;
    final list = attributes[Attribute.list.key]?.value;
    final inList = list != null;
    final indent = attributes[Attribute.indent.key]?.value;

    bool on(Attribute<Object?> attribute) => attributes[attribute.key]?.value == attribute.value;
    void toggle(Attribute<Object?> attribute) => controller.formatSelection(
      on(attribute) ? Attribute.clone(attribute, null) : attribute,
    );

    Widget button({
      required String key,
      required String tooltip,
      required IconData icon,
      required VoidCallback? onPressed,
      bool? selected,
    }) => IconButton(
      key: Key('compose.$key'),
      tooltip: tooltip,
      isSelected: selected,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: context.colors.ink700,
        backgroundColor: selected ?? false ? context.colors.ink100 : null,
      ),
      icon: Icon(icon, size: 18),
    );

    Widget gap() => ExcludeSemantics(
      child: Container(
        width: 1,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: Space.xs),
        color: context.colors.ink200,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(Space.xs),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          button(
            key: 'bold',
            tooltip: l10n.composePageBold,
            icon: LucideIcons.bold,
            selected: on(Attribute.bold),
            onPressed: () => toggle(Attribute.bold),
          ),
          button(
            key: 'italic',
            tooltip: l10n.composePageItalic,
            icon: LucideIcons.italic,
            selected: on(Attribute.italic),
            onPressed: () => toggle(Attribute.italic),
          ),
          button(
            key: 'underline',
            tooltip: l10n.composePageUnderline,
            icon: LucideIcons.underline,
            selected: on(Attribute.underline),
            onPressed: () => toggle(Attribute.underline),
          ),
          gap(),
          button(
            key: 'bulletList',
            tooltip: l10n.composePageBulletList,
            icon: LucideIcons.list,
            selected: on(Attribute.ul),
            onPressed: () => toggle(Attribute.ul),
          ),
          button(
            key: 'orderedList',
            tooltip: l10n.composePageOrderedList,
            icon: LucideIcons.listOrdered,
            selected: on(Attribute.ol),
            onPressed: () => toggle(Attribute.ol),
          ),
          button(
            key: 'indent',
            tooltip: l10n.composePageIndent,
            icon: LucideIcons.indentIncrease,
            onPressed: inList ? () => controller.indentSelection(true) : null,
          ),
          button(
            key: 'outdent',
            tooltip: l10n.composePageOutdent,
            icon: LucideIcons.indentDecrease,
            // Out of the first level, the line leaves the list (the web's "lift").
            onPressed: !inList
                ? null
                : () => indent == null
                      ? controller.formatSelection(Attribute.clone(Attribute.list, null))
                      : controller.indentSelection(false),
          ),
          gap(),
          button(
            key: 'clearBody',
            tooltip: l10n.composePageClearBody,
            icon: LucideIcons.trash2,
            onPressed: onClear,
          ),
          button(
            key: 'attach',
            tooltip: l10n.composePageAttach,
            icon: LucideIcons.paperclip,
            onPressed: onAttach,
          ),
          LabelMenuButton(checked: labels, onToggle: onToggleLabel),
        ],
      ),
    );
  }
}

/// The attached files, each with a remove button.
class _AttachmentList extends StatelessWidget {
  const _AttachmentList({required this.files, required this.onRemove});

  final List<MailAttachment> files;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Semantics(
      container: true,
      label: l10n.composePageAttachmentsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, file) in files.indexed)
            Row(
              children: [
                Icon(LucideIcons.paperclip, size: 14, color: colors.ink600),
                const SizedBox(width: Space.sm),
                Flexible(
                  child: Text(
                    file.name,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.ink950,
                    ),
                  ),
                ),
                const SizedBox(width: Space.sm),
                Text(
                  l10n.messagePageSizeKb(context.formatNumber(file.sizeKb)),
                  style: context.type.table.copyWith(fontSize: 13, color: colors.ink600),
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.composePageRemoveAttachment(file.name),
                  onPressed: () => onRemove(index),
                  icon: const Icon(LucideIcons.x, size: 16),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
