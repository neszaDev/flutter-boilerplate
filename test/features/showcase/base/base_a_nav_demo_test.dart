import 'package:flutter_boilerplate/features/showcase/base/base_a_nav_demo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'base_a_harness.dart';

const _items = [
  NavDemoItem(id: 'a', label: 'Active'),
  NavDemoItem(id: 'b', label: 'Link'),
  NavDemoItem(id: 'c', label: 'Disabled', disabled: true),
];

void main() {
  group('NavDemo', () {
    testWidgets('makes the pressed item current', (tester) async {
      await pumpBase(
        tester,
        const NavDemo(
          label: 'Demo',
          items: _items,
          variant: NavDemoVariant.pills,
          initialActive: 'a',
        ),
      );

      await tester.tap(find.text('Link'));
      await tester.pump();

      expect(tester.getSemantics(find.text('Link')), isSemantics(isSelected: true));
      expect(tester.getSemantics(find.text('Active')), isSemantics(isSelected: false));
    });

    testWidgets('keeps disabled items out of reach', (tester) async {
      await pumpBase(tester, const NavDemo(label: 'Demo', items: _items, initialActive: 'a'));

      await tester.tap(find.text('Disabled'));
      await tester.pump();

      expect(
        tester.getSemantics(find.text('Disabled')),
        isSemantics(isEnabled: false, isSelected: false),
      );
      expect(tester.getSemantics(find.text('Active')), isSemantics(isSelected: true));
    });

    testWidgets('marks the dropdown current once one of its entries is chosen', (tester) async {
      await pumpBase(
        tester,
        const NavDemo(
          label: 'Demo',
          items: _items,
          dropdown: (
            label: 'More',
            groups: [
              ['One'],
              ['Two'],
            ],
          ),
        ),
      );

      expect(tester.getSemantics(find.text('More')), isSemantics(isSelected: false));

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(find.text('Two'), findsNothing);
      expect(tester.getSemantics(find.text('More')), isSemantics(isSelected: true));
    });

    testWidgets('names icon-only items with a tooltip', (tester) async {
      await pumpBase(
        tester,
        const NavDemo(
          label: 'Demo',
          items: [NavDemoItem(id: 'bell', label: 'Notifications', icon: LucideIcons.bell)],
        ),
      );

      expect(find.byTooltip('Notifications'), findsOneWidget);
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    });
  });
}
