import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/l10n/gen/app_localizations.dart';
import 'package:intl/intl.dart';

export 'package:flutter_boilerplate/l10n/gen/app_localizations.dart';

/// `context.l10n.authFormEmailLabel` is `AuthForm.email_label` in `l10n/<locale>/auth.json`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Current locale name for `intl` formatters (`en`, `fr`).
  String get localeName => AppLocalizations.of(this).localeName;
}

/// Locale-aware dates and numbers, the counterparts of next-intl's `format.dateTime` and
/// `format.number`. Times are shown in the phone's time zone.
extension FormatContext on BuildContext {
  /// "Sep 28, 2026" (`dateStyle: 'medium'`).
  String formatDate(DateTime value) => DateFormat.yMMMd(localeName).format(value.toLocal());

  /// "September 28, 2026" (`dateStyle: 'long'`).
  String formatDateLong(DateTime value) => DateFormat.yMMMMd(localeName).format(value.toLocal());

  /// "Sep 28, 2026, 9:30 AM" (`dateStyle: 'medium', timeStyle: 'short'`).
  String formatDateTime(DateTime value) =>
      DateFormat.yMMMd(localeName).add_jm().format(value.toLocal());

  /// "9:30 AM".
  String formatTime(DateTime value) => DateFormat.jm(localeName).format(value.toLocal());

  /// "1,234.5" / "1 234,5".
  String formatNumber(num value) => NumberFormat.decimalPattern(localeName).format(value);
}

/// Renders a message with `<tag>…</tag>` markup, like next-intl's `t.rich`:
///
/// ```dart
/// RichMessage(
///   context.l10n.aboutCredits,
///   tags: {'upstream': (text) => TextSpan(text: text, style: linkStyle, recognizer: …)},
/// )
/// ```
///
/// Unknown tags render their text without styling, so a translation can't break the screen.
class RichMessage extends StatelessWidget {
  const RichMessage(this.message, {required this.tags, this.style, this.textAlign, super.key});

  final String message;
  final Map<String, InlineSpan Function(String text)> tags;
  final TextStyle? style;
  final TextAlign? textAlign;

  static final _tag = RegExp(r'<(\w+)>(.*?)</\1>', dotAll: true);

  /// Splits [message] into spans; exposed for tests and for `Text.rich` users.
  static List<InlineSpan> spans(
    String message,
    Map<String, InlineSpan Function(String text)> tags,
  ) {
    final spans = <InlineSpan>[];
    var start = 0;
    for (final match in _tag.allMatches(message)) {
      if (match.start > start) {
        spans.add(TextSpan(text: message.substring(start, match.start)));
      }
      final builder = tags[match.group(1)];
      final text = match.group(2)!;
      spans.add(builder == null ? TextSpan(text: text) : builder(text));
      start = match.end;
    }
    if (start < message.length) {
      spans.add(TextSpan(text: message.substring(start)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(style: style, children: spans(message, tags)),
    textAlign: textAlign,
  );
}
