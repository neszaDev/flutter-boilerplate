import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// One party of the invoice (the seller or the customer).
class InvoiceParty {
  const InvoiceParty({
    required this.name,
    required this.street,
    required this.city,
    required this.email,
    required this.phone,
  });

  final String name;
  final String street;
  final String city;
  final String email;
  final String phone;
}

/// A line of the invoice; amounts in cents.
class InvoiceLine {
  const InvoiceLine({
    required this.item,
    required this.description,
    required this.quantity,
    required this.unitCents,
  });

  final String item;
  final String description;
  final int quantity;
  final int unitCents;

  int get totalCents => quantity * unitCents;
}

/// An invoice: parties, payment details, lines and the rates applied to them.
class Invoice {
  const Invoice({
    required this.number,
    required this.issuedOn,
    required this.currency,
    required this.from,
    required this.to,
    required this.vatNumber,
    required this.accountName,
    required this.swift,
    required this.discountRate,
    required this.vatRate,
    required this.lines,
  });

  final String number;

  /// The issue date, `yyyy-MM-dd` (a calendar day, no time zone).
  final String issuedOn;

  /// ISO 4217 code of every amount.
  final String currency;
  final InvoiceParty from;
  final InvoiceParty to;
  final String vatNumber;
  final String accountName;
  final String swift;

  /// Discount as a fraction (0.2 is 20%).
  final double discountRate;

  /// VAT as a fraction, applied after the discount.
  final double vatRate;
  final List<InvoiceLine> lines;

  /// [issuedOn] as a local calendar day.
  DateTime get issuedDate => DateTime.parse(issuedOn);
}

/// The sample invoice of the Vue app, with fictional parties.
const sampleInvoice = Invoice(
  number: '90-98792',
  issuedOn: '2026-09-30',
  currency: 'USD',
  from: InvoiceParty(
    name: 'Northgate Software Ltd',
    street: '42 Station Road',
    city: 'Leeds LS1 4AB, United Kingdom',
    email: 'billing@northgate.example',
    phone: '+44 113 496 0000',
  ),
  to: InvoiceParty(
    name: 'Riverside Academy',
    street: '8 Mill Lane',
    city: 'York YO1 7HH, United Kingdom',
    email: 'accounts@riverside.example',
    phone: '+44 1904 496 000',
  ),
  vatNumber: 'GB 123 4567 89',
  accountName: 'Northgate Software Ltd',
  swift: 'NGSWGB2L',
  discountRate: 0.2,
  vatRate: 0.1,
  lines: [
    InvoiceLine(
      item: 'Origin licence',
      description: 'Extended licence',
      quantity: 1,
      unitCents: 99900,
    ),
    InvoiceLine(
      item: 'Custom services',
      description: 'Installation and customisation (per hour)',
      quantity: 20,
      unitCents: 15000,
    ),
    InvoiceLine(
      item: 'Hosting',
      description: 'One-year subscription',
      quantity: 1,
      unitCents: 49900,
    ),
    InvoiceLine(
      item: 'Platinum support',
      description: 'One-year subscription, 24/7',
      quantity: 1,
      unitCents: 399900,
    ),
  ],
);

/// The invoice totals, in whole cents.
typedef InvoiceTotals = ({int subtotal, int discount, int vat, int total});

/// The subtotal of [lines], the discount on it, VAT on the discounted amount, and the total
/// due, rounded to whole cents.
InvoiceTotals invoiceTotals({
  required List<InvoiceLine> lines,
  required double discountRate,
  required double vatRate,
}) {
  final subtotal = lines.fold(0, (sum, line) => sum + line.totalCents);
  final discount = (subtotal * discountRate).round();
  final vat = ((subtotal - discount) * vatRate).round();
  return (subtotal: subtotal, discount: discount, vat: vat, total: subtotal - discount + vat);
}

/// Formats cents of [currency] for [localeName]: `$9,999.00`, `9 999,00 $`.
String formatMoney(int cents, {required String currency, required String localeName}) =>
    NumberFormat.simpleCurrency(locale: localeName, name: currency).format(cents / 100);

final _markup = RegExp(r'</?\w+>');

/// [invoice] as plain text, for the share sheet: the header, both parties, the payment
/// details, one line per item, the totals and the terms.
String invoiceShareText(Invoice invoice, AppLocalizations l10n) {
  String plain(String message) => message.replaceAll(_markup, '');
  String money(int cents) =>
      formatMoney(cents, currency: invoice.currency, localeName: l10n.localeName);
  String amount(String label, int cents) => l10n.invoicePageShareAmount(label, money(cents));
  List<String> party(String title, InvoiceParty party) => [
    title.toUpperCase(),
    party.name,
    party.street,
    party.city,
    l10n.invoicePageEmail(party.email),
    l10n.invoicePagePhone(party.phone),
  ];
  final totals = invoiceTotals(
    lines: invoice.lines,
    discountRate: invoice.discountRate,
    vatRate: invoice.vatRate,
  );
  final quantity = NumberFormat.decimalPattern(l10n.localeName);

  return [
    plain(l10n.invoicePageInvoiceTitle(invoice.number)),
    DateFormat.yMMMMd(l10n.localeName).format(invoice.issuedDate),
    '',
    ...party(l10n.invoicePageFrom, invoice.from),
    '',
    ...party(l10n.invoicePageTo, invoice.to),
    '',
    l10n.invoicePageDetails.toUpperCase(),
    l10n.invoicePageVatNumber(invoice.vatNumber),
    l10n.invoicePageAccountName(invoice.accountName),
    l10n.invoicePageSwift(invoice.swift),
    '',
    l10n.invoicePageLinesCaption.toUpperCase(),
    for (final (index, line) in invoice.lines.indexed)
      l10n.invoicePageShareLine(
        '${index + 1}',
        line.item,
        line.description,
        quantity.format(line.quantity),
        money(line.unitCents),
        money(line.totalCents),
      ),
    '',
    amount(l10n.invoicePageSubtotal, totals.subtotal),
    amount(l10n.invoicePageDiscount(invoice.discountRate), totals.discount),
    amount(l10n.invoicePageVat(invoice.vatRate), totals.vat),
    amount(l10n.invoicePageTotal, totals.total),
    '',
    l10n.invoicePageTerms,
  ].join('\n');
}
