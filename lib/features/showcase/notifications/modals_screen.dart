import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Width of a modal.
enum _ModalSize { small, normal, large }

/// Colour of a modal's header band.
enum _ModalTone { plain, folder, pass, pencil, muted, deep }

/// `/dashboard/notifications/modals`: dialogs of every size and kind, a destructive
/// confirmation, a full-screen dialog, and the phone's bottom sheets.
class ModalsScreen extends StatelessWidget {
  const ModalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.modalsPageTitle,
      description: Text(l10n.modalsPageDescription),
      children: [
        DemoCard(
          title: l10n.modalsPageCardTitle,
          description: l10n.modalsPageCardDescription,
          child: const _ModalButtons(),
        ),
        DemoCard(
          title: l10n.modalsPageSheetsTitle,
          description: l10n.modalsPageSheetsDescription,
          child: const _SheetButtons(),
        ),
      ],
    );
  }
}

class _ModalButtons extends StatelessWidget {
  const _ModalButtons();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    // Every modal keeps within 85 % of the screen and scrolls its body when it is longer.
    void open({
      required String title,
      String? description,
      _ModalSize size = _ModalSize.normal,
      _ModalTone tone = _ModalTone.plain,
      bool modalOnly = false,
      List<Widget> Function(BuildContext context)? footer,
      List<Widget> Function(BuildContext context)? children,
    }) => unawaited(
      showDialog<void>(
        context: context,
        // The custom modal ignores taps outside; the back gesture and its buttons still close it.
        barrierDismissible: !modalOnly,
        builder: (context) => _DemoDialog(
          title: title,
          description: description,
          size: size,
          tone: tone,
          footer: footer?.call(context),
          children: children?.call(context) ?? [Text(context.l10n.modalsPageBody)],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            OutlinedButton(
              onPressed: () => open(title: l10n.modalsPageModalTitle),
              child: Text(l10n.modalsPageLaunchDemo),
            ),
            OutlinedButton(
              onPressed: () => open(title: l10n.modalsPageModalTitle, size: _ModalSize.large),
              child: Text(l10n.modalsPageLaunchLarge),
            ),
            OutlinedButton(
              onPressed: () => open(title: l10n.modalsPageModalTitle, size: _ModalSize.small),
              child: Text(l10n.modalsPageLaunchSmall),
            ),
            OutlinedButton(
              onPressed: () => open(
                title: l10n.modalsPageScrollableTitle,
                children: (context) => [
                  for (final paragraph in _guide(context.l10n)) Text(paragraph),
                ],
              ),
              child: Text(l10n.modalsPageLaunchScrollable),
            ),
            OutlinedButton(
              onPressed: () => unawaited(
                showDialog<void>(context: context, builder: (_) => const _FullScreenDialog()),
              ),
              child: Text(l10n.modalsPageLaunchFullscreen),
            ),
          ],
        ),
        const SizedBox(height: Space.card),
        Divider(color: colors.ink200),
        const SizedBox(height: Space.card),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            FilledButton(
              onPressed: () => open(title: l10n.modalsPageModalTitle, tone: _ModalTone.folder),
              child: Text(l10n.modalsPageLaunchPrimary),
            ),
            FilledButton.tonal(
              onPressed: () => open(
                title: l10n.modalsPageSuccessTitle,
                description: l10n.modalsPageSuccessDescription,
                tone: _ModalTone.pass,
                footer: (context) => [
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.modalsPageDone),
                  ),
                ],
              ),
              child: Text(l10n.modalsPageLaunchSuccess),
            ),
            FilledButton.tonal(
              onPressed: () => open(
                title: l10n.modalsPagePendingTitle,
                description: l10n.modalsPagePendingDescription,
                tone: _ModalTone.pencil,
              ),
              child: Text(l10n.modalsPageLaunchPending),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.pen,
                foregroundColor: colors.ply,
              ),
              onPressed: () => unawaited(
                confirm(
                  context,
                  title: l10n.modalsPageDestructiveTitle,
                  text: l10n.modalsPageDestructiveDescription,
                  confirmLabel: l10n.modalsPageDelete,
                  cancelLabel: l10n.modalsPageKeep,
                ),
              ),
              icon: const Icon(LucideIcons.trash2, size: 18),
              label: Text(l10n.modalsPageLaunchDestructive),
            ),
            TextButton(
              onPressed: () => open(title: l10n.modalsPageInfoTitle, tone: _ModalTone.muted),
              child: Text(l10n.modalsPageLaunchInfo),
            ),
            TextButton(
              onPressed: () => open(
                title: l10n.modalsPageCustomTitle,
                description: l10n.modalsPageCustomDescription,
                size: _ModalSize.large,
                tone: _ModalTone.deep,
                modalOnly: true,
                footer: (context) => [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.modalsPageDiscard),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.modalsPageAccept),
                  ),
                ],
              ),
              child: Text(l10n.modalsPageLaunchCustom),
            ),
          ],
        ),
      ],
    );
  }
}

