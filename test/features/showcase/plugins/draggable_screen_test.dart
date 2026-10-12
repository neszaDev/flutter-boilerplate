import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/draggable_layout.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/draggable_screen.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/layout_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'harness.dart';

/// A layout store in memory.
class _MemoryLayoutStore implements LayoutStore {
  _MemoryLayoutStore([this.json]);

  String? json;

  @override
  Future<String?> read() async => json;

  @override
  Future<bool> write(String json) async {
    this.json = json;
    return true;
  }
}

/// Card ids from top to bottom (one column on a phone).
List<String> _order(WidgetTester tester) {
  final cards = find.byWidgetPredicate(
    (widget) => switch (widget.key) {
      ValueKey<String>(:final value) => value.startsWith('grid-card-'),
      _ => false,
    },
  );
  final found =
      [
        for (final element in cards.evaluate())
          if (element.widget.key case final ValueKey<String> key) key,
      ]..sort(
        (a, b) =>
            tester.getTopLeft(find.byKey(a)).dy.compareTo(tester.getTopLeft(find.byKey(b)).dy),
      );
  return [for (final key in found) key.value.replaceFirst('grid-card-', '')];
}

Future<_MemoryLayoutStore> _pumpGrid(WidgetTester tester, {String? saved}) async {
  final store = _MemoryLayoutStore(saved);
  usePhoneSize(tester, height: 2400);
  await tester.pumpWidget(
    harness(const DraggableScreen(), overrides: [layoutStoreProvider.overrideWithValue(store)]),
  );
  await tester.pump();
  return store;
}

void main() {
  group('DraggableGrid', () {
    testWidgets('moves a card past the pinned one with a long-press drag', (tester) async {
      await _pumpGrid(tester);
      expect(_order(tester), ['1', '2', '3', '4', '5', '6']);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('grid-card-1'))),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      expect(find.text('Picked up Drag and drop card 1.'), findsOneWidget);

      await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('grid-card-3'))));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(_order(tester), ['3', '2', '1', '4', '5', '6']);
      expect(
        find.text('Drag and drop card 1 was dropped on Drag and drop card 3.'),
        findsOneWidget,
      );
    });

    testWidgets('does not drop a card on the pinned one', (tester) async {
      await _pumpGrid(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('grid-card-1'))),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('grid-card-2'))));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(_order(tester), ['1', '2', '3', '4', '5', '6']);
      expect(find.text('Drag and drop card 1 was dropped where it was.'), findsOneWidget);
    });

    testWidgets('scrolls the page while a card is held at the bottom edge', (tester) async {
      final store = _MemoryLayoutStore();
      usePhoneSize(tester);
      await tester.pumpWidget(
        harness(const DraggableScreen(), overrides: [layoutStoreProvider.overrideWithValue(store)]),
      );
      await tester.pump();
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
      expect(scroll.pixels, 0);

      final gesture = await tester.startGesture(
        tester.getTopLeft(find.byKey(const ValueKey('grid-card-1'))) + const Offset(40, 40),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await gesture.moveTo(const Offset(180, 735));
      for (var frame = 0; frame < 20; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(scroll.pixels, greaterThan(0));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('saves the layout and offers to restore it', (tester) async {
      final store = await _pumpGrid(tester);

      expect(find.text('Restore the saved layout'), findsNothing);
      await tester.tap(find.byTooltip('Show Drag and drop card 3 taller'));
      await tester.pump();
      await tester.tap(find.text('Save the layout'));
      await tester.pump();

      expect(find.text('Layout saved on this phone.'), findsOneWidget);
      expect(find.text('Restore the saved layout'), findsOneWidget);
      expect(store.json, contains('"tall":true'));
      expect(parseStoredLayout(store.json)?[2].tall, isTrue);
    });

    testWidgets('opens on the saved layout', (tester) async {
      await _pumpGrid(tester, saved: encodeLayout(moveCard(baseLayout, '6', '1')));

      expect(_order(tester), ['6', '2', '1', '3', '4', '5']);
      expect(find.text('Restore the saved layout'), findsOneWidget);

      await tester.tap(find.text('Restore the base layout'));
      await tester.pump();
      expect(_order(tester), ['1', '2', '3', '4', '5', '6']);
      expect(find.text('Base layout restored.'), findsOneWidget);
    });

    testWidgets('hides the handles and size buttons when the options are off', (tester) async {
      await _pumpGrid(tester);
      expect(find.byIcon(LucideIcons.gripVertical), findsNWidgets(5));

      await tester.tap(find.text('Drag and drop'));
      await tester.tap(find.text('Resizing'));
      await tester.pump();

      expect(find.byIcon(LucideIcons.gripVertical), findsNothing);
      expect(find.byIcon(LucideIcons.moveVertical), findsNothing);
    });

    testWidgets('offers the two-column size only where the grid has two columns', (tester) async {
      await _pumpGrid(tester);
      expect(find.byIcon(LucideIcons.moveHorizontal), findsNothing);

      tester.view.physicalSize = const Size(700, 2400) * 3;
      await tester.pump();
      expect(find.byIcon(LucideIcons.moveHorizontal), findsNWidgets(6));
    });

    testWidgets('moves cards with the screen reader actions', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpGrid(tester);

      const earlier = CustomSemanticsAction(label: 'Move Drag and drop card 4 earlier');
      final id = CustomSemanticsAction.getIdentifier(earlier);
      tester.semantics.customAction(
        find.semantics.byPredicate(
          (node) => node.getSemanticsData().customSemanticsActionIds?.contains(id) ?? false,
        ),
        earlier,
      );
      await tester.pump();

      expect(_order(tester), ['1', '2', '4', '3', '5', '6']);
      semantics.dispose();
    });

    testWidgets('renders in both themes and languages', (tester) async {
      await expectRendersEverywhere(
        tester,
        const DraggableScreen(),
        overrides: [layoutStoreProvider.overrideWithValue(_MemoryLayoutStore())],
      );
    });
  });
}
