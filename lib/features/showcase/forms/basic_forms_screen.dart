import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/forms/basic_forms_groups.dart';
import 'package:flutter_boilerplate/features/showcase/forms/date_pickers.dart';
import 'package:flutter_boilerplate/features/showcase/forms/form_demo_widgets.dart';
import 'package:flutter_boilerplate/features/showcase/forms/forms_data.dart';
import 'package:flutter_boilerplate/features/showcase/forms/validated_input.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Every form control on its white ply: text, selects, checks, files, groups and validation
/// states (the web's basic forms page), with the phone's own keyboards and pickers.
class BasicFormsScreen extends StatelessWidget {
  const BasicFormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.basicFormsPageTitle,
      description: Text(l10n.basicFormsPageDescription),
      children: const [
        _CreditCardCard(),
        _CompanyCard(),
        _ElementsCard(),
        _InlineFormCard(),
        _HorizontalFormCard(),
        _NormalFormCard(),
        _InputGridCard(),
        _InputSizesCard(),
        _BasicValidationCard(),
        _CustomValidationCard(),
        IconGroupsCard(),
        ButtonGroupsCard(),
        DropdownGroupsCard(),
        SplitGridCard(stackOnPhones: true),
        SplitGridCard(stackOnPhones: false),
        ExampleFormCard(variant: ExampleFormVariant.text),
        ExampleFormCard(variant: ExampleFormVariant.append),
        ExampleFormCard(variant: ExampleFormVariant.prepend),
        FormElementsCard(),
      ],
    );
  }
}

const _gap = SizedBox(height: Space.card);

/// "Option 1" … "Option 3", the values of the sample selects.
List<DropdownMenuItem<String>> _optionItems(AppLocalizations l10n) => [
  for (final number in optionNumbers)
    DropdownMenuItem(value: 'option-$number', child: Text(l10n.basicFormsPageOption('$number'))),
];

