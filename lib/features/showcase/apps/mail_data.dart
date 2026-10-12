import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The folders of the mail menu, in the Vue order (Drafts and Archive added).
enum MailFolder {
  inbox(LucideIcons.inbox),
  starred(LucideIcons.star),
  sent(LucideIcons.send),
  drafts(LucideIcons.fileText),
  archive(LucideIcons.archive),
  trash(LucideIcons.trash2),
  important(LucideIcons.bookmark),
  spam(LucideIcons.shieldAlert);

  const MailFolder(this.icon);

  final IconData icon;
}

/// Where a message is stored; starred and important are flags shown as folders.
enum MailBox { inbox, sent, drafts, archive, trash, spam }

/// The labels of the Vue label dropdown.
enum MailLabel {
  home,
  job,
  clients,
  news;

  /// The label's dot, in Marksheet tokens (the red pen stays for errors).
  Color color(MarksheetColors colors) => switch (this) {
    home => colors.primary,
    job => colors.ink700,
    clients => colors.pass,
    news => colors.pencil,
  };
}

/// A file attached to a message.
@immutable
class MailAttachment {
  const MailAttachment({required this.name, required this.kind, required this.sizeKb});

  final String name;

  /// File type shown as a tag, e.g. `zip`.
  final String kind;

  /// Size in kilobytes.
  final int sizeKb;

  @override
  bool operator ==(Object other) =>
      other is MailAttachment && other.name == name && other.kind == kind && other.sizeKb == sizeKb;

  @override
  int get hashCode => Object.hash(name, kind, sizeKb);
}

/// A message of the sample mailbox.
@immutable
class Mail {
  const Mail({
    required this.id,
    required this.from,
    required this.email,
    required this.sentAt,
    required this.subject,
    required this.body,
    this.to,
    this.quote,
    this.read = true,
    this.starred = false,
    this.important = false,
    this.box = MailBox.inbox,
    this.labels = const [],
    this.attachments = const [],
  });

  final String id;
  final String from;
  final String email;

  /// Recipients, for sent messages and drafts.
  final String? to;
  final DateTime sentAt;
  final String subject;

  /// Body paragraphs; the first is the list preview.
  final List<String> body;

  /// A quoted passage under the body, as in the Vue message.
  final String? quote;
  final bool read;
  final bool starred;
  final bool important;
  final MailBox box;
  final List<MailLabel> labels;
  final List<MailAttachment> attachments;

  /// Written here: listed with its recipient instead of its sender.
  bool get outgoing => box == MailBox.sent || box == MailBox.drafts;

  Mail copyWith({
    bool? read,
    bool? starred,
    bool? important,
    MailBox? box,
    List<MailLabel>? labels,
  }) => Mail(
    id: id,
    from: from,
    email: email,
    to: to,
    sentAt: sentAt,
    subject: subject,
    body: body,
    quote: quote,
    read: read ?? this.read,
    starred: starred ?? this.starred,
    important: important ?? this.important,
    box: box ?? this.box,
    labels: labels ?? this.labels,
    attachments: attachments,
  );
}

/// The signed-in mailbox owner, sender of sent messages and drafts.
const me = (name: 'Jordan Ellis', email: 'jordan.ellis@riverside.example');

