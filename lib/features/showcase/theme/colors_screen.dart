import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/theme/palette.dart';

/// `/dashboard/theme/colors`: the Marksheet palette of the current theme, read from
/// `context.colors`, with each colour's contrast against the one it is read with.
class ColorsScreen extends StatelessWidget {
  const ColorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.colorsPageTitle,
      description: Text(l10n.colorsPageDescription),
      children: [
        DemoCard(
          title: l10n.colorsPageThemeTitle,
          description: l10n.colorsPageThemeDescription,
          child: const _SwatchGrid(themeColors),
        ),
        DemoCard(
          title: l10n.colorsPageInkTitle,
          description: l10n.colorsPageInkDescription,
          child: const _SwatchGrid(inkRamp),
        ),
      ],
    );
  }
}

/// Swatches two to a row on a phone, more on a tablet.
class _SwatchGrid extends StatelessWidget {
  const _SwatchGrid(this.tokens);

  final List<PaletteToken> tokens;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = Space.card;
      final columns = (constraints.maxWidth / 180).floor().clamp(2, 5);
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: Space.xl,
        children: [
          for (final token in tokens) SizedBox(width: width, child: _Swatch(token)),
        ],
      );
    },
  );
}

/// One palette colour (the web's `ColorTheme`): its swatch, token, role, hex and RGB values,
/// and its contrast against the colour it is read with.
class _Swatch extends StatelessWidget {
  const _Swatch(this.token);

  final PaletteToken token;

  String _role(AppLocalizations l10n) => switch (token) {
    PaletteToken.folder => l10n.colorsPageRoleFolder,
    PaletteToken.folderDeep => l10n.colorsPageRoleFolderDeep,
    PaletteToken.folderInk => l10n.colorsPageRoleFolderInk,
    PaletteToken.folderInkSoft => l10n.colorsPageRoleFolderInkSoft,
    PaletteToken.primary => l10n.colorsPageRolePrimary,
    PaletteToken.onPrimary => l10n.colorsPageRoleOnPrimary,
    PaletteToken.pass => l10n.colorsPageRolePass,
    PaletteToken.pen => l10n.colorsPageRolePen,
    PaletteToken.pencil => l10n.colorsPageRolePencil,
    PaletteToken.paper => l10n.colorsPageRolePaper,
    PaletteToken.paperCard => l10n.colorsPageRolePaperCard,
    PaletteToken.ply => l10n.colorsPageRolePly,
    PaletteToken.ink950 => l10n.colorsPageRoleInk950,
    PaletteToken.ink900 => l10n.colorsPageRoleInk900,
    PaletteToken.ink700 => l10n.colorsPageRoleInk700,
    PaletteToken.ink600 => l10n.colorsPageRoleInk600,
    PaletteToken.ink400 => l10n.colorsPageRoleInk400,
    PaletteToken.ink300 => l10n.colorsPageRoleInk300,
    PaletteToken.ink200 => l10n.colorsPageRoleInk200,
    PaletteToken.ink100 => l10n.colorsPageRoleInk100,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final color = token.of(colors);
    final pair = token.pair.of(colors);
    final ratio = contrastRatio(color, pair);
    final small = context.text.bodySmall;
    final value = context.type.table.copyWith(fontSize: 13, fontWeight: FontWeight.w600);

    TableRow row(String label, Widget content) => TableRow(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: Space.md, bottom: Space.xs),
          child: Text(label, style: small),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: Space.xs),
          child: content,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: colors.ink200),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: ExcludeSemantics(
                  child: Text(
                    l10n.colorThemeSample,
                    style: context.text.headlineSmall?.copyWith(color: pair),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        Semantics(
          header: true,
          child: Text(
            token.name,
            style: context.type.code.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.ink950,
            ),
          ),
        ),
        const SizedBox(height: Space.xs),
        Text(_role(l10n), style: small),
        const SizedBox(height: Space.md),
        Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          children: [
            row(l10n.colorThemeHex, Text(hexOf(color), style: value)),
            row(
              l10n.colorThemeRgb,
              Text(l10n.colorThemeRgbValue(rgbOf(color).join(', ')), style: value),
            ),
            row(
              l10n.colorThemeContrast,
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: l10n.colorThemeRatio(ratio), style: value),
                    TextSpan(
                      text:
                          ' ${l10n.colorThemeAgainst(token.pair.name, contrastLevel(ratio).name)}',
                    ),
                  ],
                ),
                style: small?.copyWith(color: colors.ink900),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
