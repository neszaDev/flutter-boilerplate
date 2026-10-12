import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/apps/invoice_data.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

/// Wider than this, the parties sit side by side and the lines show every column.
const _wideLayout = 600.0;

/// `/dashboard/apps/invoicing/invoice`: the Vue invoice (seller, customer and payment details,
/// the lines and the totals) with save, share (as plain text) and a payment button.
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.invoicePageTitle,
      description: Text(l10n.invoicePageDescription),
      children: const [_InvoiceCard(invoice: sampleInvoice)],
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.card, Space.card, Space.card, Space.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: RichMessage(
                    l10n.invoicePageInvoiceTitle(invoice.number),
                    style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                    tags: {
                      'strong': (text) => TextSpan(
                        text: text,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    },
                  ),
                ),
                const SizedBox(height: Space.md),
                _InvoiceActions(invoice: invoice),
              ],
            ),
          ),
          const DoubleRule(),
          Padding(
            padding: const EdgeInsets.all(Space.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Parties(invoice: invoice),
                const SizedBox(height: Space.xl),
                _Lines(invoice: invoice),
                const SizedBox(height: Space.xl),
                Text(
                  l10n.invoicePageTerms,
                  style: context.text.bodyMedium?.copyWith(color: context.colors.ink600),
                ),
                const SizedBox(height: Space.lg),
                _Totals(invoice: invoice),
                const SizedBox(height: Space.page),
                FilledButton.icon(
                  key: const Key('invoice.pay'),
                  onPressed: () => showToast(context, l10n.invoicePagePaymentUnavailable),
                  icon: const Icon(LucideIcons.creditCard, size: 18),
                  label: Text(l10n.invoicePagePay),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Save (confirmed with a toast) and share (the invoice as plain text, through the share
/// sheet: the phone's counterpart of the web's print button).
class _InvoiceActions extends StatelessWidget {
  const _InvoiceActions({required this.invoice});

  final Invoice invoice;

  Future<void> _share(BuildContext context) async {
    final l10n = context.l10n;
    final box = context.findRenderObject() as RenderBox?;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: invoiceShareText(invoice, l10n),
          subject: l10n.invoicePageInvoiceTitle(invoice.number).replaceAll(RegExp(r'</?\w+>'), ''),
          sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } on PlatformException {
      if (context.mounted) {
        showToast(context, l10n.commonErrorGeneric, tone: ToastTone.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        OutlinedButton.icon(
          key: const Key('invoice.save'),
          onPressed: () => showToast(context, l10n.invoicePageSaved, tone: ToastTone.success),
          icon: const Icon(LucideIcons.save, size: 18),
          label: Text(l10n.invoicePageSave),
        ),
        Builder(
          builder: (context) => OutlinedButton.icon(
            key: const Key('invoice.share'),
            onPressed: () => _share(context),
            icon: const Icon(LucideIcons.share2, size: 18),
            label: Text(l10n.commonShare),
          ),
        ),
      ],
    );
  }
}

/// From, To and the payment details: stacked on a phone, side by side when there is room.
class _Parties extends StatelessWidget {
  const _Parties({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final strong = TextStyle(fontWeight: FontWeight.w600, color: context.colors.ink950);
    final blocks = [
      _Party(title: l10n.invoicePageFrom, party: invoice.from),
      _Party(title: l10n.invoicePageTo, party: invoice.to),
      _Block(
        title: l10n.invoicePageDetails,
        children: [
          RichMessage(
            l10n.invoicePageInvoiceNumber(invoice.number),
            tags: {'strong': (text) => TextSpan(text: text, style: strong)},
          ),
          Text(context.formatDateLong(invoice.issuedDate)),
          Text(l10n.invoicePageVatNumber(invoice.vatNumber)),
          Text(l10n.invoicePageAccountName(invoice.accountName)),
          Text(l10n.invoicePageSwift(invoice.swift), style: strong),
        ],
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= _wideLayout
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Space.lg,
              children: [for (final block in blocks) Expanded(child: block)],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Space.lg,
              children: blocks,
            ),
    );
  }
}

class _Party extends StatelessWidget {
  const _Party({required this.title, required this.party});

  final String title;
  final InvoiceParty party;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Block(
      title: title,
      children: [
        Text(
          party.name,
          style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.ink950),
        ),
        Text(party.street),
        Text(party.city),
        Text(l10n.invoicePageEmail(party.email)),
        Text(l10n.invoicePagePhone(party.phone)),
      ],
    );
  }
}

/// A titled address block.
class _Block extends StatelessWidget {
  const _Block({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: context.text.bodyMedium?.copyWith(color: context.colors.ink700),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Space.sm - 2),
          child: Semantics(header: true, child: FormLabel(title)),
        ),
        ...children,
      ],
    ),
  );
}

