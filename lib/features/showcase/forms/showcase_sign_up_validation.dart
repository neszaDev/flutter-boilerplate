import 'package:flutter/foundation.dart';
import 'package:flutter_boilerplate/core/validation/validation.dart';

/// The fields of the validation forms demo, in display order.
enum SignUpField { firstName, lastName, userName, email, password, confirmPassword, accept }

/// The values of the sign-up demo form. It is a showcase, not a backend request.
@immutable
class ShowcaseSignUpValues {
  const ShowcaseSignUpValues({
    this.firstName = '',
    this.lastName = '',
    this.userName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.accept = false,
  });

  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;
  final bool accept;

  /// The text of a text field ([SignUpField.accept] has none).
  String text(SignUpField field) => switch (field) {
    SignUpField.firstName => firstName,
    SignUpField.lastName => lastName,
    SignUpField.userName => userName,
    SignUpField.email => email,
    SignUpField.password => password,
    SignUpField.confirmPassword => confirmPassword,
    SignUpField.accept => '',
  };

  /// A copy with [field] set to [text].
  ShowcaseSignUpValues withText(SignUpField field, String text) => ShowcaseSignUpValues(
    firstName: field == SignUpField.firstName ? text : firstName,
    lastName: field == SignUpField.lastName ? text : lastName,
    userName: field == SignUpField.userName ? text : userName,
    email: field == SignUpField.email ? text : email,
    password: field == SignUpField.password ? text : password,
    confirmPassword: field == SignUpField.confirmPassword ? text : confirmPassword,
    accept: accept,
  );

  ShowcaseSignUpValues withAccept(bool accept) => ShowcaseSignUpValues(
    firstName: firstName,
    lastName: lastName,
    userName: userName,
    email: email,
    password: password,
    confirmPassword: confirmPassword,
    accept: accept,
  );

  /// The values as the web prints them (`JSON.stringify(values)`).
  Map<String, Object> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'userName': userName,
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
    'accept': accept,
  };
}

// `.min(1, 'required')` on the web: an empty string, not a blank one.
final _present = Rules.minLength(1, ValidationIssue.required);

/// The rule of each text field (the web's `ShowcaseSignUpValidation`, the Vue page's vuelidate
/// rules); each reports its first failed check.
final showcaseSignUpRules = <SignUpField, Rule>{
  SignUpField.firstName: Rules.all([_present, Rules.minLength(3, ValidationIssue.min3Characters)]),
  SignUpField.lastName: Rules.all([_present, Rules.minLength(2, ValidationIssue.min2Characters)]),
  SignUpField.userName: Rules.all([_present, Rules.minLength(5, ValidationIssue.min5Characters)]),
  SignUpField.email: Rules.all([
    _present,
    (value) => emailPattern.hasMatch(value) ? null : ValidationIssue.invalidEmail,
  ]),
  SignUpField.password: Rules.all([
    _present,
    Rules.minLength(8, ValidationIssue.min8Characters),
    (value) => strongPasswordPattern.hasMatch(value) ? null : ValidationIssue.strongPassword,
  ]),
  SignUpField.confirmPassword: _present,
};

/// Every rule [values] breaks, one issue per field: the field's own rule first, then the
/// confirmation must match the password and the terms must be accepted.
Map<SignUpField, ValidationIssue> validateShowcaseSignUp(ShowcaseSignUpValues values) {
  final issues = <SignUpField, ValidationIssue>{};
  for (final MapEntry(key: field, value: rule) in showcaseSignUpRules.entries) {
    final issue = rule(values.text(field));
    if (issue != null) {
      issues[field] = issue;
    }
  }
  if (!issues.containsKey(SignUpField.confirmPassword) &&
      values.confirmPassword != values.password) {
    issues[SignUpField.confirmPassword] = ValidationIssue.passwordsMustMatch;
  }
  if (!values.accept) {
    issues[SignUpField.accept] = ValidationIssue.acceptTerms;
  }
  return issues;
}
