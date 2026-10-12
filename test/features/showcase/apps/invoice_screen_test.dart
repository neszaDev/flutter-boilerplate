import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/apps/invoice_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'apps_test_app.dart';

void main() {
  group('InvoiceScreen', () {
    testWidgets('shows the lines and the totals of the sample invoice', (tester) async {
      await pumpApps(tester, const InvoiceScreen());

      expect(find.text('Platinum support'), findsOneWidget);
      expect(find.text(r'$3,000.00'), findsOneWidget);
      expect(find.text('Discount (20%)'), findsOneWidget);
      expect(find.text(r'$1,699.40'), findsOneWidget);
      expect(find.text(r'$7,477.36'), findsOneWidget);
      // On a phone the unit cost column is left out and the description goes under the item.
      expect(find.text('UNIT COST'), findsNothing);
      expect(find.text('One-year subscription, 24/7'), findsOneWidget);
    });

    testWidgets('confirms a save and says payment is not connected', (tester) async {
      await pumpApps(tester, const InvoiceScreen());

      await tester.tap(find.byKey(const Key('invoice.save')));
      await tester.pumpAndSettle();
      expect(find.text('Invoice saved'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('invoice.pay')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('invoice.pay')));
      await tester.pumpAndSettle();
      expect(find.text('Online payment is not connected yet.'), findsOneWidget);
    });

    testWidgets('shows every column on a wide screen', (tester) async {
      await pumpApps(tester, const InvoiceScreen());
      tester.view.physicalSize = const Size(900 * 3, 1200 * 3);
      await tester.pumpAndSettle();

      expect(find.text('UNIT COST'), findsOneWidget);
      expect(find.text(r'$999.00'), findsNWidgets(2));
    });

    testWidgets('reads well in the dark theme', (tester) async {
      await pumpApps(tester, const InvoiceScreen(), theme: AppTheme.dark());

      expect(find.text('Share'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
