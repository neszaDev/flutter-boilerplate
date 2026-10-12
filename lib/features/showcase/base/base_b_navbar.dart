import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/router/sign_out.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Folder-green bar, or a light bar on card stock.
enum NavbarTone { folder, paper }

/// The screen width from which a navbar's content sits inline instead of folding behind its
/// menu button (the web's `sm` and `md` breakpoints).
enum NavbarExpand {
  sm(640),
  md(768);

  const NavbarExpand(this.minWidth);

  final double minWidth;
}

/// Opens a screen the way the menu does: the tabs switch, other screens go on top.
void _open(BuildContext context, String path) {
  if (path == Routes.dashboard || path == Routes.testResults) {
    context.go(path);
  } else {
    unawaited(context.push<void>(path));
  }
}

/// The colours of a bar's tone, read by its items.
class _NavbarScope extends InheritedWidget {
  const _NavbarScope({required this.tone, required this.folded, required super.child});

  final NavbarTone tone;

  /// Items are stacked in the open menu panel rather than in a row.
  final bool folded;

  static _NavbarScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_NavbarScope>();
    assert(scope != null, 'Navbar items go inside a Navbar.');
    return scope ?? const _NavbarScope(tone: NavbarTone.paper, folded: false, child: SizedBox());
  }

  @override
  bool updateShouldNotify(_NavbarScope oldWidget) =>
      oldWidget.tone != tone || oldWidget.folded != folded;
}

extension on NavbarTone {
  /// Text and icons on the bar.
  Color foreground(MarksheetColors colors) =>
      this == NavbarTone.folder ? colors.folderInk : colors.ink900;

  /// Links and quiet text.
  Color soft(MarksheetColors colors) =>
      this == NavbarTone.folder ? colors.folderInkSoft : colors.ink700;

  /// The pressed and hovered wash of links and menus.
  Color wash(MarksheetColors colors) =>
      this == NavbarTone.folder ? colors.folderInk.withValues(alpha: 0.1) : colors.ink200;
}

/// A horizontal app bar: a brand, then its content (the web's `Navbar`). With [expand], the
/// content folds behind a menu button on screens narrower than that breakpoint (every phone)
/// and sits inline on wider ones.
class Navbar extends StatefulWidget {
  const Navbar({
    required this.tone,
    required this.label,
    this.brand,
    this.expand,
    this.children = const [],
    super.key,
  });

  final NavbarTone tone;

  /// Accessible name of the bar.
  final String label;
  final Widget? brand;
  final NavbarExpand? expand;

  /// Groups, text and forms.
  final List<Widget> children;

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tone = widget.tone;
    final expand = widget.expand;
    final brand = widget.brand;
    final folded = expand != null && MediaQuery.sizeOf(context).width < expand.minWidth;
    final hasContent = widget.children.isNotEmpty;

    final Widget content;
    if (folded) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Semantics(
                expanded: _open,
                child: IconButton(
                  tooltip: context.l10n.navbarsPageToggle,
                  color: tone.foreground(colors),
                  icon: const Icon(LucideIcons.menu, size: 20),
                  onPressed: () => setState(() => _open = !_open),
                ),
              ),
              if (brand != null) ...[const SizedBox(width: Space.sm), brand],
            ],
          ),
          AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _open && hasContent
                ? Padding(
                    padding: const EdgeInsets.only(top: Space.sm, bottom: Space.xs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (index, child) in widget.children.indexed) ...[
                          if (index > 0) const SizedBox(height: Space.sm),
                          child,
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      );
    } else {
      // Inline: the brand, then the content wrapping onto more lines when it runs out of room;
      // with two groups, the second sits at the far end.
      content = Row(
        children: [
          ?brand,
          if (brand != null && hasContent) const SizedBox(width: Space.page),
          if (hasContent)
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Space.page,
                runSpacing: Space.sm,
                children: widget.children,
              ),
            ),
        ],
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: Material(
        color: tone == NavbarTone.folder ? colors.folder : colors.ink100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: tone == NavbarTone.paper ? BorderSide(color: colors.ink200) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: tone.foreground(colors)),
            child: IconTheme.merge(
              data: IconThemeData(color: tone.foreground(colors)),
              child: _NavbarScope(tone: tone, folded: folded, child: content),
            ),
          ),
        ),
      ),
    );
  }
}

/// The brand of a navbar: the product name, with an optional mark, leading home when [home].
class NavbarBrand extends StatelessWidget {
  const NavbarBrand({required this.name, this.home = false, this.mark = false, super.key});

  final String name;
  final bool home;

  /// Shows the Marksheet tick before the name.
  final bool mark;

  @override
  Widget build(BuildContext context) {
    final text = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mark) ...[const Mark(status: TestStatus.passed, size: 24), const SizedBox(width: 6)],
        Text(
          name,
          maxLines: 1,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.18),
        ),
      ],
    );
    if (!home) {
      return text;
    }
    return Semantics(
      link: true,
      child: InkWell(
        onTap: () => _open(context, Routes.dashboard),
        borderRadius: BorderRadius.circular(Radii.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.xs),
            child: Align(widthFactor: 1, child: text),
          ),
        ),
      ),
    );
  }
}

