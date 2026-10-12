import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_boilerplate/features/auth/auth_validation.dart';
import 'package:flutter_boilerplate/features/files/files_data.dart';
import 'package:flutter_boilerplate/features/test_results/test_result_validation.dart';
import 'package:flutter_boilerplate/features/users/users_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sign-up rules (the backend RegisterRequest)', () {
    test('accept a valid email and password', () {
      expect(signUpEmail('ada@example.com'), isNull);
      expect(signUpPassword('secret'), isNull);
    });

    test('reject a missing or malformed email', () {
      expect(signUpEmail(''), ValidationIssue.required);
      expect(signUpEmail('ada@'), ValidationIssue.invalidEmail);
      expect(signUpEmail('ada..b@example.com'), ValidationIssue.invalidEmail);
      expect(signUpEmail('${'a' * 250}@example.com'), ValidationIssue.tooLong);
    });

    test('ask for 6 to 72 password characters', () {
      expect(signUpPassword('12345'), ValidationIssue.passwordTooShort);
      expect(signUpPassword('x' * 73), ValidationIssue.passwordTooLong);
    });

    test('sign-in only needs a password to be present', () {
      expect(signInPassword(''), ValidationIssue.required);
      expect(signInPassword('1'), isNull);
    });
  });

  group('test result rules (CreateTestResultRequest)', () {
    test('require a name of at most 100 characters', () {
      expect(testNameRule('  '), ValidationIssue.required);
      expect(testNameRule('x' * 101), ValidationIssue.tooLong);
      expect(testNameRule('Driving theory'), isNull);
    });

    test('accept scores from 0 to 100, with a point or a comma', () {
      expect(scoreRule('0'), isNull);
      expect(scoreRule('72,5'), isNull);
      expect(parseScore('72,5'), 72.5);
      expect(scoreRule('100.01'), ValidationIssue.scoreRange);
      expect(scoreRule('-1'), ValidationIssue.scoreRange);
      expect(scoreRule('abc'), ValidationIssue.invalidNumber);
      expect(scoreRule(''), ValidationIssue.required);
    });

    test('limit notes to 1000 characters', () {
      expect(notesRule('x' * 1001), ValidationIssue.tooLong);
    });
  });

  group('user rules (UpdateUserRequest)', () {
    test('require a valid email', () {
      expect(userEmailRule('admin@example.com'), isNull);
      expect(userEmailRule('nope'), ValidationIssue.invalidEmail);
    });
  });

  group('file checks (the backend file limits)', () {
    test('refuse empty, too large and unknown files', () {
      expect(checkFile(size: 0, contentType: 'text/plain'), FileProblem.empty);
      expect(checkFile(size: maxFileBytes + 1, contentType: 'image/png'), FileProblem.tooLarge);
      expect(checkFile(size: 10, contentType: 'application/zip'), FileProblem.type);
      expect(checkFile(size: 10, contentType: null), FileProblem.type);
    });

    test('accept allowed types up to 10 MB', () {
      expect(checkFile(size: maxFileBytes, contentType: 'application/pdf'), isNull);
    });
  });
}
