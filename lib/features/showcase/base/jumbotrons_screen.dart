import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_links.dart';

/// `/dashboard/base/jumbotrons`: hero bands for the one message a page has to get across.
class JumbotronsScreen extends StatelessWidget {
  const JumbotronsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final lead = context.text.bodyLarge?.copyWith(fontSize: 18, height: 1.6);

    return AppPage(
      title: l10n.jumbotronsPageTitle,
      description: Text(l10n.jumbotronsPageDescription),
      children: [
        DemoCard(
          title: l10n.jumbotronsPageBasicTitle,
          child: _Jumbotron(
            children: [
              _Display(l10n.jumbotronsPageDisplay, color: colors.ink950),
              Text(l10n.jumbotronsPageBasicLead, style: lead),
              Text(l10n.jumbotronsPageBasicText, style: TextStyle(color: colors.ink700)),
              FilledButton(
                onPressed: () => openAppPath(context, Routes.about),
                child: Text(l10n.jumbotronsPageMoreInfo),
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.jumbotronsPageSlotsTitle,
          description: l10n.jumbotronsPageSlotsDescription,
          child: _Jumbotron(
            children: [
              _Display(l10n.jumbotronsPageDisplay, color: colors.ink950),
              Text(l10n.jumbotronsPageHeroLead, style: lead),
              Divider(color: colors.ink300),
              Text(l10n.jumbotronsPageHeroText, style: TextStyle(color: colors.ink700)),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  FilledButton(
                    onPressed: () => openAppPath(context, Routes.testResults),
                    child: Text(l10n.jumbotronsPageDoSomething),
                  ),
                  OutlinedButton(
                    onPressed: () => openAppPath(context, Routes.account),
                    child: Text(l10n.jumbotronsPageDoSomethingElse),
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.jumbotronsPageColorsTitle,
          description: l10n.jumbotronsPageColorsDescription,
          child: _Jumbotron(
            background: colors.folder,
            border: colors.folderDeep,
            foreground: colors.folderInk,
            children: [
              _Display(l10n.jumbotronsPageDisplay, color: colors.folderInk),
              Text(l10n.jumbotronsPageHeroLead, style: lead?.copyWith(color: colors.folderInk)),
              Divider(color: colors.folderInkSoft.withValues(alpha: 0.4)),
              Text(l10n.jumbotronsPageHeroText, style: TextStyle(color: colors.folderInkSoft)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A hero band that calls attention to one message.
class _Jumbotron extends StatelessWidget {
  const _Jumbotron({required this.children, this.background, this.border, this.foreground});

  final List<Widget> children;
  final Color? background;
  final Color? border;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 40),
      decoration: BoxDecoration(
        color: background ?? colors.ink100,
        border: border == null ? null : Border.all(color: border!),
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: DefaultTextStyle.merge(
        style: context.text.bodyMedium?.copyWith(color: foreground ?? colors.ink900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, child) in children.indexed) ...[
              if (index > 0) const SizedBox(height: Space.page),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

/// The band's display heading.
class _Display extends StatelessWidget {
  const _Display(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: context.text.displayMedium?.copyWith(
        fontSize: 40,
        height: 1.02,
        letterSpacing: -1.4,
        color: color,
      ),
    ),
  );
}