/// The marking guide: long enough to scroll.
List<String> _guide(AppLocalizations l10n) => [
  l10n.modalsPageLongP1,
  l10n.modalsPageLongP2,
  l10n.modalsPageLongP3,
  l10n.modalsPageLongP4,
  l10n.modalsPageLongP5,
  l10n.modalsPageLongP6,
];

/// One example modal on the Marksheet paper: a header band (with an icon for the contextual
/// tones), the body, and a footer whose default buttons are Cancel and Save.
class _DemoDialog extends StatelessWidget {
  const _DemoDialog({
    required this.title,
    required this.size,
    required this.tone,
    required this.children,
    this.description,
    this.footer,
  });

  final String title;
  final String? description;
  final _ModalSize size;
  final _ModalTone tone;
  final List<Widget>? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final (Color? band, Color ink, IconData? icon) = switch (tone) {
      _ModalTone.plain => (null, colors.ink950, null),
      _ModalTone.folder => (colors.folder, colors.folderInk, null),
      _ModalTone.pass => (
        colors.pass.withValues(alpha: 0.08),
        colors.pass,
        LucideIcons.circleCheck,
      ),
      _ModalTone.pencil => (
        colors.pencil.withValues(alpha: 0.08),
        colors.pencil,
        LucideIcons.clock,
      ),
      _ModalTone.muted => (colors.ink100, colors.ink900, LucideIcons.info),
      _ModalTone.deep => (colors.folderDeep, colors.folderInk, null),
    };
    final maxWidth = switch (size) {
      _ModalSize.small => 320.0,
      _ModalSize.normal => 512.0,
      _ModalSize.large => 768.0,
    };
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(Space.lg, Space.card, Space.lg, Space.card),
      child: DefaultTextStyle.merge(
        style: context.text.bodyMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, child) in children.indexed) ...[
              if (index > 0) const SizedBox(height: Space.md),
              child,
            ],
          ],
        ),
      ),
    );

    return Dialog(
      backgroundColor: colors.paperCard,
      clipBehavior: Clip.antiAlias,
      insetPadding: size == _ModalSize.large
          ? const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.lg)
          : const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.lg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: band,
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.xs, Space.page),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: Space.sm + 2),
                      child: Icon(icon, size: 20, color: ink),
                    ),
                    const SizedBox(width: Space.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Space.sm),
                        Semantics(
                          header: true,
                          child: Text(
                            title,
                            style: context.text.titleLarge?.copyWith(color: ink),
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            description!,
                            style: context.text.bodyMedium?.copyWith(
                              color: ink.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.modalsPageClose,
                    color: ink,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 20),
                  ),
                ],
              ),
            ),
            const DoubleRule(),
            Flexible(child: SingleChildScrollView(child: content)),
            Container(
              color: colors.ink100.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.page),
              child: OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: Space.sm,
                overflowSpacing: Space.sm,
                overflowAlignment: OverflowBarAlignment.end,
                children:
                    footer ??
                    [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.modalsPageCancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.modalsPageSave),
                      ),
                    ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The phone's large modal: it takes the whole screen, with Close and Save in its bar.
class _FullScreenDialog extends StatelessWidget {
  const _FullScreenDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog.fullscreen(
      backgroundColor: context.colors.paper,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l10n.modalsPageClose,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x),
          ),
          title: Text(l10n.modalsPageModalTitle),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.modalsPageSave)),
            const SizedBox(width: Space.sm),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Text(l10n.modalsPageBody, style: context.text.bodyLarge),
              const SizedBox(height: Space.lg),
              const DoubleRule(),
              const SizedBox(height: Space.lg),
              for (final paragraph in _guide(l10n)) ...[
                Text(paragraph, style: context.text.bodyMedium),
                const SizedBox(height: Space.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetButtons extends StatelessWidget {
  const _SheetButtons();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        OutlinedButton(
          onPressed: () => unawaited(
            showModalBottomSheet<void>(context: context, builder: (_) => const _ShortSheet()),
          ),
          child: Text(l10n.modalsPageLaunchSheet),
        ),
        OutlinedButton(
          onPressed: () => unawaited(
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const _DraggableSheet(),
            ),
          ),
          child: Text(l10n.modalsPageLaunchDraggableSheet),
        ),
      ],
    );
  }
}

/// A bottom sheet with the demo modal's content: title, text, Cancel and Save.
class _ShortSheet extends StatelessWidget {
  const _ShortSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.modalsPageModalTitle, style: context.text.titleLarge),
            ),
            const SizedBox(height: Space.md),
            Text(l10n.modalsPageBody, style: context.text.bodyMedium),
            const SizedBox(height: Space.lg),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: Space.sm,
              overflowSpacing: Space.sm,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.modalsPageCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.modalsPageSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A sheet that opens half way and drags up to almost the full screen: the marking guide.
class _DraggableSheet extends StatelessWidget {
  const _DraggableSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.xl),
        children: [
          Semantics(
            header: true,
            child: Text(l10n.modalsPageScrollableTitle, style: context.text.titleLarge),
          ),
          const SizedBox(height: Space.md),
          for (final paragraph in _guide(l10n)) ...[
            Text(paragraph, style: context.text.bodyMedium),
            const SizedBox(height: Space.md),
          ],
        ],
      ),
    );
  }
}
