import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_boilerplate/features/showcase/apps/compose_validation.dart';
import 'package:flutter_test/flutter_test.dart';

const valid = {
  ComposeField.to: 'ada@example.com',
  ComposeField.cc: '',
  ComposeField.bcc: '',
  ComposeField.subject: '',
};

void main() {
  group('splitAddresses', () {
    test('splits on commas and semicolons and drops blanks', () {
      expect(splitAddresses(' a@x.org, b@y.org;;c@z.org ,'), ['a@x.org', 'b@y.org', 'c@z.org']);
    });
  });

  group('composeIssues', () {
    test('accepts one recipient and empty optional fields', () {
      expect(composeIssues(valid), isEmpty);
    });

    test('requires a recipient', () {
      expect(composeIssues({...valid, ComposeField.to: '  '}), {
        ComposeField.to: ValidationIssue.required,
      });
    });

    test('rejects a list with one malformed address', () {
      expect(composeIssues({...valid, ComposeField.cc: 'ben@example.com, not-an-address'}), {
        ComposeField.cc: ValidationIssue.invalidEmailList,
      });
    });

    test('accepts several valid recipients', () {
      expect(composeIssues({...valid, ComposeField.to: 'a@x.org; b@y.org'}), isEmpty);
    });

    test('limits the subject to 200 characters', () {
      expect(composeIssues({...valid, ComposeField.subject: 'x' * 201}), {
        ComposeField.subject: ValidationIssue.tooLong,
      });
      expect(composeIssues({...valid, ComposeField.subject: ' ${'x' * 200} '}), isEmpty);
    });
  });
}
