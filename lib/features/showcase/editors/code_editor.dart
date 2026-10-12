import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/editors/code_theme.dart';
import 'package:flutter_boilerplate/features/showcase/editors/syntax_highlighting.dart';

/// Space the text field keeps after a line for the caret (`RenderEditable`'s caret gap plus
/// the default cursor width), so measured lines wrap where the field wraps them.
const _caretMargin = 1.0 + 2.0;
const _padding = EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm);

/// The index of the line [offset] is on.
int lineIndexAt(String text, int offset) {
  if (offset <= 0) {
    return 0;
  }
  return '\n'.allMatches(text.substring(0, offset.clamp(0, text.length))).length;
}

/// A code editor drawn on a text field (the web uses CodeMirror): highlighting, a gutter of
/// line numbers that follows wrapped lines, and the caret's line highlighted. It grows with its
/// text, so the page scrolls rather than the editor.
class CodeEditor extends StatefulWidget {
  const CodeEditor({
    required this.controller,
    required this.theme,
    required this.label,
    this.minHeight = 320,
    super.key,
  });

  final CodeEditingController controller;
  final CodeTheme theme;

  /// Names the editing area for screen readers.
  final String label;
  final double minHeight;

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  final _focus = FocusNode();
  final _heights = <String, double>{};
  Object? _measuredFor;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  /// The height [line] takes once wrapped at [width] (cached per width and text scale).
  double _heightOf(
    String line,
    TextStyle style,
    StrutStyle strut,
    double width,
    TextScaler scaler,
  ) {
    final key = (width, scaler, style);
    if (_measuredFor != key) {
      _heights.clear();
      _measuredFor = key;
    }
    return _heights.putIfAbsent(line, () {
      final painter = TextPainter(
        text: TextSpan(text: line, style: style),
        textDirection: TextDirection.ltr,
        strutStyle: strut,
        textScaler: scaler,
      )..layout(maxWidth: width);
      final height = painter.height;
      painter.dispose();
      return height;
    });
  }

  double _widthOf(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final controller = widget.controller..theme = theme;
    final style = context.type.code.copyWith(color: theme.text);
    final strut = StrutStyle(
      fontFamily: style.fontFamily,
      fontFamilyFallback: style.fontFamilyFallback,
      fontSize: style.fontSize,
      height: style.height,
      forceStrutHeight: true,
    );
    final scaler = MediaQuery.textScalerOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([controller, _focus]),
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final text = controller.text;
          final lines = text.split('\n');
          final digits = '${lines.length}'.length.clamp(2, 6);
          final gutterWidth = _widthOf('8' * digits, style, scaler) + Space.sm * 2;
          final textWidth = constraints.maxWidth - gutterWidth - _padding.horizontal - _caretMargin;
          final heights = [
            for (final line in lines) _heightOf(line, style, strut, textWidth, scaler),
          ];
          final selection = controller.selection;
          final active = _focus.hasFocus && selection.isValid
              ? lineIndexAt(text, selection.extentOffset)
              : -1;
          var activeTop = _padding.top;
          for (var index = 0; index < active && index < heights.length; index++) {
            activeTop += heights[index];
          }

          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.background,
              border: Border.all(color: theme.border),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              child: Stack(
                children: [
                  // A tap below the text or on the gutter puts the caret in the editor.
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _focus.requestFocus,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: gutterWidth,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.gutter,
                          border: Border(right: BorderSide(color: theme.gutterBorder)),
                        ),
                      ),
                    ),
                  ),
                  if (active >= 0 && active < heights.length)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: activeTop,
                      height: heights[active],
                      child: IgnorePointer(
                        child: Row(
                          children: [
                            SizedBox(
                              width: gutterWidth,
                              child: ColoredBox(color: theme.activeGutter),
                            ),
                            Expanded(child: ColoredBox(color: theme.activeLine)),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: _padding.top),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IgnorePointer(
                          child: SizedBox(
                            width: gutterWidth,
                            child: ExcludeSemantics(
                              child: Column(
                                children: [
                                  for (final (index, height) in heights.indexed)
                                    SizedBox(
                                      height: height,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: Space.sm),
                                        child: Text(
                                          '${index + 1}',
                                          textAlign: TextAlign.right,
                                          strutStyle: strut,
                                          style: style.copyWith(
                                            color: index == active
                                                ? theme.activeGutterText
                                                : theme.gutterText,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: _padding.left),
                            child: TextSelectionTheme(
                              data: TextSelectionTheme.of(context).copyWith(
                                cursorColor: theme.cursor,
                                selectionColor: theme.selection,
                                selectionHandleColor: theme.cursor,
                              ),
                              child: Semantics(
                                label: widget.label,
                                child: TextField(
                                  controller: controller,
                                  focusNode: _focus,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  smartDashesType: SmartDashesType.disabled,
                                  smartQuotesType: SmartQuotesType.disabled,
                                  spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                                  style: style,
                                  strutStyle: strut,
                                  cursorColor: theme.cursor,
                                  keyboardAppearance: theme.background.computeLuminance() < 0.5
                                      ? Brightness.dark
                                      : Brightness.light,
                                  decoration: const InputDecoration(
                                    isCollapsed: true,
                                    filled: false,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
