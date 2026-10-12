import 'package:flutter_boilerplate/features/showcase/apps/mail_data.dart';
import 'package:flutter_boilerplate/features/showcase/apps/mailbox.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The sample mailbox shared by the inbox, message and compose screens: changes (read,
/// starred, moved, sent) carry over between them until the app restarts.
final mailboxProvider = NotifierProvider<MailboxController, List<Mail>>(MailboxController.new);

class MailboxController extends Notifier<List<Mail>> {
  var _next = 0;

  @override
  List<Mail> build() => sampleMails;

  /// Applies a toolbar action to the messages with [ids].
  void apply(Iterable<String> ids, MailAction action) =>
      state = applyMailAction(state, ids, action);

  /// Files a new message (sent, a draft or a reply) at the top.
  void add(Mail message) => state = [message, ...state];

  /// A fresh id for a message written here.
  String newId() => 'local-${DateTime.now().microsecondsSinceEpoch}-${_next++}';
}
