import 'package:flutter/material.dart';

/// The Marksheet palette (DESIGN.md): folder-green cover, pale card stock, navy form ink, a
/// green tick, a red pen and a graphite pencil. Read it with `context.colors`.
///
/// Material's [ColorScheme] is derived from these tokens in `app_theme.dart`; use the scheme for
/// standard widgets and these names when a screen needs a specific Marksheet surface or ink.
@immutable
class MarksheetColors extends ThemeExtension<MarksheetColors> {
  const MarksheetColors({
    required this.folder,
    required this.folderDeep,
    required this.folderInk,
    required this.folderInkSoft,
    required this.paper,
    required this.paperCard,
    required this.ply,
    required this.ink950,
    required this.ink900,
    required this.ink700,
    required this.ink600,
    required this.ink400,
    required this.ink300,
    required this.ink200,
    required this.ink100,
    required this.pass,
    required this.pen,
    required this.pencil,
    required this.primary,
    required this.onPrimary,
  });

  /// Daylight: the design as specified.
  static const light = MarksheetColors(
    folder: Color(0xFF1F5C45),
    folderDeep: Color(0xFF164433),
    folderInk: Color(0xFFF1F5EF),
    folderInkSoft: Color(0xFFBCD3C5),
    paper: Color(0xFFE8EEE6),
    paperCard: Color(0xFFF5F8F3),
    ply: Color(0xFFFFFFFF),
    ink950: Color(0xFF111B30),
    ink900: Color(0xFF1B2B4B),
    ink700: Color(0xFF33436A),
    ink600: Color(0xFF4A5878),
    ink400: Color(0xFF8A94A9),
    ink300: Color(0xFFB3BCCB),
    ink200: Color(0xFFCFD7DE),
    ink100: Color(0xFFDFE5E6),
    pass: Color(0xFF1F6B4E),
    pen: Color(0xFFC42F2A),
    pencil: Color(0xFF5F666E),
    primary: Color(0xFF1F5C45),
    onPrimary: Color(0xFFF1F5EF),
  );

  /// The same card on a desk at night: the ramps are inverted, the marks lifted for contrast.
  /// The web design is daylight only; phones are expected to follow the system setting.
  static const dark = MarksheetColors(
    folder: Color(0xFF143A2C),
    folderDeep: Color(0xFF0E2A20),
    folderInk: Color(0xFFE6EFE8),
    folderInkSoft: Color(0xFF9FBFAE),
    paper: Color(0xFF0F151E),
    paperCard: Color(0xFF161F2B),
    ply: Color(0xFF1D2735),
    ink950: Color(0xFFF3F6F9),
    ink900: Color(0xFFE2E7EE),
    ink700: Color(0xFFC1C9D6),
    ink600: Color(0xFFA2ACBC),
    ink400: Color(0xFF788396),
    ink300: Color(0xFF4E596B),
    ink200: Color(0xFF354051),
    ink100: Color(0xFF253041),
    pass: Color(0xFF63C295),
    pen: Color(0xFFF2756E),
    pencil: Color(0xFFA9B1BA),
    primary: Color(0xFF6DBB94),
    onPrimary: Color(0xFF07241A),
  );

  /// Cover: hero bands, the menu header, the lock screen.
  final Color folder;
  final Color folderDeep;

  /// Text and icons on [folder].
  final Color folderInk;
  final Color folderInkSoft;

  /// Page background.
  final Color paper;

  /// Cards and sheets.
  final Color paperCard;

  /// Controls that sit on a card: inputs, menus, dialogs.
  final Color ply;

  /// Text ramp, darkest to lightest (light theme). 950 headings, 900 body, 600 secondary.
  final Color ink950;
  final Color ink900;
  final Color ink700;
  final Color ink600;
  final Color ink400;
  final Color ink300;
  final Color ink200;
  final Color ink100;

  /// Passed (green tick), failed (red pen), pending (pencil).
  final Color pass;
  final Color pen;
  final Color pencil;

  /// Filled buttons and focus: [folder] by day, a lighter green by night.
  final Color primary;
  final Color onPrimary;

  @override
  MarksheetColors copyWith({
    Color? folder,
    Color? folderDeep,
    Color? folderInk,
    Color? folderInkSoft,
    Color? paper,
    Color? paperCard,
    Color? ply,
    Color? ink950,
    Color? ink900,
    Color? ink700,
    Color? ink600,
    Color? ink400,
    Color? ink300,
    Color? ink200,
    Color? ink100,
    Color? pass,
    Color? pen,
    Color? pencil,
    Color? primary,
    Color? onPrimary,
  }) => MarksheetColors(
    folder: folder ?? this.folder,
    folderDeep: folderDeep ?? this.folderDeep,
    folderInk: folderInk ?? this.folderInk,
    folderInkSoft: folderInkSoft ?? this.folderInkSoft,
    paper: paper ?? this.paper,
    paperCard: paperCard ?? this.paperCard,
    ply: ply ?? this.ply,
    ink950: ink950 ?? this.ink950,
    ink900: ink900 ?? this.ink900,
    ink700: ink700 ?? this.ink700,
    ink600: ink600 ?? this.ink600,
    ink400: ink400 ?? this.ink400,
    ink300: ink300 ?? this.ink300,
    ink200: ink200 ?? this.ink200,
    ink100: ink100 ?? this.ink100,
    pass: pass ?? this.pass,
    pen: pen ?? this.pen,
    pencil: pencil ?? this.pencil,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
  );

  @override
  MarksheetColors lerp(MarksheetColors? other, double t) {
    if (other == null) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return MarksheetColors(
      folder: mix(folder, other.folder),
      folderDeep: mix(folderDeep, other.folderDeep),
      folderInk: mix(folderInk, other.folderInk),
      folderInkSoft: mix(folderInkSoft, other.folderInkSoft),
      paper: mix(paper, other.paper),
      paperCard: mix(paperCard, other.paperCard),
      ply: mix(ply, other.ply),
      ink950: mix(ink950, other.ink950),
      ink900: mix(ink900, other.ink900),
      ink700: mix(ink700, other.ink700),
      ink600: mix(ink600, other.ink600),
      ink400: mix(ink400, other.ink400),
      ink300: mix(ink300, other.ink300),
      ink200: mix(ink200, other.ink200),
      ink100: mix(ink100, other.ink100),
      pass: mix(pass, other.pass),
      pen: mix(pen, other.pen),
      pencil: mix(pencil, other.pencil),
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
    );
  }
}
