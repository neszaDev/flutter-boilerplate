import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox.dart';
import 'package:flutter_test/flutter_test.dart';

final base = Mail(
  id: 'a',
  from: 'Ada',
  email: 'ada@example.com',
  sentAt: DateTime.utc(2026, 1, 2),
  subject: 'Hello',
  body: const ['Hi'],
  read: false,
);
final older = Mail(
  id: 'b',
  from: 'Ada',
  email: 'ada@example.com',
  sentAt: DateTime.utc(2026),
  subject: 'Hello',
  body: const ['Hi'],
);

void main() {
  group('folderCount', () {
    test('counts the four unread inbox messages of the Vue sample', () {
      expect(folderCount(sampleMails, MailFolder.inbox), 4);
    });

    test('counts every draft, read or not', () {
      expect(folderCount([older.copyWith(box: MailBox.drafts)], MailFolder.drafts), 1);
    });
  });

  group('folderMessages', () {
    test('lists a folder newest first', () {
      expect(folderMessages([older, base], MailFolder.inbox).map((m) => m.id), ['a', 'b']);
    });

    test('leaves trashed messages out of the starred folder', () {
      final trashed = base.copyWith(starred: true, box: MailBox.trash);

      expect(folderMessages([trashed], MailFolder.starred), isEmpty);
    });

    test('lists the 13 inbox messages of the sample', () {
      expect(folderMessages(sampleMails, MailFolder.inbox), hasLength(13));
    });
  });

  group('labelMessages', () {
    test('lists the messages carrying a label, outside trash and spam', () {
      final spam = base.copyWith(labels: [MailLabel.job], box: MailBox.spam);
      final job = older.copyWith(labels: [MailLabel.job]);

      expect(labelMessages([spam, job], MailLabel.job).map((m) => m.id), ['b']);
    });
  });

  group('applyMailAction', () {
    test('marks only the selected messages as read', () {
      final result = applyMailAction([base, older], ['a'], const MarkRead(true));

      expect(result.map((m) => m.read), [true, true]);
    });

    test('adds a label once and removes it again', () {
      final added = applyMailAction([base], ['a'], const SetLabel(MailLabel.job, value: true));
      final again = applyMailAction(added, ['a'], const SetLabel(MailLabel.job, value: true));
      final removed = applyMailAction(again, ['a'], const SetLabel(MailLabel.job, value: false));

      expect(again.first.labels, [MailLabel.job]);
      expect(removed.first.labels, isEmpty);
    });

    test('moves to the trash, then deletes from the trash for good', () {
      final trashed = applyMailAction([base], ['a'], const MoveTo(MailBox.trash));

      expect(trashed.first.box, MailBox.trash);
      expect(applyMailAction(trashed, ['a'], const MoveTo(MailBox.trash)), isEmpty);
    });

    test('deletes the selected messages', () {
      expect(applyMailAction([base, older], ['b'], const DeleteMail()).map((m) => m.id), ['a']);
    });
  });

  group('toFolder', () {
    test('falls back to the inbox for unknown folders', () {
      expect(toFolder('starred'), MailFolder.starred);
      expect(toFolder('nope'), MailFolder.inbox);
      expect(toFolder(null), MailFolder.inbox);
    });
  });

  group('toLabel', () {
    test('knows the four labels only', () {
      expect(toLabel('news'), MailLabel.news);
      expect(toLabel('work'), isNull);
    });
  });

  group('composeLocation', () {
    test('encodes the prefilled recipient and subject', () {
      expect(
        composeLocation(to: 'ada@example.com', subject: 'Re: A & B'),
        '${Routes.appsCompose}?to=ada%40example.com&subject=Re%3A+A+%26+B',
      );
    });

    test('links to an empty form without prefill', () {
      expect(composeLocation(), Routes.appsCompose);
    });
  });

  group('messageLocation', () {
    test('carries the message and its folder', () {
      expect(
        messageLocation('m01', MailFolder.starred),
        '${Routes.appsMessage}?id=m01&folder=starred',
      );
    });
  });

  group('outgoingMail', () {
    test('splits the text into paragraphs at blank lines', () {
      final message = outgoingMail(
        id: 'x',
        sentAt: DateTime.utc(2026),
        to: 'ada@example.com',
        subject: 'Hi',
        text: 'First line\nsame paragraph\n\n  Second  \n\n\n',
        box: MailBox.sent,
      );

      expect(message.body, ['First line\nsame paragraph', 'Second']);
      expect(message.box, MailBox.sent);
      expect(message.from, me.name);
    });
  });

  group('mailPage', () {
    final thirteen = folderMessages(sampleMails, MailFolder.inbox);

    test('shows ten rows per page', () {
      final first = mailPage(thirteen, 0);

      expect((first.from, first.to, first.total, first.pages), (1, 10, 13, 2));
      expect(first.rows, hasLength(10));
    });

    test('keeps the page within range', () {
      final last = mailPage(thirteen, 5);

      expect((last.page, last.from, last.to), (1, 11, 13));
    });

    test('has one empty page for an empty folder', () {
      final empty = mailPage(const [], 0);

      expect((empty.from, empty.to, empty.total, empty.pages), (0, 0, 0, 1));
    });
  });

  group('sharedLabels', () {
    test('keeps the labels every message carries', () {
      final both = base.copyWith(labels: [MailLabel.job, MailLabel.news]);
      final one = older.copyWith(labels: [MailLabel.job]);

      expect(sharedLabels([both, one]), {MailLabel.job});
      expect(sharedLabels(const []), isEmpty);
    });
  });

  group('attachmentOf', () {
    test('takes the type from the extension and rounds to kilobytes', () {
      expect(
        attachmentOf('notes.final.pdf', 3000),
        const MailAttachment(name: 'notes.final.pdf', kind: 'pdf', sizeKb: 3),
      );
      expect(attachmentOf('README', 10).kind, 'file');
      expect(attachmentOf('README', 10).sizeKb, 1);
    });
  });
}
