import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The message of a [MessageDialog]; [number] and [code] print as `# number-code`.
@immutable
class DialogMessageContent {
  const DialogMessageContent({
    required this.title,
    required this.message,
    required this.number,
    required this.code,
  });

  final String title;
  final String message;
  final String number;
  final String code;
}

enum DialogButtonVariant { primary, outline }

/// One button of a [MessageDialog]; pressing it closes the dialog with its [code].
@immutable
class DialogMessageButton {
  const DialogMessageButton({
    required this.code,
    required this.label,
    this.icon,
    this.variant = DialogButtonVariant.outline,
  });

  final String code;
  final String label;
  final IconData? icon;
  final DialogButtonVariant variant;
}

/// Shows a [MessageDialog]. Resolves to the pressed button's code, or null when the dialog was
/// dismissed with the back gesture. A tap outside does not close it.
Future<String?> showMessageDialog(
  BuildContext context, {
  required DialogMessageContent content,
  required List<DialogMessageButton> buttons,
}) => showDialog<String>(
  context: context,
  barrierDismissible: false,
  builder: (_) => MessageDialog(content: content, buttons: buttons),
);

/// The error message dialog (Vue `DialogMessage`): a title, the message, a reference code and
/// a configurable row of buttons.
class MessageDialog extends StatelessWidget {
  const MessageDialog({required this.content, required this.buttons, super.key});

  final DialogMessageContent content;
  final List<DialogMessageButton> buttons;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reference = '${content.number}-${content.code}';
    return AlertDialog(
      semanticLabel: content.title,
      clipBehavior: Clip.antiAlias,
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.card, vertical: Space.page),
        decoration: BoxDecoration(
          color: colors.pen.withValues(alpha: 0.06),
          border: Border(bottom: BorderSide(color: colors.pen.withValues(alpha: 0.2))),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.messageSquareWarning, size: 20, color: colors.pen),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text(
                content.title,
                style: context.text.titleMedium?.copyWith(
                  color: colors.pen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: Space.sm),
            Semantics(
              container: true,
              label: '${context.l10n.campusMessageDialogReference} $reference',
              excludeSemantics: true,
              child: Text('# $reference', style: context.type.table.copyWith(fontSize: 12)),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(Space.card, Space.card, Space.card, Space.sm),
      content: Text(
        content.message,
        style: context.text.bodyMedium?.copyWith(color: colors.ink900),
      ),
      actions: [
        for (final button in buttons)
          switch (button.variant) {
            DialogButtonVariant.primary => FilledButton.icon(
              onPressed: () => Navigator.pop(context, button.code),
              icon: button.icon == null ? null : Icon(button.icon, size: 18),
              label: Text(button.label),
            ),
            DialogButtonVariant.outline => OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, button.code),
              icon: button.icon == null ? null : Icon(button.icon, size: 18),
              label: Text(button.label),
            ),
          },
      ],
    );
  }
}
