import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_badge.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_data.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_links.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_list_group.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_colors.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';

/// `/dashboard/base/list-groups`: ruled lists of rows, plain, active, disabled, links, buttons,
/// badges, contextual tones, inside cards and with custom content.
class ListGroupsScreen extends StatefulWidget {
  const ListGroupsScreen({super.key});

  @override
  State<ListGroupsScreen> createState() => _ListGroupsScreenState();
}

class _ListGroupsScreenState extends State<ListGroupsScreen> {
  // The targets of the rows that link within the page (the web's `#hash` links).
  final _colorsLinksKey = GlobalKey();
  final _cardsKey = GlobalKey();
  final _customKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    String subject(Subject subject) => switch (subject) {
      Subject.maths => l10n.listGroupsPageSubjectMaths,
      Subject.physics => l10n.listGroupsPageSubjectPhysics,
      Subject.chemistry => l10n.listGroupsPageSubjectChemistry,
      Subject.biology => l10n.listGroupsPageSubjectBiology,
      Subject.history => l10n.listGroupsPageSubjectHistory,
    };

    final cardText = Text(
      l10n.listGroupsPageCardText,
      style: context.text.bodyMedium?.copyWith(color: colors.ink700),
    );
    List<Widget> cardLinks() => [
      for (final item in cardListSubjects)
        ListGroupItem(onTap: () => revealSection(_cardsKey), child: Text(subject(item))),
    ];

