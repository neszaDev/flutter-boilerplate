import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/features/showcase/icons/flags_data.dart';
import 'package:flutter_boilerplate/features/showcase/icons/gallery.dart';
import 'package:flutter_boilerplate/features/showcase/icons/icon_gallery.dart';

const _flagHeight = 40.0;

/// `/dashboard/icons/flags`: emoji flags by country code, searchable, each code a tap away from
/// the clipboard. Nothing to bundle: the phone draws them.
class FlagsScreen extends StatelessWidget {
  const FlagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IconGalleryScreen(
      title: l10n.flagsPageTitle,
      description: l10n.flagsPageDescription,
      galleryTitle: l10n.flagsPageGalleryTitle,
      galleryDescription: l10n.flagsPageGalleryDescription,
      names: flagCodes,
      iconSize: _flagHeight,
      iconBuilder: (context, code) => SizedBox(
        height: _flagHeight,
        child: Center(
          child: Text(
            flagEmoji(code),
            // The flag fills the fixed tile slot; the name under it scales instead.
            textScaler: TextScaler.noScaling,
            style: const TextStyle(fontSize: 32, height: 1),
          ),
        ),
      ),
      copyText: (code) => code,
    );
  }
}
