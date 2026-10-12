import 'package:flutter_boilerplate/core/validation/validation.dart';

// Limits mirror the backend's LoginRequest / RegisterRequest (and the web app's
// AuthValidation.ts), so users get the same answer before the round trip.

final signInEmail = Rules.all([Rules.required, Rules.email]);

final signInPassword = Rules.all([(value) => value.isEmpty ? ValidationIssue.required : null]);

final signUpEmail = Rules.all([Rules.required, Rules.email, Rules.maxLength(254)]);

final signUpPassword = Rules.all([
  Rules.minLength(6, ValidationIssue.passwordTooShort),
  Rules.maxLength(72, ValidationIssue.passwordTooLong),
]);
