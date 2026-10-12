import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_actions_card.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_badge.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_data.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_colors.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_switch.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// `/dashboard/base/cards`: card parts, outline, accent, quoted and filled cards in the
/// Marksheet tones, and a card with header actions.
class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final body = l10n.cardsPageBody;

    return AppPage(
      title: l10n.cardsPageTitle,
      description: Text(l10n.cardsPageDescription),
      gap: Space.xl,
      children: [
        _Section(
          title: l10n.cardsPagePartsTitle,
          children: [
            _HeaderCard(title: Text(l10n.cardsPageCardTitle), child: Text(body)),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Space.card),
                    child: Text(
                      body,
                      style: context.text.bodyMedium?.copyWith(color: colors.ink700),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.paper,
                      border: Border(top: BorderSide(color: colors.ink200)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.card,
                      vertical: Space.md,
                    ),
                    child: Text(
                      l10n.cardsPageCardFooter,
                      style: context.text.bodyMedium?.copyWith(color: colors.ink600),
                    ),
                  ),
                ],
              ),
            ),
            _HeaderCard(
              title: Row(
                children: [
                  Icon(LucideIcons.check, size: 16, color: colors.pass),
                  const SizedBox(width: Space.sm),
                  Flexible(child: Text(l10n.cardsPageCardIcon)),
                ],
              ),
              child: Text(body),
            ),
            _HeaderCard(
              title: Text(l10n.cardsPageCardSwitch),
              action: ToneSwitch(
                tone: Tone.deep,
                size: ToneSwitchSize.sm,
                shape: ToneSwitchShape.pill,
                initialValue: true,
                labelOn: Text(l10n.cardsPageSwitchOn.toUpperCase()),
                labelOff: Text(l10n.cardsPageSwitchOff.toUpperCase()),
                label: l10n.cardsPageCardSwitch,
              ),
              child: Text(body),
            ),
            _HeaderCard(
              title: Text(l10n.cardsPageCardLabel),
              action: ToneBadge(l10n.cardsPageLabelSuccess, tone: Tone.pass),
              child: Text(body),
            ),
            _HeaderCard(
              title: Text(l10n.cardsPageCardLabel),
              action: ToneBadge(
                context.formatNumber(cardBadgeCount),
                destructive: true,
                pill: true,
              ),
              child: Text(body),
            ),
          ],
        ),
        _Section(
          title: l10n.cardsPageOutlineSection,
          children: [
            for (final tone in cardRuledTones)
              _HeaderCard(
                title: Text(l10n.cardsPageOutlineTitle(tone.label(l10n))),
                outline: tone,
                child: Text(body),
              ),
          ],
        ),
        _Section(
          title: l10n.cardsPageAccentSection,
          children: [
            for (final tone in cardRuledTones)
              _HeaderCard(
                title: Text(l10n.cardsPageAccentTitle(tone.label(l10n))),
                accent: tone,
                child: Text(body),
              ),
          ],
        ),
        _Section(
          title: l10n.cardsPageQuoteSection,
          children: [for (final tone in cardQuotedTones) _QuoteCard(tone: tone)],
        ),
        _Section(
          title: l10n.cardsPageFilledSection,
          children: [
            for (final tone in cardFilledTones) _FilledCard(tone: tone, child: Text(body)),
            ActionsCard(tone: Tone.light, child: Text(body)),
          ],
        ),
      ],
    );
  }
}

/// One group of example cards under its own heading.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionTitle(title),
      for (final child in children) ...[const SizedBox(height: Space.page), child],
    ],
  );
}

/// A card with a ruled header band and a body; [outline] draws its frame and rule in a tone,
/// [accent] tops it with a thick rule in a tone.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.child,
    this.action,
    this.outline,
    this.accent,
  });

  final Widget title;
  final Widget? action;
  final Tone? outline;
  final Tone? accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final outlineColor = outline == null ? null : ToneColors.of(context, outline!).ink;
    final card = Card(
      clipBehavior: Clip.antiAlias,
      shape: outlineColor == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.sm),
              side: BorderSide(color: outlineColor),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Space.card,
              action == null ? Space.card : Space.page,
              action == null ? Space.card : Space.page,
              action == null ? Space.page : Space.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: DefaultTextStyle.merge(style: context.text.titleLarge, child: title),
                  ),
                ),
                if (action != null) ...[const SizedBox(width: Space.md), action!],
              ],
            ),
          ),
          Divider(color: outlineColor ?? colors.ink200),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.card, Space.page, Space.card, Space.card),
            child: DefaultTextStyle.merge(
              style: context.text.bodyMedium?.copyWith(color: colors.ink700),
              child: child,
            ),
          ),
        ],
      ),
    );
    if (accent == null) {
      return card;
    }
    // A thick rule over the card's top edge (the web's `border-t-[3px]`).
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Stack(
        children: [
          card,
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: Container(height: 3, color: ToneColors.of(context, accent!).ink),
          ),
        ],
      ),
    );
  }
}

/// A card filled with a tone, with a centred quote and its source.
class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.tone});

  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = ToneColors.of(context, tone);
    return _FilledCard(
      tone: tone,
      child: Column(
        children: [
          Text(
            l10n.cardsPageQuoteText,
            textAlign: TextAlign.center,
            style: context.text.bodyLarge?.copyWith(color: colors.onSolid, fontSize: 16),
          ),
          const SizedBox(height: Space.md),
          RichMessage(
            l10n.cardsPageQuoteSource,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: colors.onSolid.withValues(alpha: 0.85),
              fontSize: 14,
            ),
            tags: {
              'cite': (text) => TextSpan(
                text: text,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            },
          ),
        ],
      ),
    );
  }
}

/// A borderless card filled with a tone.
class _FilledCard extends StatelessWidget {
  const _FilledCard({required this.tone, required this.child});

  final Tone tone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = ToneColors.of(context, tone);
    return Card(
      color: colors.solid,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
      child: Padding(
        padding: const EdgeInsets.all(Space.card),
        child: DefaultTextStyle.merge(
          style: context.text.bodyMedium?.copyWith(color: colors.onSolid),
          child: child,
        ),
      ),
    );
  }
}
