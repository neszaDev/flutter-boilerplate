import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/brand_buttons_data.dart';
import 'package:flutter_boilerplate/features/showcase/icons/brand_icons_data.dart';
import 'package:flutter_boilerplate/features/showcase/icons/flags_data.dart';
import 'package:flutter_boilerplate/features/showcase/icons/gallery.dart';
import 'package:flutter_boilerplate/features/showcase/icons/lucide_icons_data.dart';
import 'package:flutter_boilerplate/features/showcase/icons/material_icons_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('searchNames', () {
    const names = ['ArrowRight', 'ArrowLeft', 'Calendar', 'cib-github', 'cib-gitlab'];

    test('matches regardless of case, spaces and dashes', () {
      expect(searchNames(names, 'arrow right'), ['ArrowRight']);
      expect(searchNames(names, 'CIBGIT'), hasLength(2));
    });

    test('treats underscores like dashes, for Material names', () {
      expect(searchNames(['arrow_right', 'arrowRight', 'arrow'], 'arrow-right'), [
        'arrow_right',
        'arrowRight',
      ]);
    });

    test('returns every name, in order, for an empty or blank query', () {
      expect(searchNames(names, ''), names);
      expect(searchNames(names, '  '), names);
    });

    test('returns nothing when nothing matches', () {
      expect(searchNames(names, 'zebra'), isEmpty);
    });
  });

  group('flagEmoji', () {
    test('spells a country code in regional indicator symbols', () {
      expect(flagEmoji('fr'), '🇫🇷');
      expect(flagEmoji('GB'), '\u{1F1EC}\u{1F1E7}');
    });
  });

  group('icon data', () {
    test('lists each flag of the web set once, as a two-letter code', () {
      expect(flagCodes, hasLength(198));
      expect(flagCodes.toSet(), hasLength(flagCodes.length));
      expect(flagCodes, everyElement(matches(RegExp(r'^[A-Z]{2}$'))));
    });

    test('names each icon by its getter', () {
      expect(lucideIcons['arrowRight'], LucideIcons.arrowRight);
      expect(materialIcons['arrow_right'], Icons.arrow_right);
      expect(brandIcons['github'], FontAwesomeIcons.github);
    });

    test('keeps one Material style per icon', () {
      expect(materialIcons, contains('search'));
      expect(materialIcons, isNot(contains('search_outlined')));
      expect(materialIcons, isNot(contains('search_rounded')));
    });

    test('carries every mark of the brand buttons', () {
      expect(brandIcons.values, containsAll(brands.map((brand) => brand.icon)));
    });
  });
}