/// The sample mailbox: the 13 inbox rows of the Vue app (4 unread) plus a few other folders.
final sampleMails = <Mail>[
  Mail(
    id: 'm01',
    from: 'Lukas Holder',
    email: 'lukas.holder@northgate.example',
    sentAt: DateTime.utc(2026, 10, 2, 15, 47),
    subject: 'Term report templates are ready',
    body: const [
      'The new report card templates are ready for review. Each subject now has its own remark '
          'field and the totals strip prints on the first page.',
      'Could you check the French version before Friday? The layout should be the same, but '
          'some labels run longer.',
    ],
    quote:
        'Please keep the double rule under every header band; the printer at the main office '
        'cuts close to the margins.',
    read: false,
    important: true,
    labels: const [MailLabel.job],
    attachments: const [
      MailAttachment(name: 'report-templates.zip', kind: 'zip', sizeKb: 2560),
      MailAttachment(name: 'readme.txt', kind: 'txt', sizeKb: 7),
      MailAttachment(name: 'class-lists.xls', kind: 'xls', sizeKb: 984),
    ],
  ),
  Mail(
    id: 'm02',
    from: 'Amira Haddad',
    email: 'amira.haddad@riverside.example',
    sentAt: DateTime.utc(2026, 10, 2, 11, 20),
    subject: 'Parents evening schedule',
    body: const [
      'Here is the draft schedule for parents evening. Slots are ten minutes, with a short '
          'break every hour.',
    ],
  ),
  Mail(
    id: 'm03',
    from: 'Tomás Ferreira',
    email: 'tomas.ferreira@riverside.example',
    sentAt: DateTime.utc(2026, 10, 1, 16, 5),
    subject: 'Science lab booking for Year 9',
    body: const [
      'Lab 2 is free on Tuesday afternoons for the rest of term. Shall I book it for Year 9?',
    ],
    starred: true,
  ),
  Mail(
    id: 'm04',
    from: 'Grace Okafor',
    email: 'grace.okafor@riverside.example',
    sentAt: DateTime.utc(2026, 10, 1, 9, 12),
    subject: 'Missing marks for the history mock',
    body: const [
      'Three pupils still have no mark for the history mock exam. Could you add them before '
          'the report run tonight?',
    ],
    read: false,
    important: true,
  ),
  Mail(
    id: 'm05',
    from: 'Henrik Larsen',
    email: 'henrik.larsen@northgate.example',
    sentAt: DateTime.utc(2026, 9, 30, 14, 30),
    subject: 'Invoice 90-98792',
    body: const ['Please find attached the invoice for the extended licence and the support plan.'],
    labels: const [MailLabel.clients],
  ),
  Mail(
    id: 'm06',
    from: 'Mei Tanaka',
    email: 'mei.tanaka@riverside.example',
    sentAt: DateTime.utc(2026, 9, 30, 8, 45),
    subject: 'Sports day volunteers',
    body: const [
      'We still need four volunteers for sports day. Reply to this message if you can help.',
    ],
    read: false,
    labels: const [MailLabel.news],
  ),
  Mail(
    id: 'm07',
    from: 'Daniel Brooks',
    email: 'daniel.brooks@riverside.example',
    sentAt: DateTime.utc(2026, 9, 29, 17, 10),
    subject: 'Re: Reading list for autumn',
    body: const ['Thanks for the list. I swapped two titles that the library does not stock.'],
  ),
  Mail(
    id: 'm08',
    from: 'Sofia Rossi',
    email: 'sofia.rossi@riverside.example',
    sentAt: DateTime.utc(2026, 9, 29, 10),
    subject: 'Staff meeting moved to Thursday',
    body: const ['The staff meeting moves to Thursday at 4 pm in the library.'],
    important: true,
  ),
  Mail(
    id: 'm09',
    from: 'Kwame Mensah',
    email: 'kwame.mensah@riverside.example',
    sentAt: DateTime.utc(2026, 9, 28, 13, 25),
    subject: 'Maths set changes',
    body: const ['Two pupils move from set 2 to set 1 after the September assessment.'],
  ),
  Mail(
    id: 'm10',
    from: 'Laura Novak',
    email: 'laura.novak@home.example',
    sentAt: DateTime.utc(2026, 9, 27, 19, 40),
    subject: 'Dinner on Saturday?',
    body: const ['Are you free on Saturday evening? We are trying the new place by the river.'],
    labels: const [MailLabel.home],
  ),
  Mail(
    id: 'm11',
    from: 'Priya Nair',
    email: 'priya.nair@riverside.example',
    sentAt: DateTime.utc(2026, 9, 26, 12, 15),
    subject: 'Exam board deadlines',
    body: const ['A reminder that entries for the winter series close on the 15th.'],
    important: true,
  ),
  Mail(
    id: 'm12',
    from: 'Oliver Grant',
    email: 'oliver.grant@riverside.example',
    sentAt: DateTime.utc(2026, 9, 25, 9, 30),
    subject: 'Trip consent forms',
    body: const ['Twelve consent forms are still missing for the museum trip next week.'],
    read: false,
  ),
  Mail(
    id: 'm13',
    from: 'Elena Petrova',
    email: 'elena.petrova@riverside.example',
    sentAt: DateTime.utc(2026, 9, 24, 15, 55),
    subject: 'Thank you',
    body: const ['Thank you for covering my class on Monday. The pupils enjoyed the quiz.'],
    starred: true,
    important: true,
  ),
  Mail(
    id: 'm14',
    from: me.name,
    email: me.email,
    to: 'amira.haddad@riverside.example',
    sentAt: DateTime.utc(2026, 9, 23, 10, 5),
    subject: 'Room change for Year 7',
    body: const ['Year 7 English moves to room 12 from next week.'],
    box: MailBox.sent,
  ),
  Mail(
    id: 'm15',
    from: 'Prize Desk',
    email: 'winner@prizes.example',
    sentAt: DateTime.utc(2026, 9, 22, 3, 12),
    subject: 'You have won a tablet!',
    body: const ['Claim your prize now by entering your card details.'],
    read: false,
    box: MailBox.spam,
  ),
  Mail(
    id: 'm16',
    from: 'Library',
    email: 'library@riverside.example',
    sentAt: DateTime.utc(2026, 9, 20, 8),
    subject: 'Overdue books',
    body: const ['Two books on your account are overdue.'],
    box: MailBox.trash,
  ),
];
