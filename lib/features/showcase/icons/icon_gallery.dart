import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/offline_banner.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/icons/gallery.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// A whole screen around a searchable icon grid (the web's `IconGallery` in a `DemoCard`): the
/// page header, then one card with the search box, the match count and the icons. The grid is
/// built lazily, so thousands of icons cost only the rows on screen.
class IconGalleryScreen extends StatefulWidget {
  const IconGalleryScreen({
    required this.title,
    required this.description,
    required this.galleryTitle,
    required this.galleryDescription,
    required this.names,
    required this.iconBuilder,
    required this.copyText,
    this.galleryAction,
    this.header,
    this.iconSize = 24,
    super.key,
  });

  final String title;
  final String description;
  final String galleryTitle;
  final String galleryDescription;

  /// Next to the card title (e.g. a link to the icon set's website).
  final Widget? galleryAction;

  /// Above the search box (e.g. a choice of icon set).
  final Widget? header;

  /// Every icon's name, in display order.
  final List<String> names;
  final Widget Function(BuildContext context, String name) iconBuilder;

  /// What tapping the icon called `name` copies.
  final String Function(String name) copyText;

  /// Height of the icons, for the height of the tiles.
  final double iconSize;

  @override
  State<IconGalleryScreen> createState() => _IconGalleryScreenState();
}

class _IconGalleryScreenState extends State<IconGalleryScreen> {
  final _search = TextEditingController();
  var _query = '';

  @override
  void initState() {
    super.initState();
    // Also rebuilds when only spaces are typed, for the clear button.
    _search.addListener(() => setState(() => _query = _search.text.trim()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final results = searchNames(widget.names, _query);
    // Padding, the icon, the gap and two lines of name.
    final tileHeight =
        Space.page * 2 +
        widget.iconSize +
        Space.md +
        MediaQuery.textScalerOf(context).scale(12) * 1.45 * 2;

    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.header != null) ...[widget.header!, const SizedBox(height: Space.page)],
        LabeledField(
          label: l10n.iconGallerySearchLabel,
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: l10n.iconGallerySearchPlaceholder,
              prefixIcon: Icon(LucideIcons.search, size: 18, color: colors.ink600),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.iconGalleryClear,
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: _search.clear,
                    ),
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        Semantics(
          liveRegion: true,
          child: Text(
            _query.isEmpty
                ? l10n.iconGalleryCount(results.length)
                : l10n.iconGalleryMatches(results.length, _query),
            style: context.type.table.copyWith(color: colors.ink600),
          ),
        ),
      ],
    );

    final gallery = DecoratedSliver(
      decoration: ShapeDecoration(
        color: colors.paperCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          side: BorderSide(color: colors.ink300),
        ),
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: _CardHeader(
              title: widget.galleryTitle,
              description: widget.galleryDescription,
              action: widget.galleryAction,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Space.card),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(child: controls),
                const SliverToBoxAdapter(child: SizedBox(height: Space.card)),
                if (results.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Space.xl),
                      child: Text(
                        l10n.iconGalleryEmpty(_query),
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium?.copyWith(color: colors.ink600),
                      ),
                    ),
                  )
                else
                  SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 128,
                      mainAxisExtent: tileHeight,
                      mainAxisSpacing: Space.xs,
                      crossAxisSpacing: Space.xs,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final name = results[index];
                      final copyText = widget.copyText(name);
                      return CopyNameTile(
                        key: ValueKey(copyText),
                        name: name,
                        copyText: copyText,
                        icon: widget.iconBuilder(context, name),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: CustomScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          Space.page,
                          Space.sm,
                          Space.page,
                          Space.section,
                        ),
                        sliver: SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child: PageHeader(
                                title: widget.title,
                                description: Text(widget.description),
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: Space.lg)),
                            gallery,
                          ],
                        ),
                      ),
                    ],
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

/// The title band of the gallery card, laid out like `DemoCard`'s.
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.description, this.action});

  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(Space.card, Space.card - 4, Space.sm, Space.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(header: true, child: Text(title, style: context.text.titleLarge)),
                    const SizedBox(height: Space.xs),
                    Text(description, style: context.text.bodySmall),
                  ],
                ),
              ),
            ),
            ?action,
          ],
        ),
      ),
      Divider(color: context.colors.ink200),
    ],
  );
}

/// Opens [url] in the browser, for a gallery card's action: an icon button that [label]
/// names, so a long label never crowds the card title on a phone.
class WebsiteLink extends StatelessWidget {
  const WebsiteLink({required this.label, required this.url, super.key});

  final String label;
  final Uri url;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () => unawaited(launchUrl(url, mode: LaunchMode.externalApplication)),
    tooltip: label,
    color: context.colors.primary,
    icon: const Icon(LucideIcons.externalLink, size: 20),
  );
}

enum _CopyStatus { idle, copied, failed }

/// One gallery tile (the web's `CopyNameTile`): the icon over its name; tapping it copies
/// [copyText] and says so for a moment.
class CopyNameTile extends StatefulWidget {
  const CopyNameTile({
    required this.name,
    required this.copyText,
    required this.icon,
    super.key,
  });

  /// Shown under the icon.
  final String name;
  final String copyText;
  final Widget icon;

  /// How long "Copied" stays up.
  static const resetAfter = Duration(milliseconds: 1500);

  @override
  State<CopyNameTile> createState() => _CopyNameTileState();
}

class _CopyNameTileState extends State<CopyNameTile> {
  var _status = _CopyStatus.idle;
  Timer? _reset;

  Future<void> _copy() async {
    _CopyStatus next;
    // The platform can refuse the clipboard.
    try {
      await Clipboard.setData(ClipboardData(text: widget.copyText));
      next = _CopyStatus.copied;
      Haptics.success();
    } on PlatformException {
      next = _CopyStatus.failed;
      Haptics.error();
    }
    if (!mounted) {
      return;
    }
    _reset?.cancel();
    setState(() => _status = next);
    _reset = Timer(CopyNameTile.resetAfter, () {
      if (mounted) {
        setState(() => _status = _CopyStatus.idle);
      }
    });
  }

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final badge = context.text.labelSmall?.copyWith(letterSpacing: 0, color: colors.primary);
    return Stack(
      children: [
        Positioned.fill(
          child: Semantics(
            button: true,
            label: l10n.iconGalleryCopyName(widget.copyText),
            excludeSemantics: true,
            // Ink of its own: the card's fill would hide the screen's.
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => unawaited(_copy()),
                borderRadius: BorderRadius.circular(Radii.md),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.page),
                  child: Column(
                    children: [
                      widget.icon,
                      const SizedBox(height: Space.md),
                      Text(
                        widget.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          fontSize: 12,
                          color: colors.ink700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: 6,
          end: 6,
          child: IgnorePointer(
            child: Semantics(
              liveRegion: true,
              child: switch (_status) {
                _CopyStatus.idle => const SizedBox.shrink(),
                _CopyStatus.copied => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.check, size: 12, color: colors.primary),
                    const SizedBox(width: 2),
                    Text(l10n.iconGalleryCopied, style: badge),
                  ],
                ),
                _CopyStatus.failed => Text(
                  l10n.iconGalleryCopyFailed,
                  style: badge?.copyWith(color: colors.pen),
                ),
              },
            ),
          ),
        ),
      ],
    );
  }
}
