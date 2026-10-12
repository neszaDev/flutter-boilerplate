import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The badge variants, in place of the Bootstrap colours.
enum _Variant { primary, secondary, destructive, outline, ghost, link }

String _variantLabel(AppLocalizations l10n, _Variant variant) => switch (variant) {
  _Variant.primary => l10n.badgesPageVariantDefault,
  _Variant.secondary => l10n.badgesPageVariantSecondary,
  _Variant.destructive => l10n.badgesPageVariantDestructive,
  _Variant.outline => l10n.badgesPageVariantOutline,
  _Variant.ghost => l10n.badgesPageVariantGhost,
  _Variant.link => l10n.badgesPageVariantLink,
};

/// `/dashboard/notifications/badges`: badges beside headings, inside a button, the variants,
/// pills and badges that answer a tap.
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final colors = context.colors;
    // The web page's h2–h6.
    final headings = [
      text.headlineLarge,
      text.headlineSmall?.copyWith(fontSize: 24),
      text.titleLarge?.copyWith(fontSize: 20),
      text.titleLarge,
      text.titleMedium,
    ];
    return AppPage(
      title: l10n.badgesPageTitle,
      description: Text(l10n.badgesPageDescription),
      children: [
        DemoCard(
          title: l10n.badgesPageHeadingsTitle,
          description: l10n.badgesPageHeadingsDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final style in headings)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.md),
                  child: Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(l10n.badgesPageExampleHeading, style: style),
                      _Tag(label: l10n.badgesPageNew),
                    ],
                  ),
                ),
              Divider(color: colors.ink200),
              const SizedBox(height: Space.page),
              Wrap(
                spacing: Space.md,
                runSpacing: Space.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.bell, size: 18),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.badgesPageNotifications),
                        const SizedBox(width: Space.sm),
                        _CountTag(count: l10n.badgesPageNotificationCount('4')),
                      ],
                    ),
                  ),
                  // The phone's own badge, on an icon.
                  IconButton.outlined(
                    tooltip: l10n.badgesPageNotifications,
                    onPressed: () {},
                    icon: Badge.count(count: 4, child: const Icon(LucideIcons.bell)),
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.badgesPageVariantsTitle,
          description: l10n.badgesPageVariantsDescription,
          child: const _VariantRow(),
        ),
        DemoCard(
          title: l10n.badgesPagePillTitle,
          description: l10n.badgesPagePillDescription,
          child: const _VariantRow(pill: true),
        ),
        DemoCard(
          title: l10n.badgesPageLinksTitle,
          description: l10n.badgesPageLinksDescription,
          child: const _VariantRow(actionable: true),
        ),
      ],
    );
  }
}

/// Every variant in a row that wraps.
class _VariantRow extends StatelessWidget {
  const _VariantRow({this.pill = false, this.actionable = false});

  final bool pill;
  final bool actionable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        for (final variant in _Variant.values)
          _Tag(
            label: _variantLabel(l10n, variant),
            variant: variant,
            pill: pill,
            onPressed: actionable
                ? () => showToast(
                    context,
                    l10n.badgesPageLinksTapped(_variantLabel(l10n, variant)),
                  )
                : null,
          ),
      ],
    );
  }
}

/// A badge: tracked small caps on a chip, or an action chip when [onPressed] is set.
class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    this.variant = _Variant.primary,
    this.pill = false,
    this.onPressed,
  });

  final String label;
  final _Variant variant;
  final bool pill;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, ink, border) = switch (variant) {
      _Variant.primary => (colors.primary, colors.onPrimary, null),
      _Variant.secondary => (colors.ink100, colors.ink900, null),
      _Variant.destructive => (colors.pen.withValues(alpha: 0.1), colors.pen, null),
      _Variant.outline => (null, colors.ink700, colors.ink300),
      _Variant.ghost => (null, colors.ink900, null),
      _Variant.link => (null, colors.primary, null),
    };
    final side = border == null ? BorderSide.none : BorderSide(color: border);
    final shape = pill
        ? const StadiumBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm));
    final text = Text(
      label.toUpperCase(),
      style: context.type.formLabel.copyWith(
        color: ink,
        letterSpacing: 1.1,
        decoration: variant == _Variant.link && onPressed != null ? TextDecoration.underline : null,
        decorationColor: ink,
      ),
    );
    const padding = EdgeInsets.symmetric(horizontal: 2);
    const labelPadding = EdgeInsets.symmetric(horizontal: 6);
    if (onPressed != null) {
      return ActionChip(
        label: text,
        onPressed: onPressed,
        backgroundColor: background ?? Colors.transparent,
        side: side,
        shape: shape,
        padding: padding,
        labelPadding: labelPadding,
        visualDensity: VisualDensity.compact,
      );
    }
    return Chip(
      label: text,
      backgroundColor: background ?? Colors.transparent,
      side: side,
      shape: shape,
      padding: padding,
      labelPadding: labelPadding,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// The outlined count inside the notifications button.
class _CountTag extends StatelessWidget {
  const _CountTag({required this.count});

  final String count;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onPrimary;
    return Container(
      height: 20,
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: ink.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Text(
        count,
        style: context.type.formLabel.copyWith(
          color: ink,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
