import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/device/connectivity.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/icons/brand_icons_data.dart';
import 'package:flutter_boilerplate/features/showcase/icons/brands_screen.dart';
import 'package:flutter_boilerplate/features/showcase/icons/flags_screen.dart';
import 'package:flutter_boilerplate/features/showcase/icons/icon_gallery.dart';
import 'package:flutter_boilerplate/features/showcase/icons/icon_library_screen.dart';
import 'package:flutter_boilerplate/features/showcase/icons/lucide_icons_data.dart';
import 'package:flutter_boilerplate/features/showcase/icons/material_icons_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [home] in the app's theme on a phone-sized screen.
Future<void> _pump(WidgetTester tester, Widget home, {bool dark = false}) async {
  tester.view
    ..devicePixelRatio = 2
    ..physicalSize = const Size(400, 1400) * 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      // No connectivity plugin in tests: the offline banner stays hidden.
      overrides: [isOnlineProvider.overrideWithValue(true)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Records what the app copies; [refuse] makes the clipboard fail instead.
List<String> _fakeClipboard(WidgetTester tester, {bool refuse = false}) {
  final copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
    call,
  ) async {
    if (call.method == 'Clipboard.setData') {
      if (refuse) {
        throw PlatformException(code: 'denied');
      }
      final arguments = call.arguments as Map<Object?, Object?>;
      copied.add(arguments['text'] as String? ?? '');
    }
    return null;
  });
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copied;
}

void main() {
  group('IconLibraryScreen', () {
    testWidgets('counts the Lucide icons, then the Material ones', (tester) async {
      await _pump(tester, const IconLibraryScreen());

      expect(find.text('${lucideIcons.length} icons'), findsOneWidget);
      expect(find.text('Lucide icons'), findsOneWidget);
      expect(find.byTooltip('Lucide website'), findsOneWidget);

      await tester.tap(find.text('Material'));
      await tester.pumpAndSettle();

      expect(find.text('${materialIcons.length} icons'), findsOneWidget);
      expect(find.text('Material icons'), findsOneWidget);
      expect(find.byTooltip('Material icons website'), findsOneWidget);
    });

    testWidgets('filters the icons as you type and says when nothing matches', (tester) async {
      await _pump(tester, const IconLibraryScreen());

      await tester.enterText(find.byType(TextField), 'arrow right');
      await tester.pump();

      expect(find.textContaining('match “arrow right”'), findsOneWidget);
      expect(find.text('arrowRight'), findsOneWidget);
      expect(find.text('calendar'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zebra');
      await tester.pump();

      expect(find.text('No icons match “zebra”'), findsOneWidget);
      expect(find.textContaining('Nothing matches “zebra”'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear the search'));
      await tester.pump();

      expect(find.text('${lucideIcons.length} icons'), findsOneWidget);
    });

    testWidgets('copies the name of a tapped icon and says so for a moment', (tester) async {
      final copied = _fakeClipboard(tester);
      await _pump(tester, const IconLibraryScreen());
      await tester.enterText(find.byType(TextField), 'arrow right');
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('Copy the name LucideIcons.arrowRight'));
      await tester.pump();

      expect(copied, ['LucideIcons.arrowRight']);
      expect(find.text('Copied'), findsOneWidget);

      await tester.pump(CopyNameTile.resetAfter);

      expect(find.text('Copied'), findsNothing);
    });

    testWidgets('says when the clipboard refuses the name', (tester) async {
      _fakeClipboard(tester, refuse: true);
      await _pump(tester, const IconLibraryScreen());

      await tester.tap(find.byType(CopyNameTile).first);
      await tester.pump();

      expect(find.text('Copy failed'), findsOneWidget);

      await tester.pump(CopyNameTile.resetAfter);
    });
  });

  group('BrandsScreen', () {
    testWidgets('shows the brand marks and copies their Font Awesome names', (tester) async {
      final copied = _fakeClipboard(tester);
      await _pump(tester, const BrandsScreen(), dark: true);

      expect(find.text('${brandIcons.length} icons'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'github');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Copy the name FontAwesomeIcons.github'));
      await tester.pump();

      expect(copied, ['FontAwesomeIcons.github']);

      await tester.pump(CopyNameTile.resetAfter);
    });
  });

  group('FlagsScreen', () {
    testWidgets('shows the emoji flags and copies their country codes', (tester) async {
      final copied = _fakeClipboard(tester);
      await _pump(tester, const FlagsScreen());

      expect(find.text('198 icons'), findsOneWidget);
      expect(find.text('🇦🇩'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'fr');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Copy the name FR'));
      await tester.pump();

      expect(copied, ['FR']);

      await tester.pump(CopyNameTile.resetAfter);
    });
  });
}