/// The invoice lines. On a phone the description goes under the item and the unit cost is
/// left out, as on the web's small screens.
class _Lines extends StatelessWidget {
  const _Lines({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final cell = context.type.table;
    final strong = cell.copyWith(fontWeight: FontWeight.w600, color: colors.ink950);
    String money(int cents) =>
        formatMoney(cents, currency: invoice.currency, localeName: l10n.localeName);

    Widget head(String text, {TextAlign align = TextAlign.start}) => Padding(
      padding: const EdgeInsets.fromLTRB(Space.sm, Space.sm, Space.sm, Space.md),
      child: Text(text.toUpperCase(), style: context.type.formLabel, textAlign: align),
    );
    Widget body(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.md),
      child: child,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideLayout;
        return Semantics(
          container: true,
          label: l10n.invoicePageLinesCaption,
          child: Table(
            columnWidths: {
              0: const FixedColumnWidth(36),
              1: const FlexColumnWidth(),
              if (wide) 2: const FlexColumnWidth(1.4),
            },
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.ink300)),
                ),
                children: [
                  head(l10n.invoicePageColumnIndex, align: TextAlign.center),
                  head(l10n.invoicePageColumnItem),
                  if (wide) head(l10n.invoicePageColumnDescription),
                  head(l10n.invoicePageColumnQuantity, align: TextAlign.center),
                  if (wide) head(l10n.invoicePageColumnUnitCost, align: TextAlign.end),
                  head(l10n.invoicePageColumnTotal, align: TextAlign.end),
                ],
              ),
              for (final (index, line) in invoice.lines.indexed)
                TableRow(
                  decoration: BoxDecoration(
                    color: index.isEven ? colors.ink100.withValues(alpha: 0.45) : null,
                  ),
                  children: [
                    body(Text('${index + 1}', style: cell, textAlign: TextAlign.center)),
                    body(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line.item, style: strong),
                          if (!wide) Text(line.description, style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    if (wide)
                      body(Text(line.description, style: cell.copyWith(color: colors.ink700))),
                    body(Text('${line.quantity}', style: cell, textAlign: TextAlign.center)),
                    if (wide)
                      body(Text(money(line.unitCents), style: cell, textAlign: TextAlign.end)),
                    body(Text(money(line.totalCents), style: strong, textAlign: TextAlign.end)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Subtotal, discount, VAT and the total due.
class _Totals extends StatelessWidget {
  const _Totals({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final totals = invoiceTotals(
      lines: invoice.lines,
      discountRate: invoice.discountRate,
      vatRate: invoice.vatRate,
    );
    String money(int cents) =>
        formatMoney(cents, currency: invoice.currency, localeName: l10n.localeName);
    final rows = [
      (l10n.invoicePageSubtotal, totals.subtotal),
      (l10n.invoicePageDiscount(invoice.discountRate), totals.discount),
      (l10n.invoicePageVat(invoice.vatRate), totals.vat),
      (l10n.invoicePageTotal, totals.total),
    ];
    final label = context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
    final value = context.type.table.copyWith(fontSize: 15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, (name, cents)) in rows.indexed)
          MergeSemantics(
            child: Container(
              key: index == rows.length - 1 ? const Key('invoice.total') : null,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: index == rows.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: colors.ink200)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: index == rows.length - 1
                          ? label?.copyWith(color: colors.ink950)
                          : label,
                    ),
                  ),
                  const SizedBox(width: Space.lg),
                  Text(
                    money(cents),
                    style: index == rows.length - 1
                        ? value.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.ink950,
                          )
                        : value,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
