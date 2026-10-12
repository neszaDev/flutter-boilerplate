import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/forms/form_demo_widgets.dart';
import 'package:flutter_boilerplate/features/showcase/forms/sign_up_validation_form.dart';

/// A sign-up form validated field by field and as a whole (the web's validation forms page).
class ValidationFormsScreen extends StatelessWidget {
  const ValidationFormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.validationFormsPageTitle,
      description: Text(l10n.validationFormsPageDescription),
      children: [
        DemoCard(
          title: l10n.validationFormsPageCardTitle,
          description: l10n.validationFormsPageIntro,
          action: DocsLink(
            url: 'https://docs.flutter.dev/cookbook/forms/validation',
            label: l10n.validationFormsPageDocs,
            title: l10n.validationFormsPageDocsTitle,
          ),
          child: const SignUpValidationForm(),
        ),
      ],
    );
  }
}
