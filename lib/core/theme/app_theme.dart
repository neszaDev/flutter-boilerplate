import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';

/// Radii and spacing from DESIGN.md (`rounded`, `spacing`).
abstract final class Radii {
  static const sm = 3.6;
  static const md = 4.8;
  static const lg = 6.0;
  static const xl = 8.4;
}

abstract final class Space {
  static const hairline = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const page = 16.0;
  static const card = 20.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const section = 48.0;
}

const _sans = 'LibreFranklin';
const _hand = 'Kalam';
const _tabular = [FontFeature.tabularFigures()];

/// Typography that Material's [TextTheme] has no slot for. Use with `context.type`.
@immutable
class MarksheetType {
  const MarksheetType(this.colors);

  final MarksheetColors colors;

  /// Tracked small caps for field labels and column heads. Upper-case the text yourself.
  TextStyle get formLabel => TextStyle(
    fontFamily: _sans,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 1.32,
    color: colors.ink600,
  );

  /// Big tabular numbers: totals, scores.
  TextStyle get figure => TextStyle(
    fontFamily: _sans,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.75,
    fontFeatures: _tabular,
    color: colors.ink950,
  );

  /// Rows of a table or list, with tabular figures.
  TextStyle get table => TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    height: 1.43,
    fontFeatures: _tabular,
    color: colors.ink900,
  );

  /// The hand that fills in the form: remarks, row notes.
  TextStyle get handRemark =>
      TextStyle(fontFamily: _hand, fontSize: 22, height: 1.375, color: colors.ink700);

  TextStyle get handNote =>
      TextStyle(fontFamily: _hand, fontSize: 15, height: 1.375, color: colors.ink600);

  /// Monospace for code samples.
  TextStyle get code => TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: const ['Menlo', 'Roboto Mono', 'Courier'],
    fontSize: 13,
    height: 1.5,
    color: colors.ink900,
  );
}

/// Builds the light and dark Material themes from the Marksheet tokens.
abstract final class AppTheme {
  static ThemeData light() => _build(MarksheetColors.light, Brightness.light);

  static ThemeData dark() => _build(MarksheetColors.dark, Brightness.dark);

  static ThemeData _build(MarksheetColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.folderInkSoft,
      onPrimaryContainer: c.folderDeep,
      secondary: c.ink700,
      onSecondary: c.ply,
      secondaryContainer: c.ink100,
      onSecondaryContainer: c.ink900,
      tertiary: c.pass,
      onTertiary: c.ply,
      error: c.pen,
      onError: brightness == Brightness.light ? c.ply : c.paper,
      surface: c.paper,
      onSurface: c.ink900,
      onSurfaceVariant: c.ink600,
      surfaceContainerLowest: c.ply,
      surfaceContainerLow: c.paperCard,
      surfaceContainer: c.paperCard,
      surfaceContainerHigh: c.ply,
      surfaceContainerHighest: c.ink100,
      outline: c.ink300,
      outlineVariant: c.ink200,
      inverseSurface: c.ink950,
      onInverseSurface: c.paper,
      inversePrimary: c.folderInkSoft,
      shadow: const Color(0xFF111B30),
      scrim: const Color(0xFF111B30),
    );

