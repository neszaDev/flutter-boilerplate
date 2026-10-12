import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/maps/maps_data.dart';
import 'package:flutter_boilerplate/features/showcase/maps/maps_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A transparent 1×1 PNG: every tile, without the network.
final _blank = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, //
  0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F,
  0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00,
  0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _OfflineTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) => MemoryImage(_blank);
}

Future<void> _pump(WidgetTester tester, {ThemeData? theme}) async {
  tester.view
    ..physicalSize = const Size(390 * 3, 844 * 3)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        theme: theme ?? AppTheme.light(),
        home: MapsScreen(tileProvider: _OfflineTiles()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _zoom(WidgetTester tester) =>
    tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!.camera.zoom;

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  // Past the map's double-tap window.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  group('MapsScreen', () {
    testWidgets('lists the places with a link to each website', (tester) async {
      await _pump(tester);

      expect(find.text('Maps'), findsWidgets);
      for (final place in mapPlaces) {
        expect(find.text(place.name), findsOneWidget);
        expect(find.byTooltip('Website of ${place.name}'), findsOneWidget);
      }
      expect(find.text('Show on map'), findsNWidgets(4));
      expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
    });

    testWidgets('opens a place from the list, then closes it again', (tester) async {
      await _pump(tester);

      await _tap(tester, find.byKey(const Key('maps.show.T')));
      expect(find.byKey(const Key('maps.info')), findsOneWidget);
      expect(find.text('https://www.tesla.com/'), findsOneWidget);

      await _tap(tester, find.byKey(const Key('maps.show.T')));
      expect(find.byKey(const Key('maps.info')), findsNothing);

      await _tap(tester, find.byKey(const Key('maps.show.A')));
      await _tap(tester, find.byTooltip('Close'));
      expect(find.byKey(const Key('maps.info')), findsNothing);
    });

    testWidgets('opens a place from its marker', (tester) async {
      await _pump(tester);

      await _tap(
        tester,
        find.descendant(of: find.byType(FlutterMap), matching: find.text('S')),
      );

      expect(find.text('https://www.stanford.edu/'), findsOneWidget);
    });

    testWidgets('zooms in and out, and goes back to the starting view', (tester) async {
      await _pump(tester);
      expect(_zoom(tester), mapInitialZoom);

      await _tap(tester, find.byTooltip('Zoom in'));
      await _tap(tester, find.byTooltip('Zoom in'));
      expect(_zoom(tester), mapInitialZoom + 2);

      await _tap(tester, find.byTooltip('Zoom out'));
      expect(_zoom(tester), mapInitialZoom + 1);

      await _tap(tester, find.byTooltip('Back to the starting view'));
      expect(_zoom(tester), mapInitialZoom);
    });

    testWidgets('shows the coordinates of a tap on the map', (tester) async {
      await _pump(tester);

      await tester.tapAt(tester.getTopLeft(find.byType(FlutterMap)) + const Offset(80, 200));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.textContaining(RegExp(r'^You tapped 37\.\d+, -122\.\d+\.$')), findsOneWidget);
    });

    testWidgets('reads well in the dark theme', (tester) async {
      await _pump(tester, theme: AppTheme.dark());

      expect(find.text('Stanford'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
