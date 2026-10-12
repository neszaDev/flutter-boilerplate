import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// A card-header link to a library's documentation, opened in the browser.
class EditorDocsLink extends StatelessWidget {
  const EditorDocsLink({required this.url, required this.label, required this.title, super.key});

  final String url;

  /// Visible text, such as "Docs".
  final String label;

  /// What the link opens, naming the library (tooltip and screen reader label).
  final String title;

  Future<void> _open() async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => Tooltip(
    message: title,
    child: TextButton.icon(
      onPressed: _open,
      iconAlignment: IconAlignment.end,
      icon: const Icon(LucideIcons.externalLink, size: 16),
      label: Text(label),
    ),
  );
}
