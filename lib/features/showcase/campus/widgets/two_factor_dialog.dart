import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/campus/two_factor.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/campus_badge.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/loading_overlay.dart';

/// Called with a failed step; resolves to true when the two-factor dialog should close.
typedef TwoFactorFailureHandler = Future<bool> Function(TwoFactorFailure failure);

/// The two-factor code step (Vue `TwoFA`): six letters or digits, sent as soon as the last one
/// is typed, with a button to ask for a new code. Requests run under the loading overlay;
/// failures go to [onFailure] (the error dialog).
class TwoFactorDialog extends StatefulWidget {
  const TwoFactorDialog({required this.email, required this.onFailure, super.key});

  /// Address the code was sent to.
  final String email;
  final TwoFactorFailureHandler onFailure;

  @override
  State<TwoFactorDialog> createState() => _TwoFactorDialogState();
}

class _TwoFactorDialogState extends State<TwoFactorDialog> {
  final _code = TextEditingController();
  var _incomplete = false;
  var _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<TwoFactorResult> Function() request) async {
    if (_busy) {
      return;
    }
    _busy = true;
    final result = await showLoadingOverlay(context, request);
    _busy = false;
    if (!mounted) {
      return;
    }
    _code.clear();
    setState(() => _incomplete = false);
    switch (result) {
      case TwoFactorVerified():
        Navigator.pop(context);
      case final TwoFactorFailure failure:
        final close = await widget.onFailure(failure);
        if (close && mounted) {
          Navigator.pop(context);
        }
    }
  }

  void _submit(String value) {
    if (value.length < twoFactorCodeLength) {
      setState(() => _incomplete = true);
      return;
    }
    _run(() => verifyTwoFactorCode(value)).ignore();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final secondary = context.text.bodyMedium?.copyWith(color: colors.ink600);
    return AlertDialog(
      scrollable: true,
      semanticLabel: l10n.campusTwoFactorTitle,
      title: Column(
        children: [
          const CampusBadge(size: 56),
          const SizedBox(height: Space.md),
          Text(l10n.campusTwoFactorTitle, textAlign: TextAlign.center),
        ],
      ),
      content: Column(
        children: [
          Text(l10n.campusTwoFactorPriority, textAlign: TextAlign.center),
          Text(l10n.campusTwoFactorInstructions, textAlign: TextAlign.center),
          const SizedBox(height: Space.xs),
          Text(
            l10n.campusTwoFactorSentTo(widget.email),
            textAlign: TextAlign.center,
            style: context.text.titleSmall,
          ),
          const SizedBox(height: Space.card),
          CodeField(
            controller: _code,
            label: l10n.campusTwoFactorCodeLabel,
            onChanged: (value) {
              if (_incomplete) {
                setState(() => _incomplete = false);
              }
              if (value.length == twoFactorCodeLength) {
                _submit(value);
              }
            },
            onSubmitted: _submit,
          ),
          Semantics(
            container: true,
            liveRegion: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Space.lg),
              child: Padding(
                padding: const EdgeInsets.only(top: Space.sm),
                child: Text(
                  _incomplete ? l10n.campusTwoFactorIncomplete('$twoFactorCodeLength') : '',
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.pen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.sm),
          Text(l10n.campusTwoFactorDelay, textAlign: TextAlign.center, style: secondary),
          Text(l10n.campusTwoFactorNotReceived, textAlign: TextAlign.center, style: secondary),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            onPressed: () => _run(sendTwoFactorCode),
            child: Text(l10n.campusTwoFactorResend),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.campusTwoFactorClose)),
      ],
    );
  }
}

/// A one-time code input drawn as [twoFactorCodeLength] boxes. One text field underneath takes
/// the typing, pasting and the keyboard's code suggestion; only letters and digits get in.
class CodeField extends StatefulWidget {
  const CodeField({
    required this.controller,
    required this.label,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;

  /// Read by screen readers.
  final String label;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_redraw);
    widget.controller.addListener(_redraw);
  }

  @override
  void didUpdateWidget(CodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_redraw);
      widget.controller.addListener(_redraw);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_redraw);
    _focus.dispose();
    super.dispose();
  }

  void _redraw() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final code = widget.controller.text;
    return Stack(
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              for (var index = 0; index < twoFactorCodeLength; index++) ...[
                if (index > 0) const SizedBox(width: Space.xs + 2),
                Expanded(
                  child: _Slot(
                    char: index < code.length ? code[index] : '',
                    active:
                        _focus.hasFocus &&
                        (index == code.length ||
                            (code.length == twoFactorCodeLength &&
                                index == twoFactorCodeLength - 1)),
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned.fill(
          child: Semantics(
            label: widget.label,
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              autofocus: true,
              showCursor: false,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                LengthLimitingTextInputFormatter(twoFactorCodeLength),
              ],
              // The boxes show the characters; the field itself stays invisible.
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),
        ),
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.char, required this.active});

  final String char;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primary = Theme.of(context).colorScheme.primary;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 48),
      child: AspectRatio(
        aspectRatio: 0.85,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.ply,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: active ? primary : colors.ink300, width: active ? 2 : 1),
          ),
          child: Text(
            char,
            style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
