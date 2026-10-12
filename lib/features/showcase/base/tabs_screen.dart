import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A tab and the text of its panel.
typedef _TabSpec = ({String label, String panel, IconData? icon, bool disabled});

List<_TabSpec> _textTabs(AppLocalizations l10n) => [
  (label: l10n.tabsPageTabHome, panel: l10n.tabsPagePanelHome, icon: null, disabled: false),
  (label: l10n.tabsPageTabProfile, panel: l10n.tabsPagePanelProfile, icon: null, disabled: false),
  (label: l10n.tabsPageTabDisabled, panel: l10n.tabsPagePanelDisabled, icon: null, disabled: true),
];

List<_TabSpec> _iconTabs(AppLocalizations l10n) => [
  (
    label: l10n.tabsPageTabCalculator,
    panel: l10n.tabsPagePanelCalculator,
    icon: LucideIcons.calculator,
    disabled: false,
  ),
  (
    label: l10n.tabsPageTabCart,
    panel: l10n.tabsPagePanelCart,
    icon: LucideIcons.shoppingCart,
    disabled: false,
  ),
  (
    label: l10n.tabsPageTabCharts,
    panel: l10n.tabsPagePanelCharts,
    icon: LucideIcons.chartPie,
    disabled: false,
  ),
];

/// `/dashboard/base/tabs`: panels switched in place, as underlined tabs, pills, icons and a
/// vertical list.
class TabsScreen extends StatelessWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.tabsPageTitle,
      description: Text(l10n.tabsPageDescription),
      children: [
        DemoCard(
          title: l10n.tabsPageTabsTitle,
          description: l10n.tabsPageTabsDescription,
          child: _DemoTabs(
            label: l10n.tabsPageTextLabel,
            tabs: _textTabs(l10n),
            style: _TabStyle.line,
          ),
        ),
        DemoCard(
          title: l10n.tabsPagePillsTitle,
          description: l10n.tabsPagePillsDescription,
          child: _DemoTabs(
            label: l10n.tabsPageTextLabel,
            tabs: _textTabs(l10n),
            style: _TabStyle.pills,
          ),
        ),
        DemoCard(
          title: l10n.tabsPageIconsTitle,
          child: _DemoTabs(
            label: l10n.tabsPageIconsLabel,
            tabs: _iconTabs(l10n),
            style: _TabStyle.line,
            content: _TabContent.icon,
            initialIndex: 1,
          ),
        ),
        DemoCard(
          title: l10n.tabsPageIconsTextTitle,
          child: _DemoTabs(
            label: l10n.tabsPageIconsLabel,
            tabs: _iconTabs(l10n),
            style: _TabStyle.line,
            content: _TabContent.iconAndText,
            initialIndex: 1,
          ),
        ),
        DemoCard(
          title: l10n.tabsPageVerticalTitle,
          description: l10n.tabsPageVerticalDescription,
          child: _VerticalTabs(label: l10n.tabsPageIconsLabel, tabs: _iconTabs(l10n)),
        ),
      ],
    );
  }
}

enum _TabStyle { line, pills }

enum _TabContent { text, icon, iconAndText }

/// A [TabController] that refuses to move to a disabled tab (Material tabs have no disabled
/// state of their own).
class _GuardedTabController extends TabController {
  _GuardedTabController({
    required super.length,
    required super.vsync,
    required this.disabled,
    super.initialIndex,
  });

  final Set<int> disabled;

  @override
  void animateTo(int value, {Duration? duration, Curve curve = Curves.ease}) {
    if (!disabled.contains(value)) {
      super.animateTo(value, duration: duration, curve: curve);
    }
  }

  @override
  set index(int value) {
    if (!disabled.contains(value)) {
      super.index = value;
    }
  }
}

/// A Material [TabBar] above the text of the selected tab's panel.
class _DemoTabs extends StatefulWidget {
  const _DemoTabs({
    required this.label,
    required this.tabs,
    required this.style,
    this.content = _TabContent.text,
    this.initialIndex = 0,
  });

  /// Accessible name of the tab list.
  final String label;
  final List<_TabSpec> tabs;
  final _TabStyle style;
  final _TabContent content;
  final int initialIndex;

  @override
  State<_DemoTabs> createState() => _DemoTabsState();
}

