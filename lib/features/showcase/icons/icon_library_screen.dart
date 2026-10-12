import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/features/showcase/icons/icon_gallery.dart';
import 'package:flutter_boilerplate/features/showcase/icons/lucide_icons_data.dart';
import 'package:flutter_boilerplate/features/showcase/icons/material_icons_data.dart';

/// The icon sets the app bundles.
enum IconSet { lucide, material }

final _lucideNames = lucideIcons.keys.toList(growable: false);
final _materialNames = materialIcons.keys.toList(growable: false);

/// `/dashboard/icons/coreui-icons`: the icon library the app actually ships, Lucide (the web
/// app's set) and Material Icons, searchable, each name a tap away from the clipboard.
class IconLibraryScreen extends StatefulWidget {
  const IconLibraryScreen({super.key});

  @override
  State<IconLibraryScreen> createState() => _IconLibraryScreenState();
}

class _IconLibraryScreenState extends State<IconLibraryScreen> {
  var _set = IconSet.lucide;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lucide = _set == IconSet.lucide;
    return IconGalleryScreen(
      title: l10n.coreuiIconsPageTitle,
      description: l10n.coreuiIconsPageDescription,
      galleryTitle: lucide ? l10n.coreuiIconsPageGalleryTitle : l10n.coreuiIconsPageMaterialTitle,
      galleryDescription: lucide
          ? l10n.coreuiIconsPageGalleryDescription
          : l10n.coreuiIconsPageMaterialDescription,
      galleryAction: lucide
          ? WebsiteLink(
              label: l10n.coreuiIconsPageWebsite,
              url: Uri.https('lucide.dev', '/icons/'),
            )
          : WebsiteLink(
              label: l10n.coreuiIconsPageMaterialWebsite,
              url: Uri.https('fonts.google.com', '/icons'),
            ),
      header: Semantics(
        container: true,
        label: l10n.coreuiIconsPageSetLabel,
        child: SegmentedButton<IconSet>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: IconSet.lucide, label: Text(l10n.coreuiIconsPageSetLucide)),
            ButtonSegment(value: IconSet.material, label: Text(l10n.coreuiIconsPageSetMaterial)),
          ],
          selected: {_set},
          onSelectionChanged: (selection) {
            Haptics.selection();
            setState(() => _set = selection.first);
          },
        ),
      ),
      names: lucide ? _lucideNames : _materialNames,
      iconBuilder: (context, name) =>
          Icon(lucide ? lucideIcons[name] : materialIcons[name], size: 24),
      copyText: (name) => lucide ? 'LucideIcons.$name' : 'Icons.$name',
    );
  }
}
