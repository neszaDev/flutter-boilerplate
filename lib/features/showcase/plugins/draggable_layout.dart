import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Accent stripe on a grid card, one step of the folder/ink palette. [wire] is the name saved
/// in the layout (the web app's `CardAccent`).
enum CardAccent {
  folder('folder'),
  ink950('ink-950'),
  ink700('ink-700'),
  ink600('ink-600'),
  ink400('ink-400'),
  ink300('ink-300');

  const CardAccent(this.wire);

  final String wire;
}

/// Which size of a card to flip.
enum CardSize { wide, tall }

/// One card of the draggable grid, in display order.
@immutable
class GridCard {
  const GridCard({
    required this.id,
    required this.accent,
    this.wide = false,
    this.tall = false,
    this.pinned = false,
  });

  final String id;
  final CardAccent accent;

  /// Spans two columns where the grid has them.
  final bool wide;

  /// Taller than the other cards.
  final bool tall;

  /// Pinned: cannot be dragged, and the other cards move around it.
  final bool pinned;

  GridCard copyWith({bool? wide, bool? tall}) => GridCard(
    id: id,
    accent: accent,
    wide: wide ?? this.wide,
    tall: tall ?? this.tall,
    pinned: pinned,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'accent': accent.wire,
    'wide': wide,
    'tall': tall,
    'pinned': pinned,
  };

  @override
  bool operator ==(Object other) =>
      other is GridCard &&
      other.id == id &&
      other.accent == accent &&
      other.wide == wide &&
      other.tall == tall &&
      other.pinned == pinned;

  @override
  int get hashCode => Object.hash(id, accent, wide, tall, pinned);
}

/// The Vue demo's base layout.
const baseLayout = <GridCard>[
  GridCard(id: '1', accent: CardAccent.folder, tall: true),
  GridCard(id: '2', accent: CardAccent.ink300, pinned: true),
  GridCard(id: '3', accent: CardAccent.ink950),
  GridCard(id: '4', accent: CardAccent.ink700),
  GridCard(id: '5', accent: CardAccent.ink600, wide: true),
  GridCard(id: '6', accent: CardAccent.ink400),
];

/// Moves a card to another card's place. Pinned cards keep their position; the movable cards
/// flow around them. Returns [layout] itself when nothing moves.
List<GridCard> moveCard(List<GridCard> layout, String activeId, String overId) {
  final movable = layout.where((card) => !card.pinned).toList();
  final from = movable.indexWhere((card) => card.id == activeId);
  final to = movable.indexWhere((card) => card.id == overId);
  if (from == -1 || to == -1 || from == to) {
    return layout;
  }
  final reordered = [...movable];
  reordered.insert(to, reordered.removeAt(from));
  var next = 0;
  return [
    for (final card in layout)
      if (card.pinned) card else reordered[next++],
  ];
}

/// Flips one size of one card: two columns wide, or taller than the rest.
List<GridCard> toggleCardSize(List<GridCard> layout, String id, CardSize size) => [
  for (final card in layout)
    if (card.id != id)
      card
    else
      switch (size) {
        CardSize.wide => card.copyWith(wide: !card.wide),
        CardSize.tall => card.copyWith(tall: !card.tall),
      },
];

/// The layout as saved on the phone.
String encodeLayout(List<GridCard> layout) => jsonEncode([
  for (final card in layout) card.toJson(),
]);

/// Reads a saved layout; anything missing, malformed or foreign counts as no saved layout.
List<GridCard>? parseStoredLayout(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final Object? json;
  try {
    json = jsonDecode(raw);
  } on FormatException {
    return null;
  }
  if (json is! List<Object?> || json.isEmpty) {
    return null;
  }
  final cards = <GridCard>[];
  for (final item in json) {
    if (item is! Map<String, Object?>) {
      return null;
    }
    final accent = CardAccent.values.where((value) => value.wire == item['accent']).firstOrNull;
    if (item
        case {
          'id': final String id,
          'wide': final bool wide,
          'tall': final bool tall,
          'pinned': final bool pinned,
        }
        when accent != null) {
      cards.add(GridCard(id: id, accent: accent, wide: wide, tall: tall, pinned: pinned));
    } else {
      return null;
    }
  }
  return cards;
}

/// How many columns a card takes in a grid of [columns].
int cardSpan(GridCard card, int columns) => card.wide ? math.min(2, columns) : 1;

/// Splits the layout into the rows of a grid of [columns], in order: a card that does not fit
/// in what is left of a row starts the next one (CSS grid without dense packing).
List<List<GridCard>> gridRows(List<GridCard> layout, int columns) {
  final rows = <List<GridCard>>[];
  var row = <GridCard>[];
  var used = 0;
  for (final card in layout) {
    final span = cardSpan(card, columns);
    if (used + span > columns) {
      rows.add(row);
      row = [];
      used = 0;
    }
    row.add(card);
    used += span;
    if (used == columns) {
      rows.add(row);
      row = [];
      used = 0;
    }
  }
  if (row.isNotEmpty) {
    rows.add(row);
  }
  return rows;
}
