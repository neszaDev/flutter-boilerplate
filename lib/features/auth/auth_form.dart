import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/features/auth/auth_validation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthMode { signIn, signUp }

/// Email + password form for both sign-in and sign-up. On success the session changes and the
/// router leaves this screen by itself.
class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({required this.mode, super.key});

  final AuthMode mode;

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _showPassword = false;
  String? _formError;
  Map<String, String> _fieldErrors = const {};

  bool get _signUp => widget.mode == AuthMode.signUp;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    setState(() {
      _formError = null;
      _fieldErrors = const {};
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _busy = true);
    final session = ref.read(sessionProvider.notifier);
    try {
      if (_signUp) {
        await session.signUp(email: _email.text, password: _password.text);
      } else {
        await session.signIn(email: _email.text, password: _password.text);
      }
      TextInput.finishAutofillContext();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        switch (error.failure) {
          case ApiFailure.unauthorized when !_signUp:
            _formError = l10n.authFormErrorInvalidCredentials;
          case ApiFailure.conflict when _signUp:
            _fieldErrors = {'email': l10n.authFormErrorEmailTaken};
          case ApiFailure.invalid when error.fieldErrors.isNotEmpty:
            _fieldErrors = error.fieldErrors;
            _formError = l10n.authFormErrorInvalidInput;
          default:
            _formError = errorMessage(context, error, fallback: l10n.authFormErrorGeneric);
        }
      });
      Haptics.error();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider);
    final expired = session is SignedOut && session.expired;

    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_formError != null || (expired && !_signUp)) ...[
              FormAlert(_formError ?? l10n.sessionExpired),
              const SizedBox(height: Space.card),
            ],
            LabeledField(
              label: l10n.authFormEmailLabel,
              child: TextFormField(
                key: const Key('auth.email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [AutofillHints.email, AutofillHints.username],
                decoration: InputDecoration(
                  hintText: 'name@example.com',
                  errorText: _fieldErrors['email'],
                  semanticCounterText: l10n.authFormEmailLabel,
                ),
                validator: validator(l10n, _signUp ? signUpEmail : signInEmail),
              ),
            ),
            const SizedBox(height: Space.card),
            LabeledField(
              label: l10n.authFormPasswordLabel,
              child: TextFormField(
                key: const Key('auth.password'),
                controller: _password,
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: [_signUp ? AutofillHints.newPassword : AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  helperText: _signUp ? l10n.authFormPasswordHint : null,
                  errorText: _fieldErrors['password'],
                  suffixIcon: IconButton(
                    tooltip: _showPassword ? l10n.authFormHidePassword : l10n.authFormShowPassword,
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                validator: validator(l10n, _signUp ? signUpPassword : signInPassword),
              ),
            ),
            const SizedBox(height: Space.lg),
            BusyButton(
              key: const Key('auth.submit'),
              label: _signUp ? l10n.authFormSignUpButton : l10n.authFormSignInButton,
              busy: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
