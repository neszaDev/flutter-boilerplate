import 'package:intl/intl.dart';

/// Month names from January on, in [locale] (the "months" labels of the CoreUI charts).
///
/// [count] names are returned; past December they repeat. [short] gives "Jan" instead of
/// "January".
List<String> monthNames(String locale, int count, {bool short = false}) {
  final format = short ? DateFormat.MMM(locale) : DateFormat.MMMM(locale);
  return [
    for (var index = 0; index < count; index++) format.format(DateTime(2026, index % 12 + 1)),
  ];
}
