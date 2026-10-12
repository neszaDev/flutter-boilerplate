import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';

/// What a validated demo input checks: nothing, presence, at least 4 characters, or an email.
enum InputRule { optional, required, minLength4, email }

/// Whether [value] passes [rule].
bool passesRule(String value, InputRule rule) => switch (rule) {
  InputRule.optional => true,
  InputRule.required => value.trim().isNotEmpty,
  InputRule.minLength4 => value.length >= 4,
  InputRule.email => emailPattern.hasMatch(value),
};

/// A labelled input that shows its validation state from the first frame and as you type: a
/// pass tick with [validFeedback], or [invalidFeedback] in red pen (the web's `ValidatedInput`).
class ValidatedInput extends StatefulWidget {
  const ValidatedInput({
    required this.label,
    required this.rule,
    this.initialValue,
    this.placeholder,
    this.hint,
    this.validFeedback,
    this.invalidFeedback,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.textInputAction,
    super.key,
  });

  final String label;
  final InputRule rule;
  final String? initialValue;
  final String? placeholder;

  /// Help text under the input, whatever the state.
  final String? hint;
  final String? validFeedback;
  final String? invalidFeedback;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;

  @override
  State<ValidatedInput> createState() => _ValidatedInputState();
}

class _ValidatedInputState extends State<ValidatedInput> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final valid = passesRule(_controller.text, widget.rule);
    OutlineInputBorder passBorder([double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.md),
      borderSide: BorderSide(color: colors.pass, width: width),
    );
    final hint = widget.hint;
    final validFeedback = widget.validFeedback;
    final hintText = hint == null ? null : Text(hint, style: context.text.bodySmall);

    Widget? helper;
    if (valid && validFeedback != null) {
      helper = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Mark(status: TestStatus.passed, size: 14, color: colors.pass),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  validFeedback,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.pass,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          ?hintText,
        ],
      );
    } else if (valid) {
      helper = hintText;
    }

    return LabeledField(
      label: widget.label,
      child: TextFormField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        autocorrect: !widget.obscureText && widget.keyboardType != TextInputType.emailAddress,
        enableSuggestions: !widget.obscureText,
        autofillHints: widget.autofillHints,
        textInputAction: widget.textInputAction,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          enabledBorder: valid ? passBorder() : null,
          focusedBorder: valid ? passBorder(2) : null,
          helper: helper,
          errorText: valid ? null : widget.invalidFeedback,
          // Invalid without a message: the red border, and the hint where the error would be.
          error: valid || widget.invalidFeedback != null
              ? null
              : hintText ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
