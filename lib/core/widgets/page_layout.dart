import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/offline_banner.dart';
import 'package:go_router/go_router.dart';

/// The screens a tab opens on: they never need a way back.
const _tabRoots = {Routes.dashboard, Routes.testResults, Routes.files, Routes.device, Routes.menu};

/// The scaffold of a page whose scroll view starts with a [PageHeader]:
///
/// - the app bar shows the title only once the header has scrolled away (the large title
///   collapses into the bar), so the title isn't printed twice;
/// - a page opened directly (deep link, notification) gets a back button to its section.
///
/// [body] must contain the page's vertical scroll view.
class AppScaffold extends StatefulWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.alwaysShowTitle = false,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  /// For pages without a [PageHeader].
  final bool alwaysShowTitle;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _scrolled = false;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0 && notification.metrics.axis == Axis.vertical) {
      final scrolled = notification.metrics.pixels > 56;
      if (scrolled != _scrolled) {
        setState(() => _scrolled = scrolled);
      }
    }
    return false;
  }

  /// Back to the page's section when there is nothing to pop (the page was opened directly).
  Widget? _fallbackBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      return null;
    }
    final router = GoRouter.maybeOf(context);
    final path = router?.state.uri.path;
    if (router == null || path == null || !Routes.isApp(path) || _tabRoots.contains(path)) {
      return null;
    }
    final section = path.startsWith('${Routes.device}/') ? Routes.device : Routes.menu;
    return BackButton(onPressed: () => router.go(section));
  }

  @override
  Widget build(BuildContext context) {
    final showTitle = widget.alwaysShowTitle || _scrolled;
    return Scaffold(
      appBar: AppBar(
        leading: _fallbackBack(context),
        title: AnimatedOpacity(
          opacity: showTitle ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: Text(widget.title),
        ),
        actions: widget.actions,
      ),
      floatingActionButton: widget.floatingActionButton,
      body: NotificationListener<ScrollNotification>(onNotification: _onScroll, child: widget.body),
    );
  }
}

/// The ruled double line under a page or card header (the web app's `border-b-[3px]
/// border-double`).
class DoubleRule extends StatelessWidget {
  const DoubleRule({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colors.ink300;
    return ExcludeSemantics(
      child: Column(
        children: [
          Container(height: 1, color: color),
          const SizedBox(height: 1.5),
          Container(height: 1, color: color),
        ],
      ),
    );
  }
}

/// The heading band of a page: title, a line of context and optional actions.
class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, this.description, this.actions, super.key});

  final String title;

  /// One line (or a few widgets) under the title.
  final Widget? description;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(header: true, child: Text(title, style: context.text.headlineMedium)),
      if (description != null) ...[
        const SizedBox(height: Space.sm),
        DefaultTextStyle.merge(
          style: context.text.bodyMedium?.copyWith(color: context.colors.ink600),
          child: description!,
        ),
      ],
      if (actions != null) ...[
        const SizedBox(height: Space.md),
        Wrap(spacing: Space.sm, runSpacing: Space.sm, children: actions!),
      ],
      const SizedBox(height: Space.lg),
      const DoubleRule(),
    ],
  );
}

/// A scrollable screen: app bar, optional [PageHeader], then [children] spaced like the web
/// app's `flex flex-col gap-8`, with pull-to-refresh when [onRefresh] is set.
///
/// Use it for every screen whose content is a column of sections. Lists that page in data use
/// [CustomScrollView]s of their own and [PageHeader] directly.
class AppPage extends StatelessWidget {
  const AppPage({
    required this.children,
    this.title,
    this.description,
    this.headerActions,
    this.appBarTitle,
    this.actions,
    this.onRefresh,
    this.floatingActionButton,
    this.showHeader = true,
    this.gap = Space.lg,
    super.key,
  });

  /// The page title (header). Also the app bar title unless [appBarTitle] is set.
  final String? title;
  final Widget? description;
  final List<Widget>? headerActions;
  final String? appBarTitle;

  /// App bar actions.
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;
  final Widget? floatingActionButton;

  /// False keeps the title in the app bar only.
  final bool showHeader;
  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.section),
      children: [
        if (showHeader && title != null) ...[
          PageHeader(title: title!, description: description, actions: headerActions),
          SizedBox(height: gap),
        ],
        for (final (index, child) in children.indexed) ...[
          if (index > 0) SizedBox(height: gap),
          child,
        ],
      ],
    );
    return AppScaffold(
      title: appBarTitle ?? title ?? '',
      // The header prints the title; a different app-bar title (or no header) stays visible.
      alwaysShowTitle:
          !showHeader || title == null || (appBarTitle != null && appBarTitle != title),
      actions: actions,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  // Tablets and landscape: keep lines readable, like the web's max-w-6xl.
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: onRefresh == null
                      ? list
                      : RefreshIndicator(onRefresh: onRefresh!, child: list),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A card of the report: title, optional action, the double rule, then the content.
class SheetCard extends StatelessWidget {
  const SheetCard({
    required this.child,
    this.title,
    this.action,
    this.padding = const EdgeInsets.all(Space.card),
    super.key,
  });

  final String? title;
  final Widget? action;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.card, Space.card, Space.md, Space.md),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title!, style: context.text.titleLarge),
                  ),
                ),
                ?action,
              ],
            ),
          ),
          const DoubleRule(),
        ],
        Padding(padding: padding, child: child),
      ],
    ),
  );
}

/// One example block of a showcase screen: a titled card with the example inside (the web
/// app's `DemoCard`).
class DemoCard extends StatelessWidget {
  const DemoCard({
    required this.title,
    required this.child,
    this.description,
    this.action,
    this.padding = const EdgeInsets.all(Space.card),
    super.key,
  });

  final String title;
  final String? description;
  final Widget? action;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
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
                      Semantics(
                        header: true,
                        child: Text(title, style: context.text.titleLarge),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: Space.xs),
                        Text(description!, style: context.text.bodySmall),
                      ],
                    ],
                  ),
                ),
              ),
              ?action,
            ],
          ),
        ),
        Divider(color: context.colors.ink200),
        Padding(padding: padding, child: child),
      ],
    ),
  );
}

/// A section heading inside a page.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
  );
}

/// A tracked small-caps label (`form-label` on the web).
class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: context.type.formLabel.copyWith(color: color));
}
