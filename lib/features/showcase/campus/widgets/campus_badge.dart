import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The campus emblem at the top of the sign-in dialogs, where the web app shows the MFU logo
/// (the app bundles no university artwork). Decorative.
class CampusBadge extends StatelessWidget {
  const CampusBadge({this.size = 64, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.folder,
          border: Border.all(color: colors.pen, width: 3),
        ),
        child: Icon(LucideIcons.graduationCap, size: size * 0.5, color: colors.folderInk),
      ),
    );
  }
}
