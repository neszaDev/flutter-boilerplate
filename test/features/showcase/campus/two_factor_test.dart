import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_boilerplate/features/showcase/campus/two_factor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('two-factor code rules', () {
    test('accepts six letters and digits', () {
      expect(twoFactorCodeRule('aB3dE9'), isNull);
    });

    test('trims the code before checking it', () {
      expect(parseTwoFactorCode(' 123456 '), '123456');
      expect(twoFactorCodeRule(' 123456 '), isNull);
    });

    test('rejects codes of the wrong length or with symbols with the Validation message', () {
      for (final code in ['12345', '1234567', '12345!', 'ก12345', '']) {
        expect(twoFactorCodeRule(code), ValidationIssue.twoFactorCode, reason: code);
      }
    });
  });

  group('twoFactorOutcome', () {
    test('rejects a malformed code before any backend call', () {
      expect(twoFactorOutcome('12-45'), TwoFactorFailureReason.invalidCode);
      expect(twoFactorOutcome(null), TwoFactorFailureReason.invalidCode);
    });

    test('reports a well-formed code as not verifiable yet instead of accepting it', () {
      expect(twoFactorOutcome('A1b2C3'), TwoFactorFailureReason.unavailable);
    });

    test('gives each failure the code the error dialog prints', () {
      expect(TwoFactorFailureReason.invalidCode.code, '42200');
      expect(TwoFactorFailureReason.unavailable.code, '50100');
    });
  });

  group('two-factor steps', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    test('verify never succeeds while the backend has no 2FA endpoint', () async {
      final result = await verifyTwoFactorCode('A1b2C3');

      expect(result, isA<TwoFactorFailure>());
      final failure = result as TwoFactorFailure;
      expect(failure.code, '50100');
      expect(failure.message(l10n), l10n.twoFactorActionsErrorUnavailable);
    });

    test('verify reports a malformed code with the Validation message', () async {
      final failure = await verifyTwoFactorCode('12-45') as TwoFactorFailure;

      expect(failure.reason, TwoFactorFailureReason.invalidCode);
      expect(failure.code, '42200');
      expect(failure.message(l10n), l10n.validationTwoFactorCode);
    });

    test('sending a new code says it is not available yet', () async {
      final failure = await sendTwoFactorCode() as TwoFactorFailure;

      expect(failure.reason, TwoFactorFailureReason.unavailable);
    });
  });
}
