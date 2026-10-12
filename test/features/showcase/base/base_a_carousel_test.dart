import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_carousel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_a_harness.dart';

void main() {
  group('DemoCarousel', () {
    const carousel = DemoCarousel(picture: Text('Crest'));

    testWidgets('goes to the slide whose indicator is pressed', (tester) async {
      await pumpBase(tester, carousel);

      await tester.tap(find.bySemanticsLabel('Go to slide 3'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Go to slide 3')),
        isSemantics(isSelected: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Go to slide 1')),
        isSemantics(isSelected: false),
      );
      expect(find.text('Slide 3 of 3'), findsOneWidget);
      expect(find.text('Crest'), findsOneWidget);
    });

    testWidgets('loops from the first slide back to the last with the previous arrow', (
      tester,
    ) async {
      await pumpBase(tester, carousel);

      expect(find.text('Slide 1 of 3'), findsOneWidget);

      await tester.tap(find.byTooltip('Previous slide'));
      await tester.pumpAndSettle();

      expect(find.text('Slide 3 of 3'), findsOneWidget);

      await tester.tap(find.byTooltip('Next slide'));
      await tester.pumpAndSettle();

      expect(find.text('Slide 1 of 3'), findsOneWidget);
    });

    testWidgets('moves on by itself every 6 seconds', (tester) async {
      await pumpBase(tester, carousel);

      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      expect(find.text('Slide 2 of 3'), findsOneWidget);
    });

    testWidgets('pauses and resumes autoplay with its button', (tester) async {
      await pumpBase(tester, carousel);

      await tester.tap(find.text('Pause'));
      await tester.pump();

      expect(find.text('Play'), findsOneWidget);

      await tester.pump(const Duration(seconds: 13));
      await tester.pumpAndSettle();

      expect(find.text('Slide 1 of 3'), findsOneWidget);

      await tester.tap(find.text('Play'));
      await tester.pump();

      expect(find.text('Pause'), findsOneWidget);
    });

    testWidgets('starts paused when the phone asks for reduced motion', (tester) async {
      await pumpBase(
        tester,
        const MediaQuery(data: MediaQueryData(disableAnimations: true), child: carousel),
      );

      expect(find.text('Play'), findsOneWidget);
    });
  });
}
