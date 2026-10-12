import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/qr_code_card.dart';

/// `/dashboard/campus/qr-code`: the campus QR code card.
class CampusQrCodeScreen extends StatelessWidget {
  const CampusQrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.campusQrCodePageTitle,
      description: Text(l10n.campusQrCodePageDescription),
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            // The web's max-w-md: the card stays phone-sized on a tablet.
            constraints: const BoxConstraints(maxWidth: 448),
            child: const QrCodeCard(),
          ),
        ),
      ],
    );
  }
}
