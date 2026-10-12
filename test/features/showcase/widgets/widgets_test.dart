import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/months.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tile_grid.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_brand.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_dropdown.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'showcase_test_app.dart';

/// The page's own (vertical) scroll view; tables and charts may scroll sideways inside it.
final _page = find.byType(Scrollable).first;

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('fr');
  });

  group('monthNames', () {
    test('names the months from January in the locale', () {
      expect(monthNames('en', 3), ['January', 'February', 'March']);
      expect(monthNames('fr', 2, short: true), ['janv.', 'févr.']);
    });

    test('repeats the names past December', () {
      final names = monthNames('en', 14, short: true);

      expect(names[11], 'Dec');
      expect(names.sublist(12), ['Jan', 'Feb']);
    });
  });

  group('TileGrid.columnsFor', () {
    test('fits as many columns of the minimum width as the space allows', () {
      expect(TileGrid.columnsFor(328, minTileWidth: 150, spacing: 12), 2);
      expect(TileGrid.columnsFor(328, minTileWidth: 220, spacing: 12), 1);
      expect(TileGrid.columnsFor(800, minTileWidth: 150, spacing: 12), 5);
    });

    test('keeps one column when even one does not fit', () {
      expect(TileGrid.columnsFor(100, minTileWidth: 150, spacing: 12), 1);
    });
  });

  group('WidgetsDropdown', () {
    testWidgets('opens a widget menu with a disabled last action', (tester) async {
      await pumpShowcase(
        tester,
        const Scaffold(body: SingleChildScrollView(child: WidgetsDropdown())),
      );

      expect(find.text('9,823'), findsNWidgets(4));

      await tester.tap(find.byTooltip('Widget options').first);
      await tester.pumpAndSettle();

      expect(find.text('Another action'), findsOneWidget);
      final disabled = tester.widget<MenuItemButton>(
        find.ancestor(of: find.text('Disabled action'), matching: find.byType(MenuItemButton)),
      );
      expect(disabled.onPressed, isNull);
    });
  });

  group('WidgetsBrand', () {
    testWidgets('names each logo and prints compact and open-ended figures', (tester) async {
      await pumpShowcase(
        tester,
        const Scaffold(body: SingleChildScrollView(child: WidgetsBrand())),
      );

      expect(find.bySemanticsLabel('Facebook'), findsOneWidget);
      expect(find.text('89K'), findsOneWidget);
      expect(find.text('500+'), findsOneWidget);
      expect(find.text('CONTACTS'), findsOneWidget);
    });

    testWidgets('prints the figures with the French separators', (tester) async {
      await pumpShowcase(
        tester,
        const Scaffold(body: SingleChildScrollView(child: WidgetsBrand(charts: true))),
        locale: const Locale('fr'),
      );

      // French groups digits with a narrow no-break space.
      expect(find.text('89\u00a0k'), findsOneWidget);
      expect(find.text('1\u202f792'), findsOneWidget);
      expect(find.text('500+'), findsOneWidget);
    });
  });

  group('WidgetsScreen', () {
    for (final dark in [false, true]) {
      testWidgets('lays every section out on a narrow phone (dark: $dark)', (tester) async {
        await pumpShowcase(tester, const WidgetsScreen(), width: 360, dark: dark);

        expect(find.text('Progress widgets'), findsOneWidget);

        await tester.scrollUntilVisible(find.text('REVIEWS'), 600, scrollable: _page);

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('announces the bars with their name and value', (tester) async {
      await pumpShowcase(tester, const WidgetsScreen());

      expect(
        tester.getSemantics(find.byType(LinearProgressIndicator).first),
        matchesSemantics(label: 'Uptime this month', value: '25%'),
      );
    });
  });
}
