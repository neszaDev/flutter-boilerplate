import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'apps_test_app.dart';

Future<void> _select(WidgetTester tester, String subject) async {
  await tester.tap(checkboxLabelled('Select “$subject”'));
  await tester.pumpAndSettle();
}

void main() {
  group('InboxScreen', () {
    testWidgets('shows the unread count and the first page range', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpEmail(tester, Routes.appsInbox);

      expect(find.bySemanticsLabel(RegExp(r'\b4 unread')), findsOneWidget);
      expect(find.text('1–10 of 13'), findsOneWidget);
      expect(find.text('Term report templates are ready'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('marks the selected message as read, which lowers the unread count', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpEmail(tester, Routes.appsInbox);

      await _select(tester, 'Term report templates are ready');
      expect(find.text('1 selected'), findsOneWidget);
      await tester.tap(find.byTooltip('Mark as read'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear selection'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp(r'\b3 unread')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('opens compose with the reply prefilled', (tester) async {
      await pumpEmail(tester, Routes.appsInbox);

      await _select(tester, 'Sports day volunteers');
      await tester.tap(find.byTooltip('Message actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();

      expect(fieldText(tester, 'Subject'), 'Re: Sports day volunteers');
      expect(fieldText(tester, 'To'), 'mei.tanaka@riverside.example');
    });

    testWidgets('archives the selected messages out of the inbox', (tester) async {
      await pumpEmail(tester, Routes.appsInbox);

      await tester.tap(checkboxLabelled('Select all messages on this page'));
      await tester.pumpAndSettle();
      expect(find.text('10 selected'), findsOneWidget);
      await tester.tap(find.byTooltip('Archive'));
      await tester.pumpAndSettle();

      expect(find.text('1–3 of 3'), findsOneWidget);
      expect(find.text('10 messages archived'), findsOneWidget);
    });

    testWidgets('archives a message swiped right and trashes one swiped left', (tester) async {
      await pumpEmail(tester, Routes.appsInbox);

      await tester.drag(find.text('Parents evening schedule'), const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Message archived'), findsOneWidget);
      expect(find.text('1–10 of 12'), findsOneWidget);

      await tester.drag(find.text('Science lab booking for Year 9'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Message moved to the trash'), findsOneWidget);
      expect(find.text('1–10 of 11'), findsOneWidget);
      final boxes = {for (final mail in mailboxOf(tester)) mail.id: mail.box};
      expect((boxes['m02'], boxes['m03']), (MailBox.archive, MailBox.trash));
    });

    testWidgets('keeps a swiped message listed while it still belongs to the folder', (
      tester,
    ) async {
      await pumpEmail(tester, '${Routes.appsInbox}?folder=starred');

      await tester.drag(find.text('Science lab booking for Year 9'), const Offset(500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Science lab booking for Year 9'), findsOneWidget);
      expect(find.text('Message archived'), findsOneWidget);
    });

    testWidgets('pages through the folder', (tester) async {
      await pumpEmail(tester, Routes.appsInbox);

      await tester.tap(find.byTooltip('Next'));
      await tester.pumpAndSettle();

      expect(find.text('11–13 of 13'), findsOneWidget);
      expect(find.text('Thank you'), findsOneWidget);
    });

    testWidgets('stars a message from its row', (tester) async {
      await pumpEmail(tester, Routes.appsInbox);

      await tester.tap(find.byTooltip('Star “Parents evening schedule”'));
      await tester.pumpAndSettle();

      final star = tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip('Star “Parents evening schedule”'),
          matching: find.byType(IconButton),
        ),
      );
      expect(star.isSelected, isTrue);
    });

    testWidgets('switches folders and labels from the app bar menu', (tester) async {
      await pumpEmail(tester, Routes.appsInbox);

      await tester.tap(find.byTooltip('Mail folders'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sent').last);
      await tester.pumpAndSettle();
      expect(find.text('To: amira.haddad@riverside.example'), findsOneWidget);

      await tester.tap(find.byTooltip('Mail folders'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('News').last);
      await tester.pumpAndSettle();
      expect(find.text('Sports day volunteers'), findsOneWidget);
      expect(find.text('1–1 of 1'), findsOneWidget);
    });

    testWidgets('opens a folder from the query and says when it is empty', (tester) async {
      await pumpEmail(tester, '${Routes.appsInbox}?folder=drafts');

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Drafts has no messages.'), findsOneWidget);
    });

    testWidgets('opens a message and marks it as read', (tester) async {
      await pumpEmail(tester, Routes.appsInbox);

      await tester.tap(find.text('Missing marks for the history mock'));
      await tester.pumpAndSettle();

      expect(find.text('Message'), findsOneWidget);
      expect(find.text('grace.okafor@riverside.example'), findsOneWidget);
      expect(mailboxOf(tester).firstWhere((mail) => mail.id == 'm04').read, isTrue);
    });

    testWidgets('reads well in the dark theme', (tester) async {
      await pumpEmail(tester, Routes.appsInbox, theme: AppTheme.dark());

      expect(find.text('1–10 of 13'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
