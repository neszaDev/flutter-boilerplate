/// A decoded JSON object.
typedef Json = Map<String, Object?>;

/// Typed reads from a decoded JSON object. A field with the wrong type throws a
/// [FormatException] naming it, instead of a `TypeError` deep inside a widget.
extension JsonRead on Json {
  T? _read<T>(String key) {
    final value = this[key];
    if (value == null || value is T) {
      return value as T?;
    }
    throw FormatException('"$key" should be $T, got ${value.runtimeType}');
  }

  String? string(String key) => _read<String>(key);

  String requireString(String key) => string(key) ?? (throw FormatException('"$key" is missing'));

  int? integer(String key) => _read<num>(key)?.toInt();

  int requireInt(String key) => integer(key) ?? (throw FormatException('"$key" is missing'));

  double? decimal(String key) => _read<num>(key)?.toDouble();

  bool? boolean(String key) => _read<bool>(key);

  DateTime? dateTime(String key) {
    final value = string(key);
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value) ?? (throw FormatException('"$key" is not a date: $value'));
  }

  Json? object(String key) => _read<Map<String, Object?>>(key);

  List<Json> objects(String key) =>
      (_read<List<Object?>>(key) ?? const []).whereType<Map<String, Object?>>().toList();
}

/// Narrows a response body to a JSON object.
Json asJson(Object? body) =>
    body is Map<String, Object?> ? body : throw const FormatException('expected a JSON object');
