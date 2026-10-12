import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import 'apps_test_app.dart';

Future<void> _tapButton(WidgetTester tester, String key) async {
  // Let a focused field finish scrolling its caret into view first.
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

void main() {
  group('ComposeScreen', () {
    testWidgets('asks for a recipient before sending', (tester) async {
      await pumpEmail(tester, Routes.appsCompose);

      await _tapButton(tester, 'compose.send');

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('rejects a malformed address in Cc', (tester) async {
      await pumpEmail(tester, Routes.appsCompose);

      await tester.enterText(fieldLabelled('To'), 'ada@example.com');
      await tester.enterText(fieldLabelled('Cc'), 'not-an-address');
      await _tapButton(tester, 'compose.send');

      expect(find.text('Enter valid email addresses, separated by commas'), findsOneWidget);
    });

    testWidgets('starts prefilled for a reply and clears the form once sent', (tester) async {
      await pumpEmail(tester, composeLocation(to: 'ada@example.com', subject: 'Re: Hello'));

      expect(fieldText(tester, 'To'), 'ada@example.com');
      expect(fieldText(tester, 'Subject'), 'Re: Hello');

      await _tapButton(tester, 'compose.send');

      expect(find.text('Message sent'), findsOneWidget);
      expect(fieldText(tester, 'Subject'), isEmpty);
      expect(fieldText(tester, 'To'), isEmpty);
      final sent = mailboxOf(tester).first;
      expect((sent.box, sent.subject, sent.to), (MailBox.sent, 'Re: Hello', 'ada@example.com'));
    });

    testWidgets('formats the message body from the toolbar', (tester) async {
      await pumpEmail(tester, Routes.appsCompose);

      await tester.tap(find.byType(QuillEditor));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Bold'));
      await tester.pumpAndSettle();

      final bold = tester.widget<IconButton>(find.byKey(const Key('compose.bold')));
      expect(bold.isSelected, isTrue);
      // Indenting needs a list.
      expect(tester.widget<IconButton>(find.byKey(const Key('compose.indent'))).onPressed, isNull);

      await tester.tap(find.byTooltip('Bulleted list'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<IconButton>(find.byKey(const Key('compose.indent'))).onPressed,
        isNotNull,
      );
    });

    testWidgets('saves a draft with its labels, without a recipient', (tester) async {
      await pumpEmail(tester, Routes.appsCompose);

      await tester.enterText(fieldLabelled('Subject'), '  Trip notes  ');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Labels'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Labels'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.ancestor(
          of: find.text('Add label Job'),
          matching: find.byType(CheckedPopupMenuItem<MailLabel>),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('JOB'), findsOneWidget);

      await _tapButton(tester, 'compose.draft');

      expect(find.text('Draft saved'), findsOneWidget);
      expect(find.text('JOB'), findsNothing);
      final draft = mailboxOf(tester).first;
      expect((draft.box, draft.subject, draft.to), (MailBox.drafts, 'Trip notes', ''));
      expect(draft.labels, [MailLabel.job]);
    });

    testWidgets('discards the message', (tester) async {
      await pumpEmail(tester, Routes.appsCompose);
      final before = mailboxOf(tester).length;

      await tester.enterText(fieldLabelled('To'), 'ada@example.com');
      await _tapButton(tester, 'compose.discard');

      expect(find.text('Message discarded'), findsOneWidget);
      expect(fieldText(tester, 'To'), isEmpty);
      expect(mailboxOf(tester), hasLength(before));
    });
  });
}
