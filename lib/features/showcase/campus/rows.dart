import 'package:flutter/foundation.dart';

/// One language entry of a multi-language field: a language key and its text (or HTML).
@immutable
class LanguageRow {
  const LanguageRow({required this.id, required this.key, required this.value});

  /// Stable identity for the row's widgets; never shown or saved.
  final String id;
  final String key;
  final String value;

  LanguageRow copyWith({String? key, String? value}) =>
      LanguageRow(id: id, key: key ?? this.key, value: value ?? this.value);

  /// The row as the backend stores it (`{ key, value }`).
  Map<String, String> toJson() => {'key': key, 'value': value};

  @override
  bool operator ==(Object other) =>
      other is LanguageRow && other.id == id && other.key == key && other.value == value;

  @override
  int get hashCode => Object.hash(id, key, value);

  @override
  String toString() => 'LanguageRow($id, $key, $value)';
}

/// The rows a new multi-language field starts with (Vue default: Thai and English).
List<LanguageRow> defaultRows() => const [
  LanguageRow(id: 'row-th', key: 'th', value: ''),
  LanguageRow(id: 'row-en', key: 'en', value: ''),
];

/// Appends an empty row with [id].
List<LanguageRow> addRow(List<LanguageRow> rows, String id) => [
  ...rows,
  LanguageRow(id: id, key: '', value: ''),
];

/// Removes the row [id]. With [refillId], an emptied list gets a fresh Thai row back, so there
/// is always a row to edit (the Vue rich-text editor did this; the plain one could end up empty).
List<LanguageRow> removeRow(List<LanguageRow> rows, String id, {String? refillId}) {
  final rest = rows.where((row) => row.id != id).toList();
  return rest.isEmpty && refillId != null
      ? [LanguageRow(id: refillId, key: 'th', value: '')]
      : rest;
}

/// Changes the key and/or value of the row [id].
List<LanguageRow> updateRow(List<LanguageRow> rows, String id, {String? key, String? value}) => [
  for (final row in rows) row.id == id ? row.copyWith(key: key, value: value) : row,
];
