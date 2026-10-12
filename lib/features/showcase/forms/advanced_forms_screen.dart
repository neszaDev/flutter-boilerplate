import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/forms/date_pickers.dart';
import 'package:flutter_boilerplate/features/showcase/forms/form_demo_widgets.dart';
import 'package:flutter_boilerplate/features/showcase/forms/masked_inputs.dart';
import 'package:flutter_boilerplate/features/showcase/forms/select_demos.dart';

/// Masked inputs, searchable selects and date pickers (the web's advanced forms page).
class AdvancedFormsScreen extends StatelessWidget {
  const AdvancedFormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.advancedFormsPageTitle,
      description: Text(l10n.advancedFormsPageDescription),
      children: [
        DemoCard(
          title: l10n.advancedFormsPageMaskedTitle,
          description: l10n.advancedFormsPageMaskedDescription,
          action: DocsLink(
            url: 'https://pub.dev/packages/mask_text_input_formatter',
            label: l10n.advancedFormsPageDocs,
            title: l10n.advancedFormsPageDocsTitle('mask_text_input_formatter'),
          ),
          child: const MaskedInputs(),
        ),
        DemoCard(
          title: l10n.advancedFormsPageMultiselectTitle,
          description: l10n.advancedFormsPageMultiselectDescription,
          child: const MultiselectDemo(),
        ),
        DemoCard(
          title: l10n.advancedFormsPageSelectTitle,
          description: l10n.advancedFormsPageSelectDescription,
          child: const SelectDemo(),
        ),
        DemoCard(
          title: l10n.advancedFormsPageDatePickerTitle,
          description: l10n.advancedFormsPageDatePickerDescription,
          action: DocsLink(
            url: 'https://api.flutter.dev/flutter/material/showDateRangePicker.html',
            label: l10n.advancedFormsPageDocs,
            title: l10n.advancedFormsPageDocsTitle('Flutter'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RangeCalendarDemo(),
              const SizedBox(height: Space.lg),
              Divider(color: context.colors.ink200),
              const SizedBox(height: Space.lg),
              const PopoverDatePickers(),
            ],
          ),
        ),
      ],
    );
  }
}
