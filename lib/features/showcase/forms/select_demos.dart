import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/features/showcase/forms/combobox.dart';
import 'package:flutter_boilerplate/features/showcase/forms/forms_data.dart';

/// The multiselect demo: pick several states as removable chips (American Samoa is disabled).
class MultiselectDemo extends StatefulWidget {
  const MultiselectDemo({super.key});

  @override
  State<MultiselectDemo> createState() => _MultiselectDemoState();
}

class _MultiselectDemoState extends State<MultiselectDemo> {
  List<String> _states = const [];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LabeledField(
      label: l10n.advancedFormsPageStatesLabel,
      child: Combobox(
        key: const Key('multiselect'),
        label: l10n.advancedFormsPageStatesLabel,
        options: usStates,
        value: _states,
        onChanged: (states) => setState(() => _states = states),
        multiple: true,
        placeholder: l10n.advancedFormsPageMultiselectPlaceholder,
        searchPlaceholder: l10n.advancedFormsPageSearchStates,
      ),
    );
  }
}

/// The searchable select demos: one state, or several in a clearable field.
class SelectDemo extends StatefulWidget {
  const SelectDemo({super.key});

  @override
  State<SelectDemo> createState() => _SelectDemoState();
}

class _SelectDemoState extends State<SelectDemo> {
  List<String> _state = const [];
  List<String> _states = const [];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledField(
          label: l10n.advancedFormsPageStateLabel,
          child: Combobox(
            key: const Key('select-single'),
            label: l10n.advancedFormsPageStateLabel,
            options: usStates,
            value: _state,
            onChanged: (state) => setState(() => _state = state),
            clearable: true,
            placeholder: l10n.advancedFormsPageSelectPlaceholder,
            searchPlaceholder: l10n.advancedFormsPageSearchStates,
          ),
        ),
        const SizedBox(height: Space.card),
        LabeledField(
          label: l10n.advancedFormsPageStatesLabel,
          child: Combobox(
            key: const Key('select-multiple'),
            label: l10n.advancedFormsPageStatesLabel,
            options: usStates,
            value: _states,
            onChanged: (states) => setState(() => _states = states),
            multiple: true,
            clearable: true,
            placeholder: l10n.advancedFormsPageSelectPlaceholder,
            searchPlaceholder: l10n.advancedFormsPageSearchStates,
          ),
        ),
      ],
    );
  }
}