    final text = TextTheme(
      displayLarge: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w800,
        height: 1.02,
        letterSpacing: -1.54,
        color: c.ink950,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 1.05,
        letterSpacing: -1.1,
        color: c.ink950,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.11,
        letterSpacing: -0.8,
        color: c.ink950,
      ),
      // The page title (`PageHeader`).
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.56,
        color: c.ink950,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.4,
        color: c.ink950,
      ),
      // Card and section titles.
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.375,
        letterSpacing: -0.18,
        color: c.ink950,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: c.ink950,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        color: c.ink900,
      ),
      // The lead paragraph.
      bodyLarge: TextStyle(fontSize: 17, height: 1.55, color: c.ink900),
      bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: c.ink900),
      bodySmall: TextStyle(fontSize: 13, height: 1.45, color: c.ink600),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        color: c.ink900,
      ),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.ink700),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.32,
        color: c.ink600,
      ),
    ).apply(fontFamily: _sans);

    final controlShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md));
    const buttonSize = Size(64, 44);
    const buttonPadding = EdgeInsets.symmetric(horizontal: Space.page);
    final buttonText = text.labelLarge;

    OutlineInputBorder inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.md),
      borderSide: BorderSide(color: color, width: width),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: _sans,
      textTheme: text,
      scaffoldBackgroundColor: c.paper,
      canvasColor: c.paper,
      dividerColor: c.ink200,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.paper,
        foregroundColor: c.ink950,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: c.ink300,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: c.paperCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          side: BorderSide(color: c.ink300),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.ink200, thickness: 1, space: 1),
      // Colours come from the scheme (primary = folder), so FilledButton.tonal keeps its own
      // secondary container (ink-100) instead of turning green too.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          disabledBackgroundColor: c.ink200,
          disabledForegroundColor: c.ink600,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.ply,
          foregroundColor: c.ink900,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: controlShape,
          textStyle: buttonText,
          elevation: 1,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.ply,
          foregroundColor: c.ink900,
          side: BorderSide(color: c.ink300),
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.ink700,
          minimumSize: const Size(48, 44),
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: c.ink700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.ply,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 12),
        hintStyle: TextStyle(color: c.ink400),
        helperStyle: text.bodySmall,
        errorStyle: TextStyle(color: c.pen, fontSize: 13, fontWeight: FontWeight.w500),
        border: inputBorder(c.ink300),
        enabledBorder: inputBorder(c.ink300),
        focusedBorder: inputBorder(c.primary, 2),
        errorBorder: inputBorder(c.pen),
        focusedErrorBorder: inputBorder(c.pen, 2),
        disabledBorder: inputBorder(c.ink200),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(c.ply)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.ply,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: c.ink200),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.ply),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.ply,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.ink700),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.paperCard,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.ink300,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.ink950,
        contentTextStyle: TextStyle(fontFamily: _sans, color: c.paper, fontSize: 14),
        actionTextColor: c.folderInkSoft,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.paperCard,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.primary.withValues(alpha: 0.14),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: _sans,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? c.ink950 : c.ink600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected) ? c.primary : c.ink600,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.ink700,
        textColor: c.ink900,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.page),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.onPrimary : c.ink400,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.primary : c.ink100,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.primary : c.ink300,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.primary : c.ply,
        ),
        checkColor: WidgetStatePropertyAll(c.onPrimary),
        side: BorderSide(color: c.ink400, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.primary : c.ink400,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primary,
        inactiveTrackColor: c.ink200,
        thumbColor: c.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.ink100,
        circularTrackColor: c.ink100,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.ink950,
        unselectedLabelColor: c.ink600,
        indicatorColor: c.primary,
        dividerColor: c.ink200,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.ply,
        selectedColor: c.primary.withValues(alpha: 0.14),
        side: BorderSide(color: c.ink300),
        labelStyle: text.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
      ),
      badgeTheme: BadgeThemeData(backgroundColor: c.pen, textColor: c.ply),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.ink950,
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        textStyle: TextStyle(fontFamily: _sans, color: c.paper, fontSize: 13),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: c.ink700,
        collapsedIconColor: c.ink600,
        textColor: c.ink950,
        collapsedTextColor: c.ink900,
        shape: const Border(),
        collapsedShape: const Border(),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl * 2)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.ply,
          selectedBackgroundColor: c.primary.withValues(alpha: 0.14),
          selectedForegroundColor: c.ink950,
          side: BorderSide(color: c.ink300),
        ),
      ),
    );
  }
}

/// Shortcuts: `context.colors.pen`, `context.type.formLabel`, `context.text.titleLarge`.
extension ThemeContext on BuildContext {
  MarksheetColors get colors => Theme.of(this).extension<MarksheetColors>()!;

  MarksheetType get type => MarksheetType(colors);

  TextTheme get text => Theme.of(this).textTheme;
}