/// A group of navbar items, stacked when folded and in a row when shown inline.
class NavbarGroup extends StatelessWidget {
  const NavbarGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => _NavbarScope.of(context).folded
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, child) in children.indexed) ...[
              if (index > 0) const SizedBox(height: Space.xs),
              child,
            ],
          ],
        )
      : Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Space.xs,
          runSpacing: Space.xs,
          children: children,
        );
}

/// The look of a link or menu button on the bar.
ButtonStyle _itemStyle(BuildContext context) {
  final colors = context.colors;
  final scope = _NavbarScope.of(context);
  return TextButton.styleFrom(
    foregroundColor: scope.tone.soft(colors),
    disabledForegroundColor: scope.tone.soft(colors).withValues(alpha: 0.5),
    overlayColor: scope.tone.wash(colors),
    alignment: scope.folded ? Alignment.centerLeft : Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: Space.md),
    textStyle: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w500),
  );
}

/// A link in a navbar; a disabled one is greyed out and cannot be followed.
class NavbarLink extends StatelessWidget {
  const NavbarLink({required this.label, required this.path, this.disabled = false, super.key});

  final String label;
  final String path;
  final bool disabled;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    child: TextButton(
      style: _itemStyle(context),
      onPressed: disabled ? null : () => _open(context, path),
      child: Text(label),
    ),
  );
}

/// Plain text in a navbar.
class NavbarText extends StatelessWidget {
  const NavbarText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.text.bodySmall?.copyWith(
      fontSize: 14,
      color: _NavbarScope.of(context).tone == NavbarTone.folder
          ? context.colors.folderInkSoft
          : context.colors.ink600,
    ),
  );
}

/// An entry of a [NavbarMenu]: a screen to open, or the real sign-out.
typedef NavbarMenuItem = ({String label, String? path, bool signOut});

/// A dropdown menu in a navbar. Entries are links, the real sign-out, or (with [choices]) a
/// single choice such as the language; the first choice starts chosen.
class NavbarMenu extends ConsumerStatefulWidget {
  const NavbarMenu({required this.label, this.items = const [], this.choices, super.key});

  final String label;
  final List<NavbarMenuItem> items;
  final List<String>? choices;

  @override
  ConsumerState<NavbarMenu> createState() => _NavbarMenuState();
}

class _NavbarMenuState extends ConsumerState<NavbarMenu> {
  late String? _choice = widget.choices?.first;

  void _select(NavbarMenuItem item) {
    if (item.signOut) {
      unawaited(signOutToWelcome(ref));
    } else if (item.path case final path?) {
      _open(context, path);
    }
  }

  @override
  Widget build(BuildContext context) => MenuAnchor(
    alignmentOffset: const Offset(0, Space.xs),
    menuChildren: [
      for (final option in widget.choices ?? const <String>[])
        RadioMenuButton<String>(
          value: option,
          groupValue: _choice,
          onChanged: (value) => setState(() => _choice = value),
          child: Text(option),
        ),
      for (final item in widget.items)
        MenuItemButton(onPressed: () => _select(item), child: Text(item.label)),
    ],
    builder: (context, controller, child) => Semantics(
      expanded: controller.isOpen,
      child: TextButton(
        style: _itemStyle(context),
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label),
            const SizedBox(width: Space.xs),
            const Icon(LucideIcons.chevronDown, size: 16),
          ],
        ),
      ),
    ),
  );
}

/// A search form for a navbar. The demo has nothing to search, so a submitted query is answered
/// with a toast.
class NavbarSearch extends StatefulWidget {
  const NavbarSearch({required this.placeholder, this.button, super.key});

  /// Field hint and accessible name.
  final String placeholder;

  /// Button text (no button when null).
  final String? button;

  @override
  State<NavbarSearch> createState() => _NavbarSearchState();
}

class _NavbarSearchState extends State<NavbarSearch> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final text = _query.text.trim();
    showToast(
      context,
      text.isEmpty ? l10n.navbarsPageSearchEmpty : l10n.navbarsPageSearchResult(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final folder = _NavbarScope.of(context).tone == NavbarTone.folder;
    final button = widget.button;
    // Phones: the field takes the rest of the line. Wider screens: a fixed width beside the
    // other items (the web's `sm:w-48`).
    final wide = MediaQuery.sizeOf(context).width >= NavbarExpand.sm.minWidth;
    final field = TextField(
      controller: _query,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submit(),
      style: context.text.bodyMedium,
      decoration: InputDecoration(hintText: widget.placeholder),
    );
    return Row(
      mainAxisSize: wide ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (wide) SizedBox(width: 192, child: field) else Expanded(child: field),
        if (button != null) ...[
          const SizedBox(width: Space.sm),
          if (folder)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.folderInk,
                foregroundColor: colors.folder,
              ),
              onPressed: _submit,
              icon: const Icon(LucideIcons.search, size: 16),
              label: Text(button),
            )
          else
            OutlinedButton.icon(
              onPressed: _submit,
              icon: const Icon(LucideIcons.search, size: 16),
              label: Text(button),
            ),
        ],
      ],
    );
  }
}
