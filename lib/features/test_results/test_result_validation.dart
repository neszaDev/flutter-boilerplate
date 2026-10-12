import 'package:flutter_boilerplate/core/validation/validation.dart';

// Mirrors the backend's CreateTestResultRequest (and the web app's TestResultValidation.ts).

final testNameRule = Rules.all([Rules.required, Rules.maxLength(100)]);

final notesRule = Rules.maxLength(1000);

/// A score from 0 to 100; decimals with a point or a comma ("72,5" on a French keyboard).
ValidationIssue? scoreRule(String value) {
  final score = parseScore(value);
  if (value.trim().isEmpty) {
    return ValidationIssue.required;
  }
  if (score == null) {
    return ValidationIssue.invalidNumber;
  }
  return score < 0 || score > 100 ? ValidationIssue.scoreRange : null;
}

double? parseScore(String value) => double.tryParse(value.trim().replaceAll(',', '.'));
