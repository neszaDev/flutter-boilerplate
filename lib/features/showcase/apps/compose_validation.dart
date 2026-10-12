import 'package:flutter_boilerplate/core/validation/validation.dart';

/// The fields of the compose form.
enum ComposeField { to, cc, bcc, subject }

/// Splits a recipients field (`a@x.org, b@y.org; c@z.org`) into trimmed, non-empty addresses.
List<String> splitAddresses(String value) => value
    .split(RegExp('[,;]'))
    .map((part) => part.trim())
    .where((part) => part.isNotEmpty)
    .toList();

/// Every address of the list is valid (an empty list is fine).
ValidationIssue? addressListRule(String value) =>
    splitAddresses(value).every((part) => Rules.email(part) == null)
    ? null
    : ValidationIssue.invalidEmailList;

/// To: at least one address, all valid.
ValidationIssue? recipientsRule(String value) =>
    addressListRule(value) ?? (value.trim().isEmpty ? ValidationIssue.required : null);

/// Subject: optional, at most 200 characters once trimmed.
ValidationIssue? subjectRule(String value) => Rules.maxLength(200)(value.trim());

/// The rule of each field (the web's `ComposeValidation`).
Rule composeRule(ComposeField field) => switch (field) {
  ComposeField.to => recipientsRule,
  ComposeField.cc || ComposeField.bcc => addressListRule,
  ComposeField.subject => subjectRule,
};

/// The issues of a whole form, by field; empty when it can be sent.
Map<ComposeField, ValidationIssue> composeIssues(Map<ComposeField, String> values) => {
  for (final field in ComposeField.values) field: ?composeRule(field)(values[field] ?? ''),
};
