import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/draggable_layout.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/edge_auto_scroll.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/layout_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

final _docs = Uri.parse('https://api.flutter.dev/flutter/widgets/LongPressDraggable-class.html');

/// `/dashboard/plugins/draggable`: cards to reorder by long-press drag and resize, with the
/// layout saved on the phone.
class DraggableScreen extends StatelessWidget {
  const DraggableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.draggablePageTitle,
      description: Text(l10n.draggablePageDescription),
      children: const [DraggableGrid()],
    );
  }
}

/// The grid with its toolbar: restore, save, the drag and resize switches, and a status line
/// that also says what dragging did.
class DraggableGrid extends ConsumerStatefulWidget {
  const DraggableGrid({super.key});

  @override
  ConsumerState<DraggableGrid> createState() => _DraggableGridState();
}

class _DraggableGridState extends ConsumerState<DraggableGrid> {
  List<GridCard>? _saved;
  List<GridCard>? _edited;
  var _draggable = true;
  var _resizable = true;
  var _status = '';
  final _autoScroll = EdgeAutoScroll();

  List<GridCard> get _layout => _edited ?? _saved ?? baseLayout;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _autoScroll.stop();
    super.dispose();
  }

  Future<void> _load() async {
    final raw = await ref.read(layoutStoreProvider).read();
    if (mounted) {
      setState(() => _saved = parseStoredLayout(raw));
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final layout = _layout;
    final saved = await ref.read(layoutStoreProvider).write(encodeLayout(layout));
    if (!mounted) {
      return;
    }
    if (saved) {
      Haptics.success();
    } else {
      Haptics.error();
    }
    setState(() {
      if (saved) {
        _saved = layout;
      }
      _status = saved ? l10n.draggableGridSaved : l10n.draggableGridSaveFailed;
    });
  }

  String _titleOf(String id) {
    final l10n = context.l10n;
    final pinned = _layout.any((card) => card.id == id && card.pinned);
    return pinned ? l10n.draggableGridPinnedTitle : l10n.draggableGridCardTitle(id);
  }

  void _drop(String activeId, String overId) {
    final l10n = context.l10n;
    final next = moveCard(_layout, activeId, overId);
    if (identical(next, _layout)) {
      setState(() => _status = l10n.draggableGridAnnounceDropNowhere(_titleOf(activeId)));
      return;
    }
    Haptics.light();
    setState(() {
      _status = l10n.draggableGridAnnounceDrop(_titleOf(activeId), _titleOf(overId));
      _edited = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final layout = _layout;
    final movable = [
      for (final card in layout)
        if (!card.pinned) card.id,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _edited = baseLayout;
                _status = l10n.draggableGridRestoredBase;
              }),
              icon: const Icon(LucideIcons.rotateCcw, size: 18),
              label: Text(l10n.draggableGridRestoreBase),
            ),
            if (_saved case final saved?)
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _edited = saved;
                  _status = l10n.draggableGridRestoredSaved;
                }),
                icon: const Icon(LucideIcons.rotateCcw, size: 18),
                label: Text(l10n.draggableGridRestoreSaved),
              ),
            FilledButton.icon(
              onPressed: () => unawaited(_save()),
              icon: const Icon(LucideIcons.save, size: 18),
              label: Text(l10n.draggableGridSave),
            ),
            TextButton.icon(
              onPressed: () => unawaited(launchUrl(_docs, mode: LaunchMode.externalApplication)),
              icon: const Icon(LucideIcons.externalLink, size: 16),
              iconAlignment: IconAlignment.end,
              label: Text(l10n.draggableGridDocumentation),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.draggableGridDragLabel),
          value: _draggable,
          onChanged: (value) => setState(() => _draggable = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.draggableGridResizeLabel),
          value: _resizable,
          onChanged: (value) => setState(() => _resizable = value),
        ),
        const SizedBox(height: Space.sm),
        Semantics(
          container: true,
          liveRegion: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 20),
            child: Text(_status, style: context.text.bodySmall),
          ),
        ),
        const SizedBox(height: Space.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = switch (constraints.maxWidth) {
              >= 760 => 3,
              >= 520 => 2,
              _ => 1,
            };
            const gap = Space.page;
            final unit = (constraints.maxWidth - gap * (columns - 1)) / columns;
            final rows = gridRows(layout, columns);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (rowIndex, row) in rows.indexed) ...[
                  if (rowIndex > 0) const SizedBox(height: gap),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (index, card) in row.indexed) ...[
                        if (index > 0) const SizedBox(width: gap),
                        _tile(
                          card: card,
                          width:
                              unit * cardSpan(card, columns) + gap * (cardSpan(card, columns) - 1),
                          columns: columns,
                          movable: movable,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _tile({
    required GridCard card,
    required double width,
    required int columns,
    required List<String> movable,
  }) {
    final l10n = context.l10n;
    final title = _titleOf(card.id);
    final canDrag = _draggable && !card.pinned;
    final position = movable.indexOf(card.id);
    final earlier = canDrag && position > 0 ? movable[position - 1] : null;
    final later = canDrag && position < movable.length - 1 ? movable[position + 1] : null;
    final tools = _resizable
        ? [
            // One column has no room to widen into.
            if (columns > 1)
              _SizeToggle(
                tooltip: l10n.draggableGridWide(title),
                icon: LucideIcons.moveHorizontal,
                selected: card.wide,
                onPressed: () =>
                    setState(() => _edited = toggleCardSize(_layout, card.id, CardSize.wide)),
              ),
            _SizeToggle(
              tooltip: l10n.draggableGridTall(title),
              icon: LucideIcons.moveVertical,
              selected: card.tall,
              onPressed: () =>
                  setState(() => _edited = toggleCardSize(_layout, card.id, CardSize.tall)),
            ),
          ]
        : const <Widget>[];

    Widget tile = DragTarget<String>(
      onWillAcceptWithDetails: (details) => !card.pinned && details.data != card.id,
      onAcceptWithDetails: (details) => _drop(details.data, card.id),
      builder: (context, candidates, _) => _CardFace(
        card: card,
        title: title,
        showGrip: canDrag,
        highlighted: candidates.isNotEmpty,
        tools: tools,
      ),
    );
    if (canDrag) {
      tile = LongPressDraggable<String>(
        data: card.id,
        // Haptics go through Haptics, which respects the user's setting.
        hapticFeedbackOnStart: false,
        onDragStarted: () {
          Haptics.medium();
          _autoScroll.start(context);
          setState(() => _status = l10n.draggableGridAnnounceStart(title));
        },
        onDragUpdate: (details) => _autoScroll.update(details.globalPosition),
        onDragEnd: (_) => _autoScroll.stop(),
        onDraggableCanceled: (_, _) =>
            setState(() => _status = l10n.draggableGridAnnounceDropNowhere(title)),
        feedback: SizedBox(
          width: width,
          child: Material(
            type: MaterialType.transparency,
            child: _CardFace(card: card, title: title, showGrip: true, lifted: true),
          ),
        ),
        childWhenDragging: _Placeholder(
          child: _CardFace(card: card, title: title),
        ),
        child: tile,
      );
    }
    return SizedBox(
      key: ValueKey('grid-card-${card.id}'),
      width: width,
      child: Semantics(
        container: true,
        customSemanticsActions: {
          if (earlier != null)
            CustomSemanticsAction(label: l10n.draggableGridMoveEarlier(title)): () =>
                _drop(card.id, earlier),
          if (later != null)
            CustomSemanticsAction(label: l10n.draggableGridMoveLater(title)): () =>
                _drop(card.id, later),
        },
        child: tile,
      ),
    );
  }
}

/// The printed face of one card, shared by the grid and the copy under the finger.
class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.card,
    required this.title,
    this.showGrip = false,
    this.highlighted = false,
    this.lifted = false,
    this.tools = const [],
  });

  final GridCard card;
  final String title;
  final bool showGrip;

  /// Another card is held over this one.
  final bool highlighted;

  /// The copy that follows the finger.
  final bool lifted;
  final List<Widget> tools;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final accent = switch (card.accent) {
      // The theme's primary keeps the folder stripe visible on the night card.
      CardAccent.folder => colors.primary,
      CardAccent.ink950 => colors.ink950,
      CardAccent.ink700 => colors.ink700,
      CardAccent.ink600 => colors.ink600,
      CardAccent.ink400 => colors.ink400,
      CardAccent.ink300 => colors.ink300,
    };
    final radius = BorderRadius.circular(Radii.sm);
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: highlighted ? colors.primary : colors.ink200,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.paperCard,
          borderRadius: radius,
          boxShadow: lifted
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: card.tall ? 256 : 176),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: 3, color: accent),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Space.md,
                    tools.isEmpty ? Space.md : 0,
                    tools.isEmpty ? Space.md : 0,
                    tools.isEmpty ? Space.md : 0,
                  ),
                  child: Row(
                    children: [
                      if (showGrip) ...[
                        ExcludeSemantics(
                          child: Icon(LucideIcons.gripVertical, size: 16, color: colors.ink600),
                        ),
                        const SizedBox(width: Space.xs),
                      ],
                      if (card.pinned) ...[
                        ExcludeSemantics(
                          child: Icon(LucideIcons.pin, size: 16, color: colors.ink600),
                        ),
                        const SizedBox(width: Space.xs),
                      ],
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleSmall?.copyWith(color: colors.ink950),
                          ),
                        ),
                      ),
                      ...tools,
                    ],
                  ),
                ),
                Divider(color: colors.ink200),
                Padding(
                  padding: const EdgeInsets.all(Space.page),
                  child: Text(
                    card.pinned ? l10n.draggableGridPinnedText : l10n.draggableGridCardText,
                    style: context.text.bodyMedium?.copyWith(color: colors.ink700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Where the lifted card was: its outline, empty.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.child});

  /// The card face, invisible, so the gap keeps its size.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        Opacity(opacity: 0, child: ExcludeSemantics(child: child)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.ink100.withValues(alpha: 0.5),
              border: Border.all(color: colors.ink400, width: 1.5),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
          ),
        ),
      ],
    );
  }
}

/// A size button that stays pressed while the size is on.
class _SizeToggle extends StatelessWidget {
  const _SizeToggle({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      tooltip: tooltip,
      isSelected: selected,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colors.ink100 : null,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colors.ink950 : colors.ink600,
        ),
      ),
    );
  }
}
