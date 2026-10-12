import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/theme/type_scale.dart';

/// Below this window width the description list stacks its terms over the descriptions.
const _wideFrom = 600.0;

/// The text of [message] without its `<code>` markup: `DemoCard` descriptions are plain text.
String _plain(String message) =>
    TextSpan(children: RichMessage.spans(message, const {})).toPlainText();

/// The role's printed name and its sample line.
(String name, String sample) _copyOf(AppLocalizations l10n, TypeRole role) => switch (role) {
  TypeRole.headline => (l10n.typographyPageRoleHeadline, l10n.typographyPageSampleHeadline),
  TypeRole.pageTitle => (l10n.typographyPageRolePageTitle, l10n.typographyPageSamplePageTitle),
  TypeRole.section => (l10n.typographyPageRoleSection, l10n.typographyPageSampleSection),
  TypeRole.title => (l10n.typographyPageRoleTitle, l10n.typographyPageSampleTitle),
  TypeRole.subtitle => (l10n.typographyPageRoleSubtitle, l10n.typographyPageSampleSubtitle),
  TypeRole.smallTitle => (
    l10n.typographyPageRoleSmallTitle,
    l10n.typographyPageSampleSmallTitle,
  ),
  TypeRole.display => (l10n.typographyPageRoleDisplay, l10n.typographyPageSampleDisplay),
  TypeRole.displaySmall => (
    l10n.typographyPageRoleDisplaySmall,
    l10n.typographyPageSampleDisplaySmall,
  ),
  TypeRole.figure => (l10n.typographyPageRoleFigure, l10n.typographyPageSampleFigure),
  TypeRole.lead => (l10n.typographyPageTextLead, l10n.typographyPageTextSampleLead),
  TypeRole.body => (l10n.typographyPageTextBody, l10n.typographyPageTextSampleBody),
  TypeRole.hint => (l10n.typographyPageTextHint, l10n.typographyPageTextSampleHint),
  TypeRole.table => (l10n.typographyPageTextTable, l10n.typographyPageTextSampleTable),
  TypeRole.label => (l10n.typographyPageTextLabel, l10n.typographyPageTextSampleLabel),
  TypeRole.button => (l10n.typographyPageTextButton, l10n.typographyPageTextSampleButton),
  TypeRole.chip => (l10n.typographyPageTextChip, l10n.typographyPageTextSampleChip),
  TypeRole.badge => (l10n.typographyPageTextBadge, l10n.typographyPageTextSampleBadge),
  TypeRole.code => (l10n.typographyPageTextCode, l10n.typographyPageTextSampleCode),
  TypeRole.handRemark => (
    l10n.typographyPageTextHandRemark,
    l10n.typographyPageTextSampleHandRemark,
  ),
  TypeRole.handNote => (l10n.typographyPageTextHandNote, l10n.typographyPageTextSampleHandNote),
};

/// `/dashboard/theme/typography`: the app's real text styles, `context.text` and
/// `context.type`, each with its spec.
class TypographyScreen extends StatelessWidget {
  const TypographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.typographyPageTitle,
      description: Text(l10n.typographyPageDescription),
      children: [
        DemoCard(
          title: l10n.typographyPageHeadingsTitle,
          description: l10n.typographyPageHeadingsDescription,
          child: _Rows([for (final role in headingRoles) _HeadingRow(role)]),
        ),
        DemoCard(
          title: l10n.typographyPageClassesTitle,
          description: _plain(l10n.typographyPageClassesDescription),
          child: _Rows(divided: false, [
            for (final role in classRoles)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Sample(role, sample: _copyOf(l10n, role).$2),
                  const SizedBox(height: 6),
                  _Code(role.token.expression),
                ],
              ),
          ]),
        ),
        DemoCard(
          title: l10n.typographyPageDisplayTitle,
          description: l10n.typographyPageDisplayDescription,
          child: _Rows([
            for (final role in displayRoles)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Sample(role, sample: _copyOf(l10n, role).$2),
                  const SizedBox(height: Space.sm),
                  _Spec(role, prefix: _copyOf(l10n, role).$1),
                ],
              ),
          ]),
        ),
        DemoCard(
          title: l10n.typographyPageTextTitle,
          description: l10n.typographyPageTextDescription,
          child: _Rows([
            for (final role in textRoles)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormLabel(_copyOf(l10n, role).$1),
                  const SizedBox(height: Space.xs),
                  _Spec(role),
                  const SizedBox(height: Space.sm),
                  _Sample(role, sample: _copyOf(l10n, role).$2),
                ],
              ),
          ]),
        ),
        DemoCard(
          title: l10n.typographyPageInlineTitle,
          description: l10n.typographyPageInlineDescription,
          child: const _InlineElements(),
        ),
        DemoCard(
          title: l10n.typographyPageDlTitle,
          description: _plain(l10n.typographyPageDlDescription),
          child: const _DescriptionList(),
        ),
      ],
    );
  }
}

/// Examples one under the other, ruled apart unless [divided] is false.
class _Rows extends StatelessWidget {
  const _Rows(this.children, {this.divided = true});

  final List<Widget> children;
  final bool divided;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, child) in children.indexed) ...[
        if (index > 0)
          divided ? const Divider(height: Space.xl + 1) : const SizedBox(height: Space.card),
        child,
      ],
    ],
  );
}

