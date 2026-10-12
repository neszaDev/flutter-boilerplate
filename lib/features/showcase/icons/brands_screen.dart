import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/features/showcase/icons/brand_icons_data.dart';
import 'package:flutter_boilerplate/features/showcase/icons/icon_gallery.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _names = brandIcons.keys.toList(growable: false);

/// `/dashboard/icons/brands`: the Font Awesome brand marks, searchable, each name a tap away
/// from the clipboard.
class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IconGalleryScreen(
      title: l10n.brandsPageTitle,
      description: l10n.brandsPageDescription,
      galleryTitle: l10n.brandsPageGalleryTitle,
      galleryDescription: l10n.brandsPageGalleryDescription,
      names: _names,
      iconSize: 40,
      iconBuilder: (context, name) => FaIcon(brandIcons[name], size: 40),
      copyText: (name) => 'FontAwesomeIcons.$name',
    );
  }
}