class _CreditCardCard extends StatelessWidget {
  const _CreditCardCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final figures = context.type.table.copyWith(fontSize: 15);
    return DemoCard(
      title: l10n.basicFormsPageCreditCardTitle,
      description: l10n.basicFormsPageCreditCardDescription,
      child: DemoForm(
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LabeledField(
                label: l10n.basicFormsPageNameLabel,
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.creditCardName],
                  decoration: InputDecoration(hintText: l10n.basicFormsPageNamePlaceholder),
                ),
              ),
              _gap,
              LabeledField(
                label: l10n.basicFormsPageCardNumberLabel,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.creditCardNumber],
                  style: figures,
                  decoration: const InputDecoration(hintText: '0000 0000 0000 0000'),
                ),
              ),
              _gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledField(
                      label: l10n.basicFormsPageMonthLabel,
                      child: _NumberSelect(values: cardMonths, style: figures),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: LabeledField(
                      label: l10n.basicFormsPageYearLabel,
                      child: _NumberSelect(values: cardYears, style: figures),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: LabeledField(
                      label: l10n.basicFormsPageCvvLabel,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.creditCardSecurityCode],
                        style: figures,
                        decoration: const InputDecoration(hintText: '123'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A native-looking select of numbers, starting on the first.
class _NumberSelect extends StatelessWidget {
  const _NumberSelect({required this.values, required this.style});

  final List<int> values;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    initialValue: values.first,
    isExpanded: true,
    style: style,
    items: [for (final value in values) DropdownMenuItem(value: value, child: Text('$value'))],
    onChanged: (_) {},
  );
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget field(
      String label,
      String? placeholder,
      List<String> autofill, {
      TextCapitalization capitalization = TextCapitalization.words,
    }) => LabeledField(
      label: label,
      child: TextFormField(
        textInputAction: TextInputAction.next,
        textCapitalization: capitalization,
        autofillHints: autofill,
        decoration: InputDecoration(hintText: placeholder),
      ),
    );
    return DemoCard(
      title: l10n.basicFormsPageCompanyTitle,
      description: l10n.basicFormsPageCompanyDescription,
      child: DemoForm(
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              field(l10n.basicFormsPageCompanyLabel, l10n.basicFormsPageCompanyPlaceholder, const [
                AutofillHints.organizationName,
              ]),
              _gap,
              field(
                l10n.basicFormsPageVatLabel,
                'PL1234567890',
                const [],
                capitalization: TextCapitalization.characters,
              ),
              _gap,
              field(l10n.basicFormsPageStreetLabel, l10n.basicFormsPageStreetPlaceholder, const [
                AutofillHints.streetAddressLine1,
              ]),
              _gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: field(
                      l10n.basicFormsPageCityLabel,
                      l10n.basicFormsPageCityPlaceholder,
                      const [AutofillHints.addressCity],
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: field(
                      l10n.basicFormsPagePostalCodeLabel,
                      l10n.basicFormsPagePostalCodePlaceholder,
                      const [AutofillHints.postalCode],
                      capitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
              ),
              _gap,
              field(l10n.basicFormsPageCountryLabel, l10n.basicFormsPageCountryPlaceholder, const [
                AutofillHints.countryName,
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ElementsCard extends StatelessWidget {
  const _ElementsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final placeholder = l10n.basicFormsPageSelectPlaceholder;
    return DemoCard(
      title: l10n.basicFormsPageElementsTitle,
      description: l10n.basicFormsPageElementsDescription,
      child: DemoForm(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HorizontalField(
              label: l10n.basicFormsPageFullNameLabel,
              child: TextFormField(
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(helperText: l10n.basicFormsPageFullNameHint),
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageStaticLabel,
              child: TextFormField(
                readOnly: true,
                initialValue: l10n.basicFormsPageStaticValue,
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageTextLabel,
              child: TextFormField(
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: l10n.basicFormsPageTextPlaceholder,
                  helperText: l10n.basicFormsPageTextHint,
                ),
              ),
            ),
            _gap,
            HorizontalField(label: l10n.basicFormsPageDateLabel, child: const _DateField()),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageEmailInputLabel,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  hintText: l10n.basicFormsPageEmailInputPlaceholder,
                  helperText: l10n.basicFormsPageEmailInputHint,
                ),
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPagePasswordInputLabel,
              child: TextFormField(
                obscureText: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  hintText: l10n.basicFormsPagePasswordInputPlaceholder,
                  helperText: l10n.basicFormsPagePasswordInputHint,
                ),
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageDisabledLabel,
              child: TextFormField(
                enabled: false,
                decoration: InputDecoration(hintText: l10n.basicFormsPageDisabledPlaceholder),
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageTextareaLabel,
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                minLines: 6,
                maxLines: 9,
                decoration: InputDecoration(hintText: l10n.basicFormsPageTextareaPlaceholder),
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageSelectLabel,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                hint: Text(placeholder),
                items: _optionItems(l10n),
                onChanged: (_) {},
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageLargeSelectLabel,
              child: DropdownButtonFormField<String>(
                initialValue: 'selected',
                isExpanded: true,
                style: context.text.bodyLarge,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: Space.md, vertical: 15),
                ),
                items: [
                  DropdownMenuItem(value: '', enabled: false, child: Text(placeholder)),
                  ..._optionItems(l10n),
                  DropdownMenuItem(
                    value: 'selected',
                    child: Text(l10n.basicFormsPageSelectedOption),
                  ),
                ],
                onChanged: (_) {},
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageSmallSelectLabel,
              child: DropdownMenu<String>(
                expandedInsets: EdgeInsets.zero,
                hintText: placeholder,
                textStyle: context.text.bodyMedium?.copyWith(fontSize: 14),
                dropdownMenuEntries: [
                  for (final number in optionNumbers)
                    DropdownMenuEntry(
                      value: 'option-$number',
                      label: l10n.basicFormsPageOption('$number'),
                    ),
                ],
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageDisabledSelectLabel,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                hint: Text(placeholder),
                disabledHint: Text(placeholder),
                items: _optionItems(l10n),
                onChanged: null,
              ),
            ),
            for (final (index, group) in ChoiceGroup.values.indexed) ...[
              _gap,
              HorizontalField(
                label: group.checkboxLabel(l10n),
                group: true,
                // As on the web, group N starts with option N checked (the last starts empty).
                child: _CheckGroup(group: group, checked: index),
              ),
            ],
            for (final (index, group) in ChoiceGroup.values.indexed) ...[
              _gap,
              HorizontalField(
                label: group.radioLabel(l10n),
                group: true,
                // The first radio group starts empty, group N with option N chosen.
                child: _RadioChoiceGroup(group: group, chosen: index == 0 ? null : index),
              ),
            ],
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageFileLabel,
              child: PlaceholderFileField(
                prompt: l10n.basicFormsPageChooseFile,
                browse: l10n.basicFormsPageBrowse,
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageMultipleFileLabel,
              child: PlaceholderFileField(
                prompt: l10n.basicFormsPageChooseFiles,
                browse: l10n.basicFormsPageBrowse,
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageCustomFileLabel,
              child: PlaceholderFileField(
                prompt: l10n.basicFormsPageChooseFile,
                browse: l10n.basicFormsPageBrowse,
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageMultipleCustomFileLabel,
              child: PlaceholderFileField(
                prompt: l10n.basicFormsPageChooseFiles,
                browse: l10n.basicFormsPageBrowse,
              ),
            ),
            const SizedBox(height: Space.sm),
            Text(
              l10n.basicFormsPageFileHint,
              style: context.text.bodySmall?.copyWith(color: colors.ink600),
            ),
            _gap,
            const SubmitResetActions(),
          ],
        ),
      ),
    );
  }
}

/// The date input: the system date picker behind a field-shaped button.
class _DateField extends StatefulWidget {
  const _DateField();

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  DateTime? _date;

  Future<void> _pick() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    if (date != null && mounted) {
      setState(() => _date = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = _date;
    return DateFieldButton(
      text: date == null ? context.l10n.basicFormsPageDatePlaceholder : context.formatDate(date),
      empty: date == null,
      onPressed: _pick,
    );
  }
}

/// The four check and radio groups of the web page: stacked or inline, the platform's own
/// controls (the web's native inputs) or the Marksheet ones (the web's custom controls).
enum ChoiceGroup {
  stacked(isInline: false, isAdaptive: true),
  inline(isInline: true, isAdaptive: true),
  custom(isInline: false, isAdaptive: false),
  inlineCustom(isInline: true, isAdaptive: false);

  const ChoiceGroup({required this.isInline, required this.isAdaptive});

  final bool isInline;
  final bool isAdaptive;

  String checkboxLabel(AppLocalizations l10n) => switch (this) {
    stacked => l10n.basicFormsPageCheckboxesStacked,
    inline => l10n.basicFormsPageCheckboxesInline,
    custom => l10n.basicFormsPageCheckboxesCustom,
    inlineCustom => l10n.basicFormsPageCheckboxesInlineCustom,
  };

  String radioLabel(AppLocalizations l10n) => switch (this) {
    stacked => l10n.basicFormsPageRadiosStacked,
    inline => l10n.basicFormsPageRadiosInline,
    custom => l10n.basicFormsPageRadiosCustom,
    inlineCustom => l10n.basicFormsPageRadiosInlineCustom,
  };
}

/// A control and its option label, tappable as one and read as one.
class _Choice extends StatelessWidget {
  const _Choice({required this.control, required this.label, required this.onTap});

  final Widget control;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
      child: Padding(
        padding: const EdgeInsets.only(right: Space.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            control,
            Text(label, style: context.text.bodyMedium),
          ],
        ),
      ),
    ),
  );
}

Widget _choiceLayout(ChoiceGroup group, List<Widget> choices) => group.isInline
    ? Wrap(spacing: Space.sm, children: choices)
    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: choices);

class _CheckGroup extends StatefulWidget {
  const _CheckGroup({required this.group, required this.checked});

  final ChoiceGroup group;

  /// Index of the option checked first (none when out of range).
  final int checked;

  @override
  State<_CheckGroup> createState() => _CheckGroupState();
}

class _CheckGroupState extends State<_CheckGroup> {
  late final _values = [
    for (var index = 0; index < optionNumbers.length; index++) index == widget.checked,
  ];

  void _toggle(int index) => setState(() => _values[index] = !_values[index]);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _choiceLayout(widget.group, [
      for (final (index, number) in optionNumbers.indexed)
        _Choice(
          label: l10n.basicFormsPageOption('$number'),
          onTap: () => _toggle(index),
          control: widget.group.isAdaptive
              ? Checkbox.adaptive(value: _values[index], onChanged: (_) => _toggle(index))
              : Checkbox(value: _values[index], onChanged: (_) => _toggle(index)),
        ),
    ]);
  }
}

class _RadioChoiceGroup extends StatefulWidget {
  const _RadioChoiceGroup({required this.group, required this.chosen});

  final ChoiceGroup group;

  /// The option number chosen first, if any.
  final int? chosen;

  @override
  State<_RadioChoiceGroup> createState() => _RadioChoiceGroupState();
}

class _RadioChoiceGroupState extends State<_RadioChoiceGroup> {
  late int? _value = widget.chosen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RadioGroup<int>(
      groupValue: _value,
      onChanged: (value) => setState(() => _value = value),
      child: _choiceLayout(widget.group, [
        for (final number in optionNumbers)
          _Choice(
            label: l10n.basicFormsPageOption('$number'),
            onTap: () => setState(() => _value = number),
            control: widget.group.isAdaptive
                ? Radio<int>.adaptive(value: number)
                : Radio<int>(value: number),
          ),
      ]),
    );
  }
}

/// A short label in front of its field, on one line (the web's inline form).
class _InlineField extends StatelessWidget {
  const _InlineField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ExcludeSemantics(child: Text(label, style: context.text.titleSmall)),
      const SizedBox(width: Space.sm),
      Expanded(
        child: Semantics(label: label, child: child),
      ),
    ],
  );
}

