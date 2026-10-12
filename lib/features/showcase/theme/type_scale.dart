import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';

/// Every text style of the app: the Material [TextTheme] slots (`context.text`) and the
/// [MarksheetType] styles (`context.type`).
enum TypeToken {
  displayLarge,
  displayMedium,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  figure,
  table,
  formLabel,
  handRemark,
  handNote,
  code;

  bool get _isMaterial => index <= labelSmall.index;

  /// How code reaches the style: `context.text.titleLarge`, `context.type.figure`.
  String get expression => _isMaterial ? 'context.text.$name' : 'context.type.$name';

  /// The style itself.
  TextStyle resolve(TextTheme text, MarksheetType type) =>
      switch (this) {
        displayLarge => text.displayLarge,
        displayMedium => text.displayMedium,
        headlineLarge => text.headlineLarge,
        headlineMedium => text.headlineMedium,
        headlineSmall => text.headlineSmall,
        titleLarge => text.titleLarge,
        titleMedium => text.titleMedium,
        titleSmall => text.titleSmall,
        bodyLarge => text.bodyLarge,
        bodyMedium => text.bodyMedium,
        bodySmall => text.bodySmall,
        labelLarge => text.labelLarge,
        labelMedium => text.labelMedium,
        labelSmall => text.labelSmall,
        figure => type.figure,
        table => type.table,
        formLabel => type.formLabel,
        handRemark => type.handRemark,
        handNote => type.handNote,
        code => type.code,
      } ??
      const TextStyle();
}

/// A role of the type scale (DESIGN.md → Typography) and the style the app sets it in.
enum TypeRole {
  headline(TypeToken.headlineLarge),
  pageTitle(TypeToken.headlineMedium),
  section(TypeToken.headlineSmall),
  title(TypeToken.titleLarge),
  subtitle(TypeToken.titleMedium),
  smallTitle(TypeToken.titleSmall),
  display(TypeToken.displayLarge),
  displaySmall(TypeToken.displayMedium),
  figure(TypeToken.figure),
  lead(TypeToken.bodyLarge),
  body(TypeToken.bodyMedium),
  hint(TypeToken.bodySmall),
  table(TypeToken.table),
  label(TypeToken.formLabel, caps: true),
  button(TypeToken.labelLarge),
  chip(TypeToken.labelMedium),
  badge(TypeToken.labelSmall),
  code(TypeToken.code),
  handRemark(TypeToken.handRemark),
  handNote(TypeToken.handNote);

  const TypeRole(this.token, {this.caps = false});

  final TypeToken token;

  /// The text is upper-cased where it is used (`FormLabel`).
  final bool caps;
}

/// The heading roles, largest first.
const headingRoles = [
  TypeRole.headline,
  TypeRole.pageTitle,
  TypeRole.section,
  TypeRole.title,
  TypeRole.subtitle,
  TypeRole.smallTitle,
];

/// The headings the web page also shows without their element.
const classRoles = [TypeRole.headline, TypeRole.pageTitle, TypeRole.title];

/// The heavy, large roles.
const displayRoles = [TypeRole.display, TypeRole.displaySmall, TypeRole.figure];

/// Running text, labels and the hand.
const textRoles = [
  TypeRole.lead,
  TypeRole.body,
  TypeRole.hint,
  TypeRole.table,
  TypeRole.label,
  TypeRole.button,
  TypeRole.chip,
  TypeRole.badge,
  TypeRole.code,
  TypeRole.handRemark,
  TypeRole.handNote,
];

const _sans = 'LibreFranklin';

/// `28`, `1.25`, `-0.56`: up to three decimals, without trailing zeros.
String _number(double value) => value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

/// The spec of [style], as DESIGN.md writes it: family (when not Libre Franklin), weight,
/// size, line height, tracking, then `tnum` for tabular figures and `caps` when [caps].
///
/// `describeStyle(context.text.headlineMedium!)` is `700 · 28 · 1.25 · -0.56`.
String describeStyle(TextStyle style, {bool caps = false}) {
  final family = style.fontFamily;
  final weight = '${(style.fontWeight ?? FontWeight.w400).value}';
  return [
    if (family != null && family != _sans) '$family $weight' else weight,
    if (style.fontSize case final size?) _number(size),
    if (style.height case final height?) _number(height),
    if (style.letterSpacing case final spacing? when spacing != 0) _number(spacing),
    if (style.fontFeatures?.contains(const FontFeature.tabularFigures()) ?? false) 'tnum',
    if (caps) 'caps',
  ].join(' · ');
}
