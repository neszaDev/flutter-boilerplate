import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The product name with its tick. [onFolder] for the green cover.
class Wordmark extends StatelessWidget {
  const Wordmark({this.onFolder = false, this.size = 20, super.key});

  final bool onFolder;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: AppConfig.name,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Mark(
            status: TestStatus.passed,
            size: size * 1.2,
            color: onFolder ? colors.folderInkSoft : null,
          ),
          const SizedBox(width: Space.sm),
          Text(
            AppConfig.name,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: onFolder ? colors.folderInk : colors.ink950,
            ),
          ),
        ],
      ),
    );
  }
}

/// The language picker. Shows each language in its own name; "system" follows the phone.
class LocaleSwitcher extends ConsumerWidget {
  const LocaleSwitcher({this.onFolder = false, super.key});

  final bool onFolder;

  static const _names = {'en': 'English', 'fr': 'Français'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = Localizations.localeOf(context).languageCode;
    final color = onFolder ? context.colors.folderInk : context.colors.ink700;
    return PopupMenuButton<String>(
      tooltip: context.l10n.localeSwitcherChangeLanguage,
      initialValue: current,
      onSelected: (code) => ref.read(settingsProvider.notifier).setLocale(Locale(code)),
      itemBuilder: (context) => [
        for (final locale in AppConfig.locales)
          PopupMenuItem(
            value: locale.languageCode,
            child: Text(_names[locale.languageCode] ?? locale.languageCode),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate, size: 18, color: color),
            const SizedBox(width: Space.xs),
            Text(
              current.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// The language names for settings, in their own language.
String languageName(String code) => LocaleSwitcher._names[code] ?? code;