    return AppPage(
      title: l10n.listGroupsPageTitle,
      description: Text(l10n.listGroupsPageDescription),
      children: [
        DemoCard(
          title: l10n.listGroupsPageBasicTitle,
          child: ListGroup(
            label: l10n.listGroupsPageBasicTitle,
            children: [
              for (final item in Subject.values) ListGroupItem(child: Text(subject(item))),
            ],
          ),
        ),
        DemoCard(
          title: l10n.listGroupsPageActiveTitle,
          child: ListGroup(
            label: l10n.listGroupsPageActiveTitle,
            children: [
              for (final (index, item) in Subject.values.indexed)
                ListGroupItem(active: index == activeSubjectIndex, child: Text(subject(item))),
            ],
          ),
        ),
        DemoCard(
          title: l10n.listGroupsPageDisabledTitle,
          child: ListGroup(
            label: l10n.listGroupsPageDisabledTitle,
            children: [
              for (final (index, item) in Subject.values.indexed)
                ListGroupItem(
                  disabled: disabledSubjectIndexes.contains(index),
                  child: Text(subject(item)),
                ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.listGroupsPageLinksTitle,
          description: l10n.listGroupsPageLinksDescription,
          child: ListGroup(
            label: l10n.listGroupsPageLinksTitle,
            children: [
              ListGroupItem(
                onTap: () => openAppPath(context, Routes.dashboard),
                child: Text(l10n.listGroupsPageLinkOverview),
              ),
              // The page you are on: nowhere to go.
              ListGroupItem(active: true, onTap: () {}, child: Text(l10n.listGroupsPageLinkActive)),
              ListGroupItem(
                onTap: () => openAppPath(context, Routes.testResults),
                child: Text(l10n.listGroupsPageLinkResults),
              ),
              ListGroupItem(
                disabled: true,
                onTap: () => openAppPath(context, Routes.account),
                child: Text(l10n.listGroupsPageLinkDisabled),
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.listGroupsPageButtonsTitle,
          description: l10n.listGroupsPageButtonsDescription,
          child: ButtonListGroup(
            label: l10n.listGroupsPageButtonsTitle,
            items: [
              (id: 'one', label: l10n.listGroupsPageButtonOne, disabled: false),
              (id: 'two', label: l10n.listGroupsPageButtonTwo, disabled: false),
              (id: 'disabled', label: l10n.listGroupsPageButtonDisabled, disabled: true),
              (id: 'three', label: l10n.listGroupsPageButtonThree, disabled: false),
            ],
          ),
        ),
        DemoCard(
          title: l10n.listGroupsPageBadgesTitle,
          child: ListGroup(
            label: l10n.listGroupsPageBadgesTitle,
            children: [
              for (final row in subjectTestCounts)
                ListGroupItem(
                  child: Row(
                    children: [
                      Expanded(child: Text(subject(row.subject))),
                      const SizedBox(width: Space.md),
                      ToneBadge(
                        context.formatNumber(row.count),
                        pill: true,
                        semanticsLabel: l10n.listGroupsPageBadgeLabel(row.count),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.listGroupsPageColorsTitle,
          description: l10n.listGroupsPageColorsDescription,
          child: ListGroup(
            label: l10n.listGroupsPageColorsTitle,
            children: [
              ListGroupItem(child: Text(l10n.listGroupsPageColorsDefault)),
              for (final tone in Tone.values)
                ListGroupItem(
                  tone: tone,
                  child: Text(l10n.listGroupsPageColorsItem(tone.label(l10n))),
                ),
            ],
          ),
        ),
        DemoCard(
          key: _colorsLinksKey,
          title: l10n.listGroupsPageColorsLinksTitle,
          description: l10n.listGroupsPageColorsLinksDescription,
          child: ListGroup(
            label: l10n.listGroupsPageColorsLinksTitle,
            children: [
              ListGroupItem(
                onTap: () => revealSection(_colorsLinksKey),
                child: Text(l10n.listGroupsPageColorsDefault),
              ),
              for (final tone in Tone.values)
                ListGroupItem(
                  tone: tone,
                  onTap: () => revealSection(_colorsLinksKey),
                  child: Text(l10n.listGroupsPageColorsItem(tone.label(l10n))),
                ),
            ],
          ),
        ),
        DemoCard(
          key: _cardsKey,
          title: l10n.listGroupsPageCardsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InnerCard(
                title: l10n.listGroupsPageCardWithList,
                ruled: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.card,
                    Space.page,
                    Space.card,
                    Space.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListGroup(label: l10n.listGroupsPageCardWithList, children: cardLinks()),
                      const SizedBox(height: Space.md),
                      cardText,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.page),
              _InnerCard(
                title: l10n.listGroupsPageCardWithFlush,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListGroup(
                      flush: true,
                      label: l10n.listGroupsPageCardWithFlush,
                      children: cardLinks(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Space.card,
                        Space.page,
                        Space.card,
                        Space.card,
                      ),
                      child: cardText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DemoCard(
          key: _customKey,
          title: l10n.listGroupsPageCustomTitle,
          child: ListGroup(
            label: l10n.listGroupsPageCustomTitle,
            children: [
              for (final item in CustomListItem.values)
                ListGroupItem(
                  active: item.isActive,
                  disabled: item.isDisabled,
                  onTap: () => revealSection(_customKey),
                  child: _CustomRow(item: item),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A card inside the "inside cards" example: a title, optionally ruled off, then [child].
class _InnerCard extends StatelessWidget {
  const _InnerCard({required this.title, required this.child, this.ruled = false});

  final String title;
  final bool ruled;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.card, Space.card, Space.card, Space.page),
          child: Semantics(
            header: true,
            child: Text(title, style: context.text.titleLarge),
          ),
        ),
        if (ruled) Divider(color: context.colors.ink200),
        child,
      ],
    ),
  );
}

/// A custom row: title and age on one line, then the text and a small note.
class _CustomRow extends StatelessWidget {
  const _CustomRow({required this.item});

  final CustomListItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final (title, text, note) = switch (item) {
      CustomListItem.spanish => (
        l10n.listGroupsPageCustomSpanishTitle,
        l10n.listGroupsPageCustomSpanishText,
        l10n.listGroupsPageCustomSpanishNote,
      ),
      CustomListItem.physics => (
        l10n.listGroupsPageCustomPhysicsTitle,
        l10n.listGroupsPageCustomPhysicsText,
        l10n.listGroupsPageCustomPhysicsNote,
      ),
      CustomListItem.disabled => (
        l10n.listGroupsPageCustomDisabledTitle,
        l10n.listGroupsPageCustomDisabledText,
        l10n.listGroupsPageCustomDisabledNote,
      ),
    };
    // Small print keeps the row's colour when active, and is greyed otherwise.
    final smallStyle = TextStyle(fontSize: 13, color: item.isActive ? null : colors.ink600);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: Space.md,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(l10n.listGroupsPageDaysAgo(item.days), style: smallStyle),
          ],
        ),
        const SizedBox(height: Space.xs),
        Text(text),
        const SizedBox(height: Space.xs),
        Text(
          note,
          style: item.isActive ? smallStyle.copyWith(color: colors.folderInkSoft) : smallStyle,
        ),
      ],
    );
  }
}
