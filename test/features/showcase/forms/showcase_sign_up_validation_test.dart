import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_boilerplate/features/showcase/forms/showcase_sign_up_validation.dart';
import 'package:flutter_test/flutter_test.dart';

const _valid = ShowcaseSignUpValues(
  firstName: 'Ada',
  lastName: 'Li',
  userName: 'adali',
  email: 'ada@example.com',
  password: 'Report1card',
  confirmPassword: 'Report1card',
  accept: true,
);

ValidationIssue? _issueFor(ShowcaseSignUpValues values, SignUpField field) =>
    validateShowcaseSignUp(values)[field];

void main() {
  group('Showcase sign-up rules', () {
    test('accept a form that meets every rule', () {
      expect(validateShowcaseSignUp(_valid), isEmpty);
    });

    group('length rules', () {
      test('report an empty field as required before its minimum length', () {
        expect(
          _issueFor(_valid.withText(SignUpField.firstName, ''), SignUpField.firstName),
          ValidationIssue.required,
        );
        expect(
          _issueFor(_valid.withText(SignUpField.firstName, 'Al'), SignUpField.firstName),
          ValidationIssue.min3Characters,
        );
        expect(
          _issueFor(_valid.withText(SignUpField.lastName, 'L'), SignUpField.lastName),
          ValidationIssue.min2Characters,
        );
        expect(
          _issueFor(_valid.withText(SignUpField.userName, 'ada'), SignUpField.userName),
          ValidationIssue.min5Characters,
        );
      });
    });

    group('email rule', () {
      test('rejects an address without a domain', () {
        expect(
          _issueFor(_valid.withText(SignUpField.email, 'ada@'), SignUpField.email),
          ValidationIssue.invalidEmail,
        );
        expect(
          _issueFor(_valid.withText(SignUpField.email, ''), SignUpField.email),
          ValidationIssue.required,
        );
      });
    });

    group('password rules', () {
      test('ask for 8 characters, then for a digit and both letter cases', () {
        expect(
          _issueFor(_valid.withText(SignUpField.password, 'Ab1'), SignUpField.password),
          ValidationIssue.min8Characters,
        );
        expect(
          _issueFor(_valid.withText(SignUpField.password, 'reportcard1'), SignUpField.password),
          ValidationIssue.strongPassword,
        );
      });

      test('require the confirmation to match the password', () {
        expect(
          _issueFor(
            _valid.withText(SignUpField.confirmPassword, 'Report1cards'),
            SignUpField.confirmPassword,
          ),
          ValidationIssue.passwordsMustMatch,
        );
        expect(
          _issueFor(_valid.withText(SignUpField.confirmPassword, ''), SignUpField.confirmPassword),
          ValidationIssue.required,
        );
      });
    });

    group('terms', () {
      test('reject a form whose terms are not accepted', () {
        expect(
          _issueFor(_valid.withAccept(false), SignUpField.accept),
          ValidationIssue.acceptTerms,
        );
      });
    });

    group('values', () {
      test('print every field under the web names', () {
        expect(_valid.toJson().keys, [
          'firstName',
          'lastName',
          'userName',
          'email',
          'password',
          'confirmPassword',
          'accept',
        ]);
      });
    });
  });
}
