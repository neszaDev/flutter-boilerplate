import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/notifications/badges_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  group('BadgesScreen', () {
    testWidgets('shows a badge beside each heading and every variant', (tester) async {
      usePhoneSize(tester, height: 3000);
      await tester.pumpWidget(harness(const BadgesScreen()));

      expect(find.text('NEW'), findsNWidgets(5));
      for (final variant in ['PRIMARY', 'SECONDARY', 'DESTRUCTIVE', 'OUTLINE', 'GHOST', 'LINK']) {
        // Plain, pill and actionable.
        expect(find.text(variant), findsNWidgets(3), reason: variant);
      }
      expect(find.byType(Badge), findsOneWidget);
    });

    testWidgets('answers a tap on an actionable badge', (tester) async {
      usePhoneSize(tester, height: 3000);
      await tester.pumpWidget(harness(const BadgesScreen()));

      await tester.tap(find.widgetWithText(ActionChip, 'OUTLINE'));
      await tester.pump();

      expect(find.text('You tapped the “Outline” badge.'), findsOneWidget);
    });

    testWidgets('renders in both themes and languages', (tester) async {
      await expectRendersEverywhere(tester, const BadgesScreen());
    });
  });
}