class _DemoTabsState extends State<_DemoTabs> with SingleTickerProviderStateMixin {
  late final _controller = _GuardedTabController(
    length: widget.tabs.length,
    vsync: this,
    initialIndex: widget.initialIndex,
    disabled: {
      for (final (index, tab) in widget.tabs.indexed)
        if (tab.disabled) index,
    },
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _tab(_TabSpec tab) {
    final pills = widget.style == _TabStyle.pills;
    final height = pills ? 40.0 : null;
    Widget tabWidget = switch (widget.content) {
      _TabContent.text => Tab(height: height, text: tab.label),
      // Icon only: the name is the tooltip (long-press) and what screen readers read.
      _TabContent.icon => Tab(
        height: height,
        icon: Tooltip(message: tab.label, child: Icon(tab.icon, size: 18)),
      ),
      _TabContent.iconAndText => Tab(
        height: height ?? 46,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Icon(tab.icon, size: 16)),
            const SizedBox(width: 6),
            Text(tab.label),
          ],
        ),
      ),
    };
    if (tab.disabled) {
      tabWidget = Semantics(
        enabled: false,
        child: Opacity(opacity: 0.5, child: tabWidget),
      );
    }
    return tabWidget;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pills = widget.style == _TabStyle.pills;
    final tabBar = TabBar(
      controller: _controller,
      // Underlined tabs fit their labels and scroll when they run out of room; pills share the
      // width like a segmented control.
      isScrollable: !pills,
      tabAlignment: pills ? TabAlignment.fill : TabAlignment.start,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: Space.md),
      dividerHeight: 0,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: colors.ink950,
      indicator: pills
          ? BoxDecoration(
              color: colors.ply,
              borderRadius: BorderRadius.circular(Radii.sm),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            )
          : null,
      splashBorderRadius: pills ? BorderRadius.circular(Radii.sm) : null,
      tabs: [for (final tab in widget.tabs) _tab(tab)],
    );
    final bar = Semantics(container: true, label: widget.label, child: tabBar);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pills)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.ink100,
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Padding(padding: const EdgeInsets.all(3), child: bar),
          )
        else
          bar,
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _Panel(text: widget.tabs[_controller.index].panel),
        ),
      ],
    );
  }
}

/// The text of the selected tab.
class _Panel extends StatelessWidget {
  const _Panel({required this.text, this.top = Space.md});

  final String text;
  final double top;

  @override
  Widget build(BuildContext context) => Semantics(
    role: SemanticsRole.tabPanel,
    container: true,
    child: Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(
        text,
        style: context.text.bodyMedium?.copyWith(height: 1.625, color: context.colors.ink700),
      ),
    ),
  );
}

/// Pills stacked in a column beside their panel, or above it on phones.
class _VerticalTabs extends StatefulWidget {
  const _VerticalTabs({required this.label, required this.tabs});

  /// Accessible name of the tab list.
  final String label;
  final List<_TabSpec> tabs;

  @override
  State<_VerticalTabs> createState() => _VerticalTabsState();
}

class _VerticalTabsState extends State<_VerticalTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final beside = MediaQuery.sizeOf(context).width >= 640;
    final list = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.ink100,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Semantics(
          role: SemanticsRole.tabBar,
          container: true,
          explicitChildNodes: true,
          label: widget.label,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, tab) in widget.tabs.indexed)
                _VerticalTab(
                  tab: tab,
                  selected: index == _index,
                  onTap: () => setState(() => _index = index),
                ),
            ],
          ),
        ),
      ),
    );
    final panel = _Panel(text: widget.tabs[_index].panel, top: 0);
    return beside
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicWidth(child: list),
              const SizedBox(width: Space.page),
              Expanded(child: panel),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              list,
              const SizedBox(height: Space.page),
              panel,
            ],
          );
  }
}

class _VerticalTab extends StatelessWidget {
  const _VerticalTab({required this.tab, required this.selected, required this.onTap});

  final _TabSpec tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.ink950 : colors.ink600;
    return Semantics(
      role: SemanticsRole.tab,
      container: true,
      selected: selected,
      child: Material(
        color: selected ? colors.ply : Colors.transparent,
        elevation: selected ? 1 : 0,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(Radii.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.md),
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  ExcludeSemantics(child: Icon(tab.icon, size: 16, color: color)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      tab.label,
                      style: context.text.titleSmall?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
