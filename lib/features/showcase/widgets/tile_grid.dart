import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';

/// Lays [children] out in as many equal columns as fit (each at least [minTileWidth] wide, at
/// most [maxColumns]), rows of equal height: the web's `grid sm:grid-cols-2 lg:grid-cols-4`
/// for a phone that may be 360 pt or a tablet.
///
/// Tiles must report an intrinsic height: give charts inside them a fixed height.
class TileGrid extends StatelessWidget {
  const TileGrid({
    required this.children,
    this.minTileWidth = 150,
    this.maxColumns,
    this.spacing = Space.md,
    this.filler,
    super.key,
  });

  final List<Widget> children;
  final double minTileWidth;
  final int? maxColumns;
  final double spacing;

  /// Fills the empty cells of the last row (e.g. card stock in a joined card group).
  final Widget? filler;

  /// How many columns of at least [minTileWidth] fit in [width].
  static int columnsFor(double width, {required double minTileWidth, required double spacing}) =>
      ((width + spacing) / (minTileWidth + spacing)).floor().clamp(1, 12);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final fit = columnsFor(constraints.maxWidth, minTileWidth: minTileWidth, spacing: spacing);
      final columns = fit.clamp(1, maxColumns ?? children.length.clamp(1, 12));
      final rows = <Widget>[];
      for (var start = 0; start < children.length; start += columns) {
        final cells = <Widget>[];
        for (var column = 0; column < columns; column++) {
          final index = start + column;
          if (column > 0) {
            cells.add(SizedBox(width: spacing));
          }
          cells.add(
            Expanded(
              child: index < children.length ? children[index] : filler ?? const SizedBox(),
            ),
          );
        }
        if (rows.isNotEmpty) {
          rows.add(SizedBox(height: spacing));
        }
        rows.add(
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
          ),
        );
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
    },
  );
}
