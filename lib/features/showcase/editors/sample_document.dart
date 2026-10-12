import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_quill/quill_delta.dart';

final _tag = RegExp(r'<(\w+)>(.*?)</\1>', dotAll: true);

/// Inserts [message] into [delta]: plain text as is, and the text of each `<tag>…</tag>` with
/// the attributes [tags] gives that tag (none for an unknown tag).
void insertMarkup(Delta delta, String message, Map<String, Map<String, Object>> tags) {
  var start = 0;
  for (final match in _tag.allMatches(message)) {
    if (match.start > start) {
      delta.insert(message.substring(start, match.start));
    }
    delta.insert(match.group(2)!, tags[match.group(1)]);
    start = match.end;
  }
  if (start < message.length) {
    delta.insert(message.substring(start));
  }
}

/// The sample document of the text editor demo: the web page's article about report cards,
/// with its bold lead, links, quote and italics.
Delta sampleDocument(AppLocalizations l10n) {
  final delta = Delta();
  insertMarkup(delta, l10n.textEditorsPageArticleIntro, {
    'b': {'bold': true},
    'school': {'link': l10n.textEditorsPageLinkSchool},
    'grade': {'link': l10n.textEditorsPageLinkGrade},
  });
  delta
    ..insert('\n')
    ..insert('${l10n.textEditorsPageArticleTerms}\n')
    ..insert('${l10n.textEditorsPageArticleQuoteIntro}\n')
    ..insert(l10n.textEditorsPageArticleQuote)
    ..insert('\n', {'blockquote': true});
  insertMarkup(delta, l10n.textEditorsPageArticleLayout, {
    'i': {'italic': true},
  });
  delta.insert('\n');
  return delta;
}
