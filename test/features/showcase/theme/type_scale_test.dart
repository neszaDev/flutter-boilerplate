import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';
import 'package:flutter_boilerplate/features/showcase/theme/type_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final text = AppTheme.light().textTheme;
  const type = MarksheetType(MarksheetColors.light);

  String spec(TypeToken token, {bool caps = false}) =>
      describeStyle(token.resolve(text, type), caps: caps);

  group('describeStyle', () {
    test('writes the weight, size, line height and tracking', () {
      expect(spec(TypeToken.headlineMedium), '700 · 28 · 1.25 · -0.56');
      expect(spec(TypeToken.displayLarge), '800 · 44 · 1.02 · -1.54');
    });

    test('marks tabular figures and capitals', () {
      expect(spec(TypeToken.figure), '600 · 30 · 1.2 · -0.75 · tnum');
      expect(spec(TypeToken.formLabel, caps: true), '600 · 11 · 1 · 1.32 · caps');
    });

    test('names a family other than Libre Franklin', () {
      expect(spec(TypeToken.handRemark), 'Kalam 400 · 22 · 1.375');
      expect(spec(TypeToken.code), startsWith('monospace 400 · 13'));
    });
  });

  group('TypeToken', () {
    test('says how code reaches each style', () {
      expect(TypeToken.titleLarge.expression, 'context.text.titleLarge');
      expect(TypeToken.labelSmall.expression, 'context.text.labelSmall');
      expect(TypeToken.figure.expression, 'context.type.figure');
    });
  });

  group('TypeRole', () {
    test('shows every text style of the app exactly once', () {
      expect(TypeRole.values.map((role) => role.token).toSet(), TypeToken.values.toSet());
      expect(TypeRole.values, hasLength(TypeToken.values.length));
    });

    test('puts every role in one section', () {
      final listed = [...headingRoles, ...displayRoles, ...textRoles];

      expect(listed.toSet(), TypeRole.values.toSet());
      expect(listed, hasLength(TypeRole.values.length));
      expect(headingRoles, containsAll(classRoles));
    });
  });
}
