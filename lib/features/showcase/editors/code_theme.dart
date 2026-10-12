import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';

/// The two themes of the code editor demo, as on the web.
enum CodeThemeName { paper, night }

/// Colours of the code editor: its surfaces and one colour per highlight.js token class.
///
/// The syntax colours are the only hard-coded colours of the showcase: "paper" takes its
/// surfaces from the Marksheet tokens and has token colours for the light and the dark app
/// theme; "night" is CodeMirror's One Dark, dark whatever the app theme.
@immutable
class CodeTheme {
  const CodeTheme({
    required this.background,
    required this.text,
    required this.gutter,
    required this.gutterText,
    required this.gutterBorder,
    required this.activeLine,
    required this.activeGutter,
    required this.activeGutterText,
    required this.cursor,
    required this.selection,
    required this.border,
    required this.tokens,
  });

  /// Marksheet paper: a white ply page, a card-stock gutter, navy ink and a folder-green caret
  /// (in the dark app theme, the same tokens at night).
  factory CodeTheme.paper(MarksheetColors colors, Brightness brightness) => CodeTheme(
    background: colors.ply,
    text: colors.ink900,
    gutter: colors.paperCard,
    gutterText: colors.ink400,
    gutterBorder: colors.ink200,
    activeLine: colors.paperCard,
    activeGutter: colors.ink100,
    activeGutterText: colors.ink700,
    cursor: colors.primary,
    selection: colors.ink200,
    border: colors.ink300,
    tokens: brightness == Brightness.light ? _paperLight : _paperDark,
  );

  /// CodeMirror's One Dark.
  static const night = CodeTheme(
    background: Color(0xFF282C34),
    text: Color(0xFFABB2BF),
    gutter: Color(0xFF282C34),
    gutterText: Color(0xFF7D8799),
    gutterBorder: Color(0xFF282C34),
    activeLine: Color(0xFF2C313A),
    activeGutter: Color(0xFF2C313A),
    activeGutterText: Color(0xFFABB2BF),
    cursor: Color(0xFF528BFF),
    selection: Color(0xFF3E4451),
    border: Color(0xFF181A1F),
    tokens: _oneDark,
  );

  /// The theme called [name] for the app's [colors] and [brightness].
  static CodeTheme of(CodeThemeName name, MarksheetColors colors, Brightness brightness) =>
      switch (name) {
        CodeThemeName.paper => CodeTheme.paper(colors, brightness),
        CodeThemeName.night => night,
      };

  final Color background;
  final Color text;
  final Color gutter;
  final Color gutterText;
  final Color gutterBorder;
  final Color activeLine;
  final Color activeGutter;
  final Color activeGutterText;
  final Color cursor;
  final Color selection;
  final Color border;

  /// highlight.js class name → colour.
  final Map<String, Color> tokens;

  /// The colour of a token class, or null to keep the text colour. Only colours change, never
  /// the weight or slant, so highlighted lines wrap like plain ones.
  Color? colorOf(String? className) => className == null ? null : tokens[className];
}

const _paperLight = <String, Color>{
  'keyword': Color(0xFF1F5C45),
  'built_in': Color(0xFF0E6E7E),
  'literal': Color(0xFF7A3E9D),
  'number': Color(0xFF7A3E9D),
  'string': Color(0xFFA0461F),
  'comment': Color(0xFF5F666E),
  'quote': Color(0xFF5F666E),
  'meta': Color(0xFF5F666E),
  'meta-keyword': Color(0xFF1F5C45),
  'meta-string': Color(0xFFA0461F),
  'doctag': Color(0xFF1F5C45),
  'title': Color(0xFF1D4E89),
  'function': Color(0xFF1D4E89),
  'name': Color(0xFF1F5C45),
  'attr': Color(0xFF7A3E9D),
  'attribute': Color(0xFF1D4E89),
  'tag': Color(0xFF4A5878),
  'section': Color(0xFF1F5C45),
  'link': Color(0xFF1D4E89),
  'symbol': Color(0xFF1D4E89),
  'bullet': Color(0xFFC42F2A),
  'code': Color(0xFFA0461F),
  'variable': Color(0xFFA0461F),
  'regexp': Color(0xFF0E6E7E),
  'type': Color(0xFF0E6E7E),
  'class': Color(0xFF0E6E7E),
  'selector-tag': Color(0xFF1F5C45),
  'selector-class': Color(0xFF7A3E9D),
  'selector-id': Color(0xFF7A3E9D),
};

const _paperDark = <String, Color>{
  'keyword': Color(0xFF6DBB94),
  'built_in': Color(0xFF5CC8D8),
  'literal': Color(0xFFC9A0F0),
  'number': Color(0xFFC9A0F0),
  'string': Color(0xFFF0A27A),
  'comment': Color(0xFF97A1B3),
  'quote': Color(0xFF97A1B3),
  'meta': Color(0xFF97A1B3),
  'meta-keyword': Color(0xFF6DBB94),
  'meta-string': Color(0xFFF0A27A),
  'doctag': Color(0xFF6DBB94),
  'title': Color(0xFF8AB4F8),
  'function': Color(0xFF8AB4F8),
  'name': Color(0xFF6DBB94),
  'attr': Color(0xFFC9A0F0),
  'attribute': Color(0xFF8AB4F8),
  'tag': Color(0xFFA2ACBC),
  'section': Color(0xFF6DBB94),
  'link': Color(0xFF8AB4F8),
  'symbol': Color(0xFF8AB4F8),
  'bullet': Color(0xFFF2756E),
  'code': Color(0xFFF0A27A),
  'variable': Color(0xFFF0A27A),
  'regexp': Color(0xFF5CC8D8),
  'type': Color(0xFF5CC8D8),
  'class': Color(0xFF5CC8D8),
  'selector-tag': Color(0xFF6DBB94),
  'selector-class': Color(0xFFC9A0F0),
  'selector-id': Color(0xFFC9A0F0),
};

const _oneDark = <String, Color>{
  'keyword': Color(0xFFC678DD),
  'built_in': Color(0xFFE5C07B),
  'literal': Color(0xFFD19A66),
  'number': Color(0xFFE5C07B),
  'string': Color(0xFF98C379),
  'comment': Color(0xFF7D8799),
  'quote': Color(0xFF7D8799),
  'meta': Color(0xFF7D8799),
  'meta-keyword': Color(0xFFC678DD),
  'meta-string': Color(0xFF98C379),
  'doctag': Color(0xFFC678DD),
  'title': Color(0xFF61AFEF),
  'function': Color(0xFF61AFEF),
  'name': Color(0xFFE06C75),
  'attr': Color(0xFFD19A66),
  'attribute': Color(0xFF61AFEF),
  'tag': Color(0xFFABB2BF),
  'section': Color(0xFFE06C75),
  'link': Color(0xFF56B6C2),
  'symbol': Color(0xFF56B6C2),
  'bullet': Color(0xFF61AFEF),
  'code': Color(0xFF98C379),
  'variable': Color(0xFFE06C75),
  'regexp': Color(0xFF56B6C2),
  'type': Color(0xFFE5C07B),
  'class': Color(0xFFE5C07B),
  'selector-tag': Color(0xFFE06C75),
  'selector-class': Color(0xFFD19A66),
  'selector-id': Color(0xFF61AFEF),
};
