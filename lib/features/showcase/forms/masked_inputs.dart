import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// A fixed pattern for a field: each [filter] key in [mask] takes one matching character, the
/// rest is printed as is.
@immutable
class MaskSpec {
  MaskSpec({
    required this.mask,
    required this.placeholderChar,
    Map<String, RegExp>? filter,
    this.alwaysShow = false,
  }) : filter = filter ?? {'#': RegExp('[0-9]')};

  final String mask;
  final Map<String, RegExp> filter;

  /// Drawn where a character is still to come.
  final String placeholderChar;

  /// Show the guide even before the field is focused.
  final bool alwaysShow;

  /// The whole pattern with placeholders, e.g. `__/__/____`.
  String get guide =>
      mask.split('').map((char) => filter.containsKey(char) ? placeholderChar : char).join();

  MaskTextInputFormatter formatter() => MaskTextInputFormatter(mask: mask, filter: filter);
}

/// What the field shows: the typed [text], then the rest of the guide (like vue-text-mask and
/// IMask's guide on the web). Without [showGuide], just the text.
String maskDisplay(MaskSpec spec, String text, {required bool showGuide}) {
  final guide = spec.guide;
  if (!showGuide || text.length >= guide.length) {
    return text;
  }
  return text + guide.substring(text.length);
}

/// The masked fields of the advanced forms page.
enum MaskField { date, phone, taxId, ssn, eyeScript, cardNumber }

/// The masks of the web page, written for mask_text_input_formatter (`#` is any digit).
final maskSpecs = <MaskField, MaskSpec>{
  MaskField.date: MaskSpec(
    mask: 'D#/D#/####',
    filter: {'D': RegExp('[0-3]'), '#': RegExp('[0-9]')},
    placeholderChar: '_',
    alwaysShow: true,
  ),
  MaskField.phone: MaskSpec(
    mask: '(N##) ###-####',
    filter: {'N': RegExp('[1-9]'), '#': RegExp('[0-9]')},
    placeholderChar: '#',
  ),
  MaskField.taxId: MaskSpec(mask: '##-#######', placeholderChar: '#'),
  MaskField.ssn: MaskSpec(mask: '###-##-####', placeholderChar: '#'),
  MaskField.eyeScript: MaskSpec(mask: '~#.## ~#.## ###', placeholderChar: '#'),
  MaskField.cardNumber: MaskSpec(mask: '#### #### #### ####', placeholderChar: '#'),
};

const _examples = {
  MaskField.date: '99/99/9999',
  MaskField.phone: '(999) 999-9999',
  MaskField.taxId: '99-9999999',
  MaskField.ssn: '999-99-9999',
  MaskField.eyeScript: '~9.99 ~9.99 999',
  MaskField.cardNumber: '9999 9999 9999 9999',
};

const _icons = {
  MaskField.date: LucideIcons.calendar,
  MaskField.phone: LucideIcons.phone,
  MaskField.taxId: LucideIcons.circleDollarSign,
  MaskField.ssn: LucideIcons.user,
  MaskField.eyeScript: LucideIcons.droplet,
  MaskField.cardNumber: LucideIcons.creditCard,
};

String _labelOf(AppLocalizations l10n, MaskField field) => switch (field) {
  MaskField.date => l10n.advancedFormsPageMaskDate,
  MaskField.phone => l10n.advancedFormsPageMaskPhone,
  MaskField.taxId => l10n.advancedFormsPageMaskTaxId,
  MaskField.ssn => l10n.advancedFormsPageMaskSsn,
  MaskField.eyeScript => l10n.advancedFormsPageMaskEyeScript,
  MaskField.cardNumber => l10n.advancedFormsPageMaskCardNumber,
};

/// Date, phone, taxpayer id, social security number, eye script and card number, each typed
/// into a fixed pattern (the web's `MaskedInputs`).
class MaskedInputs extends StatelessWidget {
  const MaskedInputs({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, field) in MaskField.values.indexed) ...[
          if (index > 0) const SizedBox(height: Space.card),
          MaskedField(
            key: ValueKey('masked-${field.name}'),
            label: _labelOf(l10n, field),
            hint: l10n.advancedFormsPageMaskExample(_examples[field]!),
            icon: _icons[field]!,
            spec: maskSpecs[field]!,
            keyboardType: field == MaskField.phone ? TextInputType.phone : TextInputType.number,
          ),
        ],
      ],
    );
  }
}

/// One masked field: an icon addon, the input, and the guide drawn behind what you typed.
class MaskedField extends StatefulWidget {
  const MaskedField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.spec,
    this.keyboardType = TextInputType.number,
    super.key,
  });

  final String label;

  /// The example under the field.
  final String hint;
  final IconData icon;
  final MaskSpec spec;
  final TextInputType keyboardType;

  @override
  State<MaskedField> createState() => _MaskedFieldState();
}

class _MaskedFieldState extends State<MaskedField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  late final _formatter = widget.spec.formatter();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _focus.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final focused = _focus.hasFocus;
    final text = _controller.text;
    final showGuide = widget.spec.alwaysShow || focused || text.isNotEmpty;
    // The guide and the input share one style, so the guide lines up with the typed text.
    final style = context.text.bodyLarge!.copyWith(
      fontSize: 16,
      height: 1.4,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final strut = StrutStyle.fromTextStyle(style, forceStrutHeight: true);
    const padding = EdgeInsets.symmetric(vertical: 11);
    final display = maskDisplay(widget.spec, text, showGuide: showGuide);

    return LabeledField(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.ply,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: focused ? colors.primary : colors.ink300),
              boxShadow: [
                if (focused)
                  BoxShadow(color: colors.primary.withValues(alpha: 0.2), spreadRadius: 3),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Icon(widget.icon, size: 18, color: colors.ink600),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ExcludeSemantics(
                          child: Padding(
                            padding: padding,
                            child: Text.rich(
                              TextSpan(
                                style: style,
                                children: [
                                  TextSpan(
                                    text: text,
                                    style: const TextStyle(color: Colors.transparent),
                                  ),
                                  TextSpan(
                                    text: display.substring(text.length),
                                    style: TextStyle(color: colors.ink400),
                                  ),
                                ],
                              ),
                              strutStyle: strut,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                      Semantics(
                        hint: widget.hint,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          inputFormatters: [_formatter],
                          keyboardType: widget.keyboardType,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: style,
                          strutStyle: strut,
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            filled: false,
                            contentPadding: padding,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.md),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ExcludeSemantics(child: Text(widget.hint, style: context.text.bodySmall)),
        ],
      ),
    );
  }
}
