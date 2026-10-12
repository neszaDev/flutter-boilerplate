import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// A demo form (the web's `DemoForm`): submitting keeps the values and closes the keyboard,
/// resetting mounts the fields afresh so every control goes back to its default.
///
/// Fields inside keep their own state (no controllers from outside), so a reset clears them.
class DemoForm extends StatefulWidget {
  const DemoForm({required this.child, super.key});

  final Widget child;

  /// The form around [context]; [FormActions] buttons call it.
  static DemoFormState of(BuildContext context) =>
      context.findAncestorStateOfType<DemoFormState>()!;

  @override
  State<DemoForm> createState() => DemoFormState();
}

/// Submits (closes the keyboard) and resets a [DemoForm].
class DemoFormState extends State<DemoForm> {
  int _generation = 0;

  /// Closes the keyboard; the demo has nowhere to send the values.
  void submit() => FocusScope.of(context).unfocus();

  /// Puts every control back to its default.
  void reset() {
    FocusScope.of(context).unfocus();
    setState(() => _generation++);
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(
    key: ValueKey(_generation),
    child: Form(child: widget.child),
  );
}

/// The button row closing a demo form, ruled off from the fields like a card footer.
class FormActions extends StatelessWidget {
  const FormActions({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Divider(color: context.colors.ink200),
      const SizedBox(height: Space.page),
      Wrap(spacing: Space.sm, runSpacing: Space.sm, children: children),
    ],
  );
}

/// "Submit" and the red "Reset" of most demo forms.
class SubmitResetActions extends StatelessWidget {
  const SubmitResetActions({
    this.submitIcon = LucideIcons.circleCheck,
    this.submitLabel,
    super.key,
  });

  final IconData submitIcon;

  /// Defaults to "Submit".
  final String? submitLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final form = DemoForm.of(context);
    return FormActions(
      children: [
        FilledButton.icon(
          onPressed: form.submit,
          icon: Icon(submitIcon, size: 18),
          label: Text(submitLabel ?? l10n.basicFormsPageSubmit),
        ),
        FilledButton.icon(
          style: destructiveButtonStyle(context),
          onPressed: form.reset,
          icon: const Icon(LucideIcons.ban, size: 18),
          label: Text(l10n.basicFormsPageReset),
        ),
      ],
    );
  }
}

/// The red pen variant of a filled button (the web's `destructive`).
ButtonStyle destructiveButtonStyle(BuildContext context) => FilledButton.styleFrom(
  backgroundColor: context.colors.pen,
  foregroundColor: context.colors.ply,
);

/// The web's `HorizontalField`: the label beside the control on wider screens, above it on a
/// phone. With [group], the label names a group of controls (checkboxes, radios).
class HorizontalField extends StatelessWidget {
  const HorizontalField({
    required this.label,
    required this.child,
    this.group = false,
    super.key,
  });

  /// Below this width the label goes above the control.
  static const breakpoint = 480.0;

  final String label;
  final Widget child;
  final bool group;

  @override
  Widget build(BuildContext context) {
    final printed = ExcludeSemantics(child: Text(label, style: context.text.titleSmall));
    final control = group
        ? Semantics(container: true, explicitChildNodes: true, label: label, child: child)
        : Semantics(label: label, child: child);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [printed, const SizedBox(height: 6), control],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 144,
              child: Padding(
                padding: const EdgeInsets.only(top: Space.md),
                child: printed,
              ),
            ),
            const SizedBox(width: Space.page),
            Expanded(child: control),
          ],
        );
      },
    );
  }
}

/// A card-header link to a library's documentation, opened in the browser.
class DocsLink extends StatelessWidget {
  const DocsLink({required this.url, required this.label, required this.title, super.key});

  final String url;

  /// Visible text, such as "Docs".
  final String label;

  /// What the link opens, naming the library (tooltip and screen reader label).
  final String title;

  Future<void> _open() async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => Tooltip(
    message: title,
    child: TextButton.icon(
      onPressed: _open,
      iconAlignment: IconAlignment.end,
      icon: const Icon(LucideIcons.externalLink, size: 16),
      label: Text(label),
    ),
  );
}

/// The look of the web's file fields (prompt and "Browse" tag), disabled: on the phone, files
/// are picked on the Files screen.
class PlaceholderFileField extends StatelessWidget {
  const PlaceholderFileField({required this.prompt, required this.browse, super.key});

  final String prompt;
  final String browse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 44,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.ply,
        border: Border.all(color: colors.ink200),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.md),
              child: Text(
                prompt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(color: colors.ink400),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Space.md),
            decoration: BoxDecoration(
              color: colors.paperCard,
              border: Border(left: BorderSide(color: colors.ink200)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.upload, size: 16, color: colors.ink400),
                const SizedBox(width: 6),
                Text(browse, style: context.text.labelLarge?.copyWith(color: colors.ink400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
