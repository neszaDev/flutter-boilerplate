import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/features/showcase/apps/invoice_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(initializeDateFormatting);

  group('invoiceTotals', () {
    test('matches the figures of the Vue sample invoice', () {
      expect(
        invoiceTotals(
          lines: sampleInvoice.lines,
          discountRate: sampleInvoice.discountRate,
          vatRate: sampleInvoice.vatRate,
        ),
        (subtotal: 849700, discount: 169940, vat: 67976, total: 747736),
      );
    });

    test('rounds the discount and VAT to whole cents', () {
      final totals = invoiceTotals(
        lines: const [InvoiceLine(item: 'Pen', description: '', quantity: 3, unitCents: 333)],
        discountRate: 0.15,
        vatRate: 0.2,
      );

      expect(totals, (subtotal: 999, discount: 150, vat: 170, total: 1019));
    });

    test('returns zeros for an empty invoice', () {
      expect(invoiceTotals(lines: const [], discountRate: 0.2, vatRate: 0.1).total, 0);
    });
  });

  group('formatMoney', () {
    test('formats cents in the locale', () {
      expect(formatMoney(747736, currency: 'USD', localeName: 'en'), r'$7,477.36');
      expect(formatMoney(747736, currency: 'USD', localeName: 'fr'), contains('7 477,36'));
    });
  });

  group('invoiceShareText', () {
    test('lists the parties, the lines and the totals as plain text', () {
      final text = invoiceShareText(sampleInvoice, lookupAppLocalizations(const Locale('en')));

      expect(text, startsWith('Invoice #90-98792\nSeptember 30, 2026\n'));
      expect(text, contains('FROM\nNorthgate Software Ltd\n42 Station Road'));
      expect(text, contains('Email: accounts@riverside.example'));
      expect(
        text,
        contains(
          r'2. Custom services (Installation and customisation (per hour)): 20 × $150.00 = $3,000.00',
        ),
      );
      expect(text, contains('Discount (20%): \$1,699.40'));
      expect(text, contains('VAT (10%): \$679.76'));
      expect(text, contains('Total: \$7,477.36'));
      expect(text, isNot(contains('<strong>')));
    });

    test('follows the French punctuation', () {
      final text = invoiceShareText(sampleInvoice, lookupAppLocalizations(const Locale('fr')));

      expect(text, startsWith('Facture n° 90-98792\n30 septembre 2026\n'));
      expect(text, contains('Sous-total : '));
    });
  });
}
