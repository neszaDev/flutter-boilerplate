import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/brand.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/test_results/widgets/report_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// The web version of this template.
final webBoilerplateUrl = Uri.parse('https://github.com/neszaDev/nextjs-boilerplate');

/// `/`: what a signed-out visitor sees first (the web app's landing page, phone-sized).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final inverse = FilledButton.styleFrom(
      backgroundColor: colors.folderInk,
      foregroundColor: colors.folder,
      minimumSize: const Size(64, 48),
    );
    final marks = [
      (TestStatus.passed, l10n.indexKeyPassed),
      (TestStatus.failed, l10n.indexKeyFailed),
      (TestStatus.pending, l10n.indexKeyPending),
    ];
    final fields = [
      (l10n.indexRowName, l10n.indexRowNameDesc),
      (l10n.indexRowStatus, l10n.indexRowStatusDesc),
      (l10n.indexRowScore, l10n.indexRowScoreDesc),
      (l10n.indexRowTestedAt, l10n.indexRowTestedAtDesc),
      (l10n.indexRowNotes, l10n.indexRowNotesDesc),
    ];
    final features = [
      (l10n.indexFeatureTotalsTitle, l10n.indexFeatureTotals),
      (l10n.indexFeatureHistoryTitle, l10n.indexFeatureHistory),
      (l10n.indexFeaturePrivateTitle, l10n.indexFeaturePrivate),
      (l10n.indexFeatureLanguagesTitle, l10n.indexFeatureLanguages),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // The folder: copy, then the card sliding out of it.
          SliverToBoxAdapter(
            child: ColoredBox(
              color: colors.folder,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Wordmark(onFolder: true),
                          const Spacer(),
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: colors.folderInk),
                            onPressed: () => context.push(Routes.about),
                            child: Text(l10n.menuPageAbout),
                          ),
                          const LocaleSwitcher(onFolder: true),
                        ],
                      ),
                      const SizedBox(height: Space.xl),
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.indexTitle,
                          style: context.text.displayLarge?.copyWith(color: colors.folderInk),
                        ),
                      ),
                      const SizedBox(height: Space.card),
                      Text(
                        l10n.indexIntro,
                        style: context.text.bodyLarge?.copyWith(color: colors.folderInkSoft),
                      ),
                      const SizedBox(height: Space.lg),
                      Wrap(
                        spacing: Space.sm,
                        runSpacing: Space.sm,
                        children: [
                          FilledButton(
                            key: const Key('welcome.signUp'),
                            style: inverse,
                            onPressed: () => context.go(Routes.signUp),
                            child: Text(l10n.indexCta),
                          ),
                          TextButton(
                            key: const Key('welcome.signIn'),
                            style: TextButton.styleFrom(
                              foregroundColor: colors.folderInk,
                              minimumSize: const Size(64, 48),
                            ),
                            onPressed: () => context.go(Routes.signIn),
                            child: Text(l10n.indexSecondaryCta),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.xl),
                      Transform.translate(
                        offset: const Offset(0, Space.xl),
                        child: Transform.rotate(angle: -0.015, child: const SampleCard()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.section + Space.xl,
              Space.page,
              Space.section,
            ),
            sliver: SliverList.list(
              children: [
                // Key to the marks.
                Text(l10n.indexKeyTitle, style: context.text.headlineLarge),
                const SizedBox(height: Space.md),
                Text(
                  l10n.indexKeyIntro,
                  style: context.text.bodyLarge?.copyWith(color: colors.ink600),
                ),
                const SizedBox(height: Space.lg),
                const DoubleRule(),
                for (final (status, text) in marks) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.card),
                    child: Row(
                      children: [
                        Mark(status: status, size: 48, animate: true),
                        const SizedBox(width: Space.card),
                        Expanded(child: Text(text, style: context.text.titleMedium)),
                      ],
                    ),
                  ),
                  Divider(color: colors.ink200),
                ],
                const SizedBox(height: Space.section),
                // One row of the card, taken apart.
                Text(l10n.indexRowsTitle, style: context.text.headlineLarge),
                const SizedBox(height: Space.md),
                Text(
                  l10n.indexRowsIntro,
                  style: context.text.bodyLarge?.copyWith(color: colors.ink600),
                ),
                const SizedBox(height: Space.lg),
                const DoubleRule(),
                for (final (label, text) in fields) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.page),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel(label),
                        const SizedBox(height: Space.sm),
                        Text(text, style: context.text.bodyMedium?.copyWith(color: colors.ink600)),
                      ],
                    ),
                  ),
                  Divider(color: colors.ink200),
                ],
                const SizedBox(height: Space.section),
                Text(l10n.indexFeaturesTitle, style: context.text.headlineLarge),
                const SizedBox(height: Space.lg),
                for (final (title, text) in features) ...[
                  Divider(color: colors.ink300),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.card),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.text.titleMedium),
                        const SizedBox(height: Space.xs),
                        Text(text, style: context.text.bodyMedium?.copyWith(color: colors.ink700)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Close: back into the folder.
          SliverToBoxAdapter(
            child: ColoredBox(
              color: colors.folder,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.page,
                    Space.section,
                    Space.page,
                    Space.section,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Mark(status: TestStatus.passed, size: 44, color: colors.folderInkSoft),
                          const SizedBox(width: Space.md),
                          Expanded(
                            child: Text(
                              l10n.indexCloseTitle,
                              style: context.text.displayMedium?.copyWith(color: colors.folderInk),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.md),
                      Text(
                        l10n.indexCloseText,
                        style: context.text.bodyLarge?.copyWith(color: colors.folderInkSoft),
                      ),
                      const SizedBox(height: Space.lg),
                      FilledButton(
                        style: inverse,
                        onPressed: () => context.go(Routes.signUp),
                        child: Text(l10n.indexCta),
                      ),
                      const SizedBox(height: Space.xl),
                      Text(
                        l10n.brandSampleNote,
                        style: context.text.bodySmall?.copyWith(color: colors.folderInkSoft),
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

/// The filled-in report card on the welcome screen: the real results list and totals, with
/// sample rows whose marks draw on one after another.
class SampleCard extends StatelessWidget {
  const SampleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final rows = [
      _sample(1, l10n.indexSample1Name, TestStatus.passed, 94, '2026-09-28T09:30:00Z'),
      _sample(
        2,
        l10n.indexSample2Name,
        TestStatus.failed,
        58,
        '2026-09-24T14:00:00Z',
        l10n.indexSample2Note,
      ),
      _sample(3, l10n.indexSample3Name, TestStatus.passed, 88, '2026-09-19T08:15:00Z'),
      _sample(4, l10n.indexSample4Name, TestStatus.passed, 100, '2026-09-12T16:45:00Z'),
      _sample(
        5,
        l10n.indexSample5Name,
        TestStatus.pending,
        81,
        '2026-09-09T11:00:00Z',
        l10n.indexSample5Note,
      ),
      _sample(6, l10n.indexSample6Name, TestStatus.passed, 72, '2026-09-03T07:20:00Z'),
    ];
    final summary = TestResultSummary(
      total: rows.length,
      byStatus: {
        for (final status in TestStatus.values)
          status: rows.where((row) => row.status == status).length,
      },
    );

    return Semantics(
      label: l10n.indexSampleTag,
      child: Container(
        decoration: BoxDecoration(
          color: colors.paperCard,
          borderRadius: BorderRadius.circular(Radii.lg),
          boxShadow: const [
            BoxShadow(color: Color(0x33111B30), blurRadius: 24, offset: Offset(0, 12)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.card, Space.card, Space.page, Space.page),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.indexCardTitle, style: context.text.headlineSmall)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.ply,
                      border: Border.all(color: colors.ink300),
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Text(l10n.indexSampleTag.toUpperCase(), style: context.type.formLabel),
                  ),
                ],
              ),
            ),
            const DoubleRule(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.card, vertical: Space.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  FormLabel(l10n.indexCardNameLabel),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Text(
                      l10n.indexCardName,
                      style: context.type.handNote.copyWith(fontSize: 18),
                    ),
                  ),
                  Text(l10n.indexCardTerm, style: context.text.bodySmall),
                ],
              ),
            ),
            Divider(color: colors.ink200),
            ResultsList(
              rows: rows,
              compact: true,
              drawDelays: {
                for (final (index, row) in rows.indexed)
                  row.id: Duration(milliseconds: 500 + index * 220),
              },
            ),
            Divider(color: colors.ink300),
            Padding(
              padding: const EdgeInsets.all(Space.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormLabel(l10n.indexRemarkLabel),
                  const SizedBox(height: Space.xs),
                  Text(l10n.indexRemark, style: context.type.handRemark.copyWith(fontSize: 20)),
                  const SizedBox(height: Space.page),
                  TotalsStrip(summary: summary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static TestResult _sample(
    int id,
    String name,
    TestStatus status,
    double score,
    String testedAt, [
    String? notes,
  ]) => TestResult(
    id: id,
    testName: name,
    status: status,
    score: score,
    testedAt: DateTime.parse(testedAt),
    notes: notes,
  );
}

/// `/about`: what this template is and what's inside.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _upstream = TapGestureRecognizer()
    ..onTap = () => launchUrl(webBoilerplateUrl, mode: LaunchMode.externalApplication);

  @override
  void dispose() {
    _upstream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final features = [
      l10n.aboutFeatureAuth,
      l10n.aboutFeatureApi,
      l10n.aboutFeatureRbac,
      l10n.aboutFeatureDevice,
      l10n.aboutFeatureUi,
      l10n.aboutFeatureI18n,
      l10n.aboutFeatureQuality,
    ];
    final body = context.text.bodyLarge?.copyWith(color: colors.ink700);

    return AppPage(
      title: l10n.aboutTitle,
      children: [
        Text(l10n.aboutAboutParagraph, style: body),
        Text(l10n.aboutReplaceParagraph, style: body),
        SheetCard(
          title: l10n.aboutInsideTitle,
          child: Column(
            children: [
              for (final feature in features)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Mark(status: TestStatus.passed, size: 18),
                      const SizedBox(width: Space.md),
                      Expanded(child: Text(feature, style: context.text.bodyMedium)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        RichMessage(
          l10n.aboutCredits,
          style: context.text.bodyMedium?.copyWith(color: colors.ink600),
          tags: {
            'upstream': (text) => TextSpan(
              text: text,
              style: TextStyle(
                color: colors.primary,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
              recognizer: _upstream,
            ),
          },
        ),
      ],
    );
  }
}
