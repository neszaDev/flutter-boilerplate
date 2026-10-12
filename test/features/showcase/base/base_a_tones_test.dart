import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_data.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tone_colors.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tone', () {
    test('follows the order of the Vue colour variants', () {
      expect(Tone.values, [
        Tone.folder,
        Tone.ink,
        Tone.pass,
        Tone.pencil,
        Tone.deep,
        Tone.pen,
        Tone.light,
        Tone.dark,
      ]);
    });
  });

  group('card tones', () {
    test('leave red pen to errors', () {
      for (final tones in [cardRuledTones, cardQuotedTones, cardFilledTones]) {
        expect(tones, isNot(contains(Tone.pen)));
      }
    });
  });

  group('radio switch tones', () {
    test('list every tone once, warning before success, and start on pencil', () {
      expect(radioSwitchTones.toSet(), Tone.values.toSet());
      expect(radioSwitchTones, hasLength(Tone.values.length));
      expect(radioSwitchTones.indexOf(Tone.pencil), lessThan(radioSwitchTones.indexOf(Tone.pass)));
      expect(radioSwitchInitial, Tone.pencil);
    });
  });

  group('ToneColors', () {
    const day = MarksheetColors.light;
    const night = MarksheetColors.dark;

    test('fills surfaces with the web tone and readable text', () {
      final folder = ToneColors.resolve(Tone.folder, day, dark: false);
      expect(folder.solid, day.folder);
      expect(folder.onSolid, day.folderInk);
      final light = ToneColors.resolve(Tone.light, day, dark: false);
      expect(light.solid, day.ink200);
      expect(light.onSolid, day.ink950);
    });

    test('lifts the folder greens on paper at night', () {
      expect(ToneColors.resolve(Tone.folder, day, dark: false).ink, day.folder);
      expect(ToneColors.resolve(Tone.folder, night, dark: true).ink, night.primary);
      expect(ToneColors.resolve(Tone.deep, day, dark: false).ink, day.folderDeep);
      expect(ToneColors.resolve(Tone.deep, night, dark: true).ink, night.folderInkSoft);
    });

    test('washes contextual rows lightly, the light tone on white', () {
      final pass = ToneColors.resolve(Tone.pass, day, dark: false);
      expect(pass.softText, day.pass);
      expect(pass.softBackground, day.pass.withValues(alpha: 0.10));
      expect(pass.softPressed, day.pass.withValues(alpha: 0.20));
      final light = ToneColors.resolve(Tone.light, day, dark: false);
      expect(light.softBackground, day.ply);
      expect(light.softText, day.ink700);
    });
  });
}
