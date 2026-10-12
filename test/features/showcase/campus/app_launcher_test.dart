import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/app_launcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'campus_test_app.dart';

void main() {
  group('AppLauncher', () {
    testWidgets('shows each category with its app count and caps badges at 99+', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpCampusWidget(
        tester,
        const AppLauncher(
          categories: [
            LauncherCategory(
              id: 'c1',
              name: LauncherCategoryName.events,
              icon: LucideIcons.ticket,
              apps: [
                LauncherApp(id: 'a1', badge: 0, icon: LucideIcons.gauge),
                LauncherApp(id: 'a2', badge: 120, icon: LucideIcons.gauge),
              ],
            ),
          ],
        ),
      );

      expect(find.text('Events'), findsOneWidget);
      expect(find.text('2 apps'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(find.bySemanticsLabel('Application, 120 new notifications'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'\b0 new notifications')), findsNothing);
      semantics.dispose();
    });
  });
}
