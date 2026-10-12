import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/validation/validation.dart';

// The web app's TwoFactorValidation.ts and TwoFactorActions.ts.
//
// The Spring API has no 2FA endpoints yet (planned: POST /api/v1/auth/2fa/send and
// /api/v1/auth/2fa/verify, see the web app's docs/plans/0003-vue-ui-port.md). Until then both
// steps say so instead of pretending to send or verify anything.

/// Number of characters in a two-factor code (letters and digits).
const twoFactorCodeLength = 6;

// The Vue 2FA step accepted a-z, A-Z and 0-9 only.
final _codePattern = RegExp('^[a-zA-Z0-9]{$twoFactorCodeLength}\$');

/// The trimmed code when it is well-formed, else null.
String? parseTwoFactorCode(String value) {
  final code = value.trim();
  return _codePattern.hasMatch(code) ? code : null;
}

/// The validation rule of the code field.
ValidationIssue? twoFactorCodeRule(String value) =>
    parseTwoFactorCode(value) == null ? ValidationIssue.twoFactorCode : null;

/// Why a two-factor step failed, and the code the error dialog prints (`#1-<code>`).
enum TwoFactorFailureReason {
  invalidCode('42200'),
  unavailable('50100');

  const TwoFactorFailureReason(this.code);

  final String code;
}

/// Decides how a verify request ends. With no 2FA endpoint on the backend, a well-formed code is
/// reported as "unavailable", never as verified.
TwoFactorFailureReason twoFactorOutcome(String? code) =>
    code != null && parseTwoFactorCode(code) != null
    ? TwoFactorFailureReason.unavailable
    : TwoFactorFailureReason.invalidCode;

/// Result of a two-factor step.
sealed class TwoFactorResult {
  const TwoFactorResult();
}

/// The code was accepted. Not produced until the backend can verify codes.
class TwoFactorVerified extends TwoFactorResult {
  const TwoFactorVerified();
}

/// A failed step, with the code the error dialog prints.
class TwoFactorFailure extends TwoFactorResult {
  const TwoFactorFailure(this.reason);

  final TwoFactorFailureReason reason;

  String get code => reason.code;

  String message(AppLocalizations l10n) => switch (reason) {
    TwoFactorFailureReason.invalidCode => ValidationIssue.twoFactorCode.message(l10n),
    TwoFactorFailureReason.unavailable => l10n.twoFactorActionsErrorUnavailable,
  };
}

/// Asks the backend to send a new code to the signed-in user's email: always "not available
/// yet" until the backend serves the endpoint.
Future<TwoFactorResult> sendTwoFactorCode() async {
  await Future<void>.delayed(Duration.zero);
  return const TwoFactorFailure(TwoFactorFailureReason.unavailable);
}

/// Checks a code: its shape first, then (one day) the backend. An invalid-code failure, or
/// "not available yet" for a well-formed code.
Future<TwoFactorResult> verifyTwoFactorCode(String code) async {
  await Future<void>.delayed(Duration.zero);
  return TwoFactorFailure(twoFactorOutcome(code));
}
