import 'package:flutter/painting.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';
import 'package:flutter_boilerplate/features/showcase/theme/palette.dart';
import 'package:flutter_test/flutter_test.dart';

/// The web app's `:root` tokens (src/styles/global.css), which the light theme mirrors.
const _webTokens = {
  PaletteToken.folder: '#1f5c45',
  PaletteToken.folderDeep: '#164433',
  PaletteToken.folderInk: '#f1f5ef',
  PaletteToken.folderInkSoft: '#bcd3c5',
  PaletteToken.pass: '#1f6b4e',
  PaletteToken.pen: '#c42f2a',
  PaletteToken.pencil: '#5f666e',
  PaletteToken.paper: '#e8eee6',
  PaletteToken.paperCard: '#f5f8f3',
  PaletteToken.ply: '#ffffff',
  PaletteToken.ink950: '#111b30',
  PaletteToken.ink900: '#1b2b4b',
  PaletteToken.ink700: '#33436a',
  PaletteToken.ink600: '#4a5878',
  PaletteToken.ink400: '#8a94a9',
  PaletteToken.ink300: '#b3bccb',
  PaletteToken.ink200: '#cfd7de',
  PaletteToken.ink100: '#dfe5e6',
};

void main() {
  group('palette', () {
    test('lists every token once', () {
      final listed = [...themeColors, ...inkRamp];

      expect(listed.toSet(), PaletteToken.values.toSet());
      expect(listed, hasLength(PaletteToken.values.length));
    });

    test("gives the light theme the web app's values", () {
      for (final MapEntry(key: token, value: hex) in _webTokens.entries) {
        expect(hexOf(token.of(MarksheetColors.light)), hex, reason: token.name);
      }
    });

    test('reads every colour against another one', () {
      for (final token in PaletteToken.values) {
        expect(token.pair, isNot(token), reason: token.name);
      }
    });

    test('keeps every pair readable as large text in both themes, ink rules aside', () {
      const rules = {PaletteToken.ink400, PaletteToken.ink300, PaletteToken.ink200};
      for (final colors in [MarksheetColors.light, MarksheetColors.dark]) {
        for (final token in PaletteToken.values.where((token) => !rules.contains(token))) {
          expect(
            contrastRatio(token.of(colors), token.pair.of(colors)),
            greaterThanOrEqualTo(3),
            reason: '${token.name} with ${token.pair.name}',
          );
        }
      }
    });
  });

  group('rgbOf', () {
    test('splits a colour into channels', () {
      expect(rgbOf(const Color(0xFF1F5C45)), [31, 92, 69]);
    });
  });

  group('hexOf', () {
    test('writes a colour as #rrggbb', () {
      expect(hexOf(const Color(0xFF1F5C45)), '#1f5c45');
      expect(hexOf(const Color(0xFF000000)), '#000000');
    });
  });

  group('contrastRatio', () {
    const black = Color(0xFF000000);
    const white = Color(0xFFFFFFFF);

    test('gives 21:1 for black on white, in either order', () {
      expect(contrastRatio(black, white), closeTo(21, 0.001));
      expect(contrastRatio(white, black), closeTo(21, 0.001));
    });

    test('gives 1:1 for a colour against itself', () {
      expect(contrastRatio(const Color(0xFF1F5C45), const Color(0xFF1F5C45)), closeTo(1, 0.001));
    });

    test('keeps body ink readable on the card face in both themes', () {
      for (final colors in [MarksheetColors.light, MarksheetColors.dark]) {
        expect(contrastRatio(colors.ink900, colors.paperCard), greaterThan(7));
      }
    });
  });

  group('contrastLevel', () {
    test('names the WCAG level a ratio reaches', () {
      expect(contrastLevel(7.2), ContrastLevel.aaa);
      expect(contrastLevel(4.5), ContrastLevel.aa);
      expect(contrastLevel(3.1), ContrastLevel.large);
      expect(contrastLevel(1.4), ContrastLevel.decorative);
    });
  });
}
