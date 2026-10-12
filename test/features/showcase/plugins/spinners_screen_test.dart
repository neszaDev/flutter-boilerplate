import 'package:flutter_boilerplate/features/showcase/plugins/spinners_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  group('SpinnersScreen', () {
    testWidgets('names every SpinKit loader and announces the base spinners', (tester) async {
      usePhoneSize(tester, height: 3000);
      await tester.pumpWidget(harness(const SpinnersScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SpinKitDemo), findsNWidgets(SpinKitLoader.values.length));
      for (final name in ['Rotating plane', 'Chasing dots', 'Swing', 'Folding cube']) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      expect(find.bySemanticsLabel('Loading'), findsNWidgets(6));
    });

    testWidgets('stands still when the phone asks for reduced motion', (tester) async {
      usePhoneSize(tester, height: 3000);
      await tester.pumpWidget(harness(const SpinnersScreen(), reduceMotion: true));
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('renders in both themes and languages', (tester) async {
      await expectRendersEverywhere(tester, const SpinnersScreen());
    });
  });
}
