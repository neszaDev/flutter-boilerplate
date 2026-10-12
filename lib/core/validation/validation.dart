import 'package:flutter_boilerplate/core/l10n/l10n.dart';

/// Why a value was rejected. Each one is a message in the `Validation` namespace, the same keys
/// the web app's zod schemas use, so both apps answer the same way.
enum ValidationIssue {
  required,
  invalidEmail,
  tooLong,
  passwordTooShort,
  passwordTooLong,
  invalidNumber,
  scoreRange,
  invalidDate,
  min2Characters,
  min3Characters,
  min5Characters,
  min8Characters,
  strongPassword,
  passwordsMustMatch,
  acceptTerms,
  invalidEmailList,
  twoFactorCode;

  String message(AppLocalizations l10n) => switch (this) {
    required => l10n.validationRequired,
    invalidEmail => l10n.validationInvalidEmail,
    tooLong => l10n.validationTooLong,
    passwordTooShort => l10n.validationPasswordTooShort,
    passwordTooLong => l10n.validationPasswordTooLong,
    invalidNumber => l10n.validationInvalidNumber,
    scoreRange => l10n.validationScoreRange,
    invalidDate => l10n.validationInvalidDate,
    min2Characters => l10n.validationMin2Characters,
    min3Characters => l10n.validationMin3Characters,
    min5Characters => l10n.validationMin5Characters,
    min8Characters => l10n.validationMin8Characters,
    strongPassword => l10n.validationStrongPassword,
    passwordsMustMatch => l10n.validationPasswordsMustMatch,
    acceptTerms => l10n.validationAcceptTerms,
    invalidEmailList => l10n.validationInvalidEmailList,
    twoFactorCode => l10n.validationTwoFactorCode,
  };
}

/// A rule for one field: null when the value is fine.
typedef Rule = ValidationIssue? Function(String value);

/// The same pattern as zod's `z.email()`.
final emailPattern = RegExp(
  r"^(?!\.)(?!.*\.\.)([A-Za-z0-9_'+\-\.]*)[A-Za-z0-9_+-]@([A-Za-z0-9][A-Za-z0-9\-]*\.)+[A-Za-z]{2,}$",
);

/// At least one digit, one lowercase and one uppercase letter, and 8 characters.
final strongPasswordPattern = RegExp(r'(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}');

abstract final class Rules {
  static ValidationIssue? required(String value) =>
      value.trim().isEmpty ? ValidationIssue.required : null;

  static ValidationIssue? email(String value) =>
      emailPattern.hasMatch(value.trim()) ? null : ValidationIssue.invalidEmail;

  static Rule maxLength(int max, [ValidationIssue issue = ValidationIssue.tooLong]) =>
      (value) => value.length > max ? issue : null;

  static Rule minLength(int min, ValidationIssue issue) =>
      (value) => value.length < min ? issue : null;

  /// The first issue of [rules], in order (like zod reporting the first failed check).
  static Rule all(List<Rule> rules) => (value) {
    for (final rule in rules) {
      final issue = rule(value);
      if (issue != null) {
        return issue;
      }
    }
    return null;
  };
}

/// Adapts a [Rule] to `TextFormField.validator`, translated.
String? Function(String?) validator(AppLocalizations l10n, Rule rule) =>
    (value) => rule(value ?? '')?.message(l10n);
