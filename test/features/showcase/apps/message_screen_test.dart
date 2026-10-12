import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'apps_test_app.dart';

void main() {
  group('MessageScreen', () {
    testWidgets('shows the message of the id, with its attachments', (tester) async {
      await pumpEmail(tester, '${Routes.appsMessage}?id=m01&folder=inbox');

      expect(find.text('Term report templates are ready'), findsOneWidget);
      expect(find.text('1 of 13'), findsOneWidget);
      expect(find.text('3 ATTACHMENTS'), findsOneWidget);
      expect(find.text('2.5 MB'), findsOneWidget);
      expect(find.text('7 kB'), findsOneWidget);
    });

    testWidgets('shows the newest message of the folder without an id', (tester) async {
      await pumpEmail(tester, '${Routes.appsMessage}?folder=sent');

      expect(find.text('Room change for Year 7'), findsOneWidget);
      expect(find.text('To: amira.haddad@riverside.example'), findsOneWidget);
    });

    testWidgets('walks the folder with next and previous, marking messages read', (tester) async {
      await pumpEmail(tester, '${Routes.appsMessage}?id=m01&folder=inbox');

      await tester.tap(find.byTooltip('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Parents evening schedule'), findsOneWidget);
      expect(find.text('2 of 13'), findsOneWidget);

      await tester.tap(find.byTooltip('Previous'));
      await tester.pumpAndSettle();
      expect(find.text('Term report templates are ready'), findsOneWidget);
    });

    testWidgets('asks for a reply, then files it under Sent', (tester) async {
      await pumpEmail(tester, '${Routes.appsMessage}?id=m02&folder=inbox');

      await tester.ensureVisible(find.text('Send reply'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send reply'));
      await tester.pumpAndSettle();
      expect(find.text('Required'), findsOneWidget);

      await tester.enterText(fieldLabelled('Reply'), 'Looks good.\n\nThanks!');
      await tester.tap(find.text('Send reply'));
      await tester.pumpAndSettle();

      expect(find.text('Reply sent'), findsOneWidget);
      expect(fieldText(tester, 'Reply'), isEmpty);
      final reply = mailboxOf(tester).first;
      expect(
        (reply.box, reply.subject, reply.to),
        (MailBox.sent, 'Re: Parents evening schedule', 'amira.haddad@riverside.example'),
      );
      expect(reply.body, ['Looks good.', 'Thanks!']);
    });

    testWidgets('moves the message to the trash and goes back to the folder', (tester) async {
      final router = await pumpEmail(tester, Routes.appsInbox);
      await tester.tap(find.text('Parents evening schedule'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Message moved to the trash'), findsOneWidget);
      expect(router.state.uri.path, Routes.appsInbox);
      expect(find.text('1–10 of 12'), findsOneWidget);
    });

    testWidgets('says when the message does not exist', (tester) async {
      await pumpEmail(tester, '${Routes.appsMessage}?id=nope&folder=spam');

      expect(find.text('Message not found'), findsOneWidget);
      await tester.tap(find.text('Back to Spam'));
      await tester.pumpAndSettle();

      expect(find.text('You have won a tablet!'), findsOneWidget);
    });

    testWidgets('says an attachment is only a sample', (tester) async {
      await pumpEmail(tester, '${Routes.appsMessage}?id=m01&folder=inbox');

      await tester.ensureVisible(find.text('readme.txt'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Actions for readme.txt'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share readme.txt'));
      await tester.pumpAndSettle();

      expect(
        find.text('readme.txt is a sample attachment: there is no file behind it.'),
        findsOneWidget,
      );
    });
  });
}
