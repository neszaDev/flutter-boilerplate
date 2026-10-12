import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/forms/form_demo_widgets.dart';
import 'package:flutter_boilerplate/features/showcase/forms/showcase_sign_up_validation.dart';

const _textFields = [
  SignUpField.firstName,
  SignUpField.lastName,
  SignUpField.userName,
  SignUpField.email,
  SignUpField.password,
  SignUpField.confirmPassword,
];

/// A sign-up form checked by [validateShowcaseSignUp], as the web does with react-hook-form and
/// zod: each field shows its state once you edit it, "Validate" checks them all, "Submit" is
/// enabled only when the whole form is valid, and "Reset" empties it. The live values are
/// printed under the form, on a panel that turns to the pass colour once submitted.
class SignUpValidationForm extends StatefulWidget {
  const SignUpValidationForm({super.key});

  @override
  State<SignUpValidationForm> createState() => _SignUpValidationFormState();
}

class _SignUpValidationFormState extends State<SignUpValidationForm> {
  final _controllers = {for (final field in _textFields) field: TextEditingController()};
  var _values = const ShowcaseSignUpValues();
  final _edited = <SignUpField>{};
  bool _validated = false;
  bool _submitted = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Like vuelidate's `$dirty`: a field shows valid or invalid only once edited or checked.
  bool _shown(SignUpField field) => _validated || _edited.contains(field);

  void _reset() {
    for (final controller in _controllers.values) {
      controller.clear();
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _values = const ShowcaseSignUpValues();
      _edited.clear();
      _validated = false;
      _submitted = false;
    });
  }

  String _labelOf(AppLocalizations l10n, SignUpField field) => switch (field) {
    SignUpField.firstName => l10n.validationFormsPageFirstNameLabel,
    SignUpField.lastName => l10n.validationFormsPageLastNameLabel,
    SignUpField.userName => l10n.validationFormsPageUserNameLabel,
    SignUpField.email => l10n.validationFormsPageEmailLabel,
    SignUpField.password => l10n.validationFormsPagePasswordLabel,
    SignUpField.confirmPassword => l10n.validationFormsPageConfirmPasswordLabel,
    SignUpField.accept => l10n.validationFormsPageAcceptLabel,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final issues = validateShowcaseSignUp(_values);
    final valid = issues.isEmpty;
    final passBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.md),
      borderSide: BorderSide(color: colors.pass),
    );

    Widget textField(SignUpField field) {
      final label = _labelOf(l10n, field);
      final secret = field == SignUpField.password || field == SignUpField.confirmPassword;
      final shown = _shown(field);
      final issue = issues[field];
      return LabeledField(
        label: label,
        child: TextFormField(
          key: ValueKey('signup.${field.name}'),
          controller: _controllers[field],
          obscureText: secret,
          autocorrect: false,
          enableSuggestions: !secret && field != SignUpField.email,
          textCapitalization: switch (field) {
            SignUpField.firstName || SignUpField.lastName => TextCapitalization.words,
            _ => TextCapitalization.none,
          },
          keyboardType: field == SignUpField.email ? TextInputType.emailAddress : null,
          textInputAction: TextInputAction.next,
          autofillHints: switch (field) {
            SignUpField.firstName => const [AutofillHints.givenName],
            SignUpField.lastName => const [AutofillHints.familyName],
            SignUpField.userName => const [AutofillHints.newUsername],
            SignUpField.email => const [AutofillHints.email],
            _ => const [AutofillHints.newPassword],
          },
          onChanged: (text) => setState(() {
            _values = _values.withText(field, text);
            _edited.add(field);
          }),
          decoration: InputDecoration(
            hintText: secret ? l10n.validationFormsPagePasswordPlaceholder : label,
            errorText: shown ? issue?.message(l10n) : null,
            enabledBorder: shown && issue == null ? passBorder : null,
          ),
        ),
      );
    }

    final acceptError = _shown(SignUpField.accept) ? issues[SignUpField.accept] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, field) in _textFields.indexed) ...[
                  if (index > 0) const SizedBox(height: Space.card),
                  textField(field),
                ],
                const SizedBox(height: Space.page),
                CheckboxListTile(
                  key: const ValueKey('signup.accept'),
                  value: _values.accept,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  isError: acceptError != null,
                  title: Text(
                    _labelOf(l10n, SignUpField.accept),
                    style: context.text.bodyMedium,
                  ),
                  onChanged: (accept) => setState(() {
                    _values = _values.withAccept(accept ?? false);
                    _edited.add(SignUpField.accept);
                  }),
                ),
                if (acceptError != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      acceptError.message(l10n),
                      style: TextStyle(
                        color: colors.pen,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: Space.page),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: [
                    FilledButton(
                      onPressed: valid && !_submitted
                          ? () {
                              FocusScope.of(context).unfocus();
                              setState(() => _submitted = true);
                            }
                          : null,
                      child: Text(l10n.validationFormsPageSubmit),
                    ),
                    OutlinedButton(
                      onPressed: valid ? null : () => setState(() => _validated = true),
                      child: Text(l10n.validationFormsPageValidate),
                    ),
                    FilledButton(
                      style: destructiveButtonStyle(context),
                      onPressed: _edited.isEmpty && !_validated ? null : _reset,
                      child: Text(l10n.validationFormsPageReset),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.lg),
        _FormValues(values: _values, submitted: _submitted),
      ],
    );
  }
}

/// The live values, printed as JSON like the web's `<pre>`.
class _FormValues extends StatelessWidget {
  const _FormValues({required this.values, required this.submitted});

  final ShowcaseSignUpValues values;
  final bool submitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final json = const JsonEncoder.withIndent('    ').convert(values.toJson());
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(Space.page),
      decoration: BoxDecoration(
        color: submitted ? colors.pass.withValues(alpha: 0.06) : colors.ink100,
        border: Border.all(color: submitted ? colors.pass.withValues(alpha: 0.4) : colors.ink200),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            liveRegion: submitted,
            child: Row(
              children: [
                if (submitted) ...[
                  Mark(status: TestStatus.passed, size: 16, animate: true, color: colors.pass),
                  const SizedBox(width: Space.sm),
                ],
                Flexible(
                  child: FormLabel(
                    submitted
                        ? l10n.validationFormsPageValuesSubmitted
                        : l10n.validationFormsPageValuesTitle,
                    color: colors.ink700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(json, style: context.type.code),
          ),
        ],
      ),
    );
  }
}
