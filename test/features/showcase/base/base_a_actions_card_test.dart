import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_actions_card.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_a_harness.dart';

void main() {
  group('ActionsCard', () {
    testWidgets('folds and unfolds the body with the minimise button', (tester) async {
      await pumpBase(tester, const ActionsCard(child: Text('Card body')));

      expect(find.text('Card body'), findsOneWidget);

      await tester.tap(find.byTooltip('Fold the card body'));
      await tester.pumpAndSettle();

      expect(find.text('Card body'), findsNothing);
      expect(
        tester.getSemantics(find.byTooltip('Unfold the card body')),
        isSemantics(hasExpandedState: true, isExpanded: false, isButton: true),
      );

      await tester.tap(find.byTooltip('Unfold the card body'));
      await tester.pumpAndSettle();

      expect(find.text('Card body'), findsOneWidget);
      expect(
        tester.getSemantics(find.byTooltip('Fold the card body')),
        isSemantics(hasExpandedState: true, isExpanded: true),
      );
    });

    testWidgets('closes the card and brings it back', (tester) async {
      await pumpBase(tester, const ActionsCard(child: Text('Card body')));

      await tester.tap(find.byTooltip('Close the card'));
      await tester.pumpAndSettle();

      expect(find.text('Card with header actions'), findsNothing);

      await tester.tap(find.text('Show the card again'));
      await tester.pumpAndSettle();

      expect(find.text('Card body'), findsOneWidget);
    });
  });
}
