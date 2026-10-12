final _separators = RegExp(r'[\s_-]+');

String _normalise(String value) => value.toLowerCase().replaceAll(_separators, '');

/// The [names] that match a search text, in their order; every name for an empty search.
///
/// Matching ignores case, spaces, dashes and underscores, so "arrow right", "arrow-right",
/// "ArrowRight" and "arrow_right" find the same icons.
List<String> searchNames(Iterable<String> names, String query) {
  final needle = _normalise(query);
  return needle.isEmpty
      ? names.toList()
      : [
          for (final name in names)
            if (_normalise(name).contains(needle)) name,
        ];
}

/// The emoji flag of a two-letter ISO 3166-1 country code: its letters as regional indicator
/// symbols, which phones draw as the flag (`fr` → 🇫🇷).
String flagEmoji(String code) {
  assert(RegExp(r'^[a-zA-Z]{2}$').hasMatch(code), 'not a two-letter country code: $code');
  const regionalIndicatorA = 0x1F1E6;
  return String.fromCharCodes([
    for (final unit in code.toUpperCase().codeUnits) regionalIndicatorA + unit - 0x41,
  ]);
}