/// Code in the running text: monospace on a muted fill.
class _Code extends StatelessWidget {
  const _Code(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.ink100,
      borderRadius: BorderRadius.circular(Radii.sm),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: 2),
      child: Text(text, style: context.type.code.copyWith(color: context.colors.ink950)),
    ),
  );
}

/// [sample] set in [role]'s style.
class _Sample extends StatelessWidget {
  const _Sample(this.role, {required this.sample});

  final TypeRole role;
  final String sample;

  @override
  Widget build(BuildContext context) => Text(
    role.caps ? sample.toUpperCase() : sample,
    style: role.token.resolve(context.text, context.type),
  );
}

/// The spec line of [role]'s style, after an optional [prefix].
class _Spec extends StatelessWidget {
  const _Spec(this.role, {this.prefix});

  final TypeRole role;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final spec = describeStyle(role.token.resolve(context.text, context.type), caps: role.caps);
    return Text(
      prefix == null ? spec : '$prefix · $spec',
      style: context.type.table.copyWith(fontSize: 12, color: context.colors.ink600),
    );
  }
}

/// A heading role: the style's name and role, then the sample and its spec.
class _HeadingRow extends StatelessWidget {
  const _HeadingRow(this.role);

  final TypeRole role;

  @override
  Widget build(BuildContext context) {
    final (name, sample) = _copyOf(context.l10n, role);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Code(role.token.name),
            Text(name, style: context.text.bodySmall),
          ],
        ),
        const SizedBox(height: Space.md),
        _Sample(role, sample: sample),
        const SizedBox(height: Space.xs),
        _Spec(role),
      ],
    );
  }
}

/// The web's inline HTML elements as `TextSpan` styles.
class _InlineElements extends StatelessWidget {
  const _InlineElements();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    const lineThrough = TextStyle(decoration: TextDecoration.lineThrough);
    const underline = TextStyle(decoration: TextDecoration.underline);
    final lines = [
      ('del', l10n.typographyPageInlineDel, lineThrough),
      ('s', l10n.typographyPageInlineS, lineThrough),
      ('ins', l10n.typographyPageInlineIns, underline.copyWith(decorationColor: colors.primary)),
      ('u', l10n.typographyPageInlineU, underline),
      ('small', l10n.typographyPageInlineSmall, const TextStyle(fontSize: 13)),
      ('strong', l10n.typographyPageInlineStrong, const TextStyle(fontWeight: FontWeight.w700)),
      ('em', l10n.typographyPageInlineEm, const TextStyle(fontStyle: FontStyle.italic)),
    ];
    final body = context.text.bodyMedium;

    Widget line(String tag, Widget text) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Code('<$tag>'),
        const SizedBox(height: Space.xs),
        text,
      ],
    );

    return _Rows(divided: false, [
      line(
        'mark',
        RichMessage(
          l10n.typographyPageInlineMark,
          style: body,
          tags: {
            'mark': (text) => TextSpan(
              text: text,
              style: TextStyle(
                backgroundColor: colors.primary.withValues(alpha: 0.15),
                color: colors.ink950,
              ),
            ),
          },
        ),
      ),
      for (final (tag, text, style) in lines) line(tag, Text(text, style: body?.merge(style))),
    ]);
  }
}

/// Printed terms and their descriptions: stacked on a phone, side by side when there is room.
class _DescriptionList extends StatelessWidget {
  const _DescriptionList();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wide = MediaQuery.sizeOf(context).width >= _wideFrom;
    final body = context.text.bodyMedium;
    return _Terms(
      wide: wide,
      entries: [
        (l10n.typographyPageDlTermLists, Text(l10n.typographyPageDlLists, style: body)),
        (
          l10n.typographyPageDlTermMarking,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.typographyPageDlMarking1, style: body),
              const SizedBox(height: Space.sm),
              Text(l10n.typographyPageDlMarking2, style: body),
            ],
          ),
        ),
        (l10n.typographyPageDlTermRetakes, Text(l10n.typographyPageDlRetakes, style: body)),
        (l10n.typographyPageDlTermTruncated, Text(l10n.typographyPageDlTruncated, style: body)),
        (
          l10n.typographyPageDlTermNesting,
          _Terms(
            wide: wide,
            entries: [
              (l10n.typographyPageDlTermNested, Text(l10n.typographyPageDlNested, style: body)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A description list: each term a printed label, cut with an ellipsis when its column is
/// too narrow (long-press shows it whole).
class _Terms extends StatelessWidget {
  const _Terms({required this.entries, required this.wide});

  final List<(String term, Widget description)> entries;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    Widget term(String text) => Tooltip(
      message: text,
      child: Padding(
        padding: const EdgeInsets.only(top: Space.xs),
        child: Text(
          text.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.type.formLabel,
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, (text, description)) in entries.indexed) ...[
          if (index > 0) SizedBox(height: wide ? Space.md : Space.page),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: term(text)),
                const SizedBox(width: Space.lg),
                Expanded(flex: 3, child: description),
              ],
            )
          else ...[
            term(text),
            const SizedBox(height: Space.xs),
            description,
          ],
        ],
      ],
    );
  }
}