class _InlineFormCard extends StatelessWidget {
  const _InlineFormCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.basicFormsPageInlineTitle,
      description: l10n.basicFormsPageInlineDescription,
      child: DemoForm(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InlineField(
              label: l10n.basicFormsPageInlineNameLabel,
              child: TextFormField(
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(hintText: l10n.basicFormsPageInlineNamePlaceholder),
              ),
            ),
            const SizedBox(height: Space.page),
            _InlineField(
              label: l10n.basicFormsPageInlineEmailLabel,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(hintText: l10n.basicFormsPageInlineEmailPlaceholder),
              ),
            ),
            _gap,
            const SubmitResetActions(),
          ],
        ),
      ),
    );
  }
}

class _HorizontalFormCard extends StatelessWidget {
  const _HorizontalFormCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.basicFormsPageHorizontalTitle,
      description: l10n.basicFormsPageHorizontalDescription,
      child: DemoForm(
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HorizontalField(
                label: l10n.basicFormsPageEmailLabel,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    hintText: l10n.basicFormsPageEmailPlaceholder,
                    helperText: l10n.basicFormsPageEmailHint,
                  ),
                ),
              ),
              _gap,
              HorizontalField(
                label: l10n.basicFormsPagePasswordLabel,
                child: TextFormField(
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: l10n.basicFormsPagePasswordPlaceholder,
                    helperText: l10n.basicFormsPagePasswordHint,
                  ),
                ),
              ),
              _gap,
              const SubmitResetActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NormalFormCard extends StatelessWidget {
  const _NormalFormCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.basicFormsPageNormalTitle,
      description: l10n.basicFormsPageNormalDescription,
      child: DemoForm(
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValidatedInput(
                label: l10n.basicFormsPageEmailLabel,
                rule: InputRule.email,
                hint: l10n.basicFormsPageEmailHint,
                placeholder: l10n.basicFormsPageEmailPlaceholder,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              _gap,
              ValidatedInput(
                label: l10n.basicFormsPagePasswordLabel,
                rule: InputRule.required,
                hint: l10n.basicFormsPagePasswordHint,
                placeholder: l10n.basicFormsPagePasswordPlaceholder,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
              ),
              _gap,
              const SubmitResetActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputGridCard extends StatelessWidget {
  const _InputGridCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.basicFormsPageInputGridTitle,
      description: l10n.basicFormsPageInputGridDescription,
      child: DemoForm(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= HorizontalField.breakpoint;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final span in gridSpans) ...[
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: wide ? span / 12 : 1,
                      child: GridInput(span: span),
                    ),
                  ),
                  const SizedBox(height: Space.md),
                ],
                const SizedBox(height: Space.sm),
                SubmitResetActions(
                  submitIcon: LucideIcons.user,
                  submitLabel: l10n.basicFormsPageLogin,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InputSizesCard extends StatelessWidget {
  const _InputSizesCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.basicFormsPageSizesTitle,
      description: l10n.basicFormsPageSizesDescription,
      child: DemoForm(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HorizontalField(
              label: l10n.basicFormsPageSmallInputLabel,
              child: TextFormField(
                style: context.text.bodyMedium?.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.basicFormsPageSmallInputPlaceholder,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                ),
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageDefaultInputLabel,
              child: TextFormField(
                decoration: InputDecoration(hintText: l10n.basicFormsPageDefaultInputPlaceholder),
              ),
            ),
            _gap,
            HorizontalField(
              label: l10n.basicFormsPageLargeInputLabel,
              child: TextFormField(
                style: context.text.bodyLarge?.copyWith(fontSize: 18),
                decoration: InputDecoration(
                  hintText: l10n.basicFormsPageLargeInputPlaceholder,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Space.page,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            _gap,
            const SubmitResetActions(),
          ],
        ),
      ),
    );
  }
}

class _BasicValidationCard extends StatelessWidget {
  const _BasicValidationCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.basicFormsPageBasicValidationTitle,
      description: l10n.basicFormsPageBasicValidationDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValidatedInput(
            label: l10n.basicFormsPageValidInputLabel,
            rule: InputRule.optional,
            validFeedback: l10n.basicFormsPageNotRequiredFeedback,
          ),
          _gap,
          ValidatedInput(
            label: l10n.basicFormsPageInvalidInputLabel,
            rule: InputRule.required,
            validFeedback: l10n.basicFormsPageThankYouFeedback,
            invalidFeedback: l10n.basicFormsPageRequiredFeedback,
          ),
        ],
      ),
    );
  }
}

class _CustomValidationCard extends StatelessWidget {
  const _CustomValidationCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.basicFormsPageCustomValidationTitle,
      description: l10n.basicFormsPageCustomValidationDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValidatedInput(
            label: l10n.basicFormsPageValidInputLabel,
            rule: InputRule.minLength4,
            initialValue: l10n.basicFormsPageValidValue,
            validFeedback: l10n.basicFormsPageValidFeedback,
            invalidFeedback: l10n.basicFormsPageMinLengthFeedback,
          ),
          _gap,
          ValidatedInput(
            label: l10n.basicFormsPageInvalidInputLabel,
            rule: InputRule.minLength4,
            validFeedback: l10n.basicFormsPageThankYouFeedback,
            invalidFeedback: l10n.basicFormsPageMinLengthFeedback,
          ),
        ],
      ),
    );
  }
}
