import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/multi_language_editor.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/multi_language_fields.dart';

/// `/dashboard/campus/content`: the two multi-language editors, each with a switch for its add
/// and remove buttons (off by default for plain fields and on for rich text, as in Vue).
class CampusContentScreen extends StatefulWidget {
  const CampusContentScreen({super.key});

  @override
  State<CampusContentScreen> createState() => _CampusContentScreenState();
}

class _CampusContentScreenState extends State<CampusContentScreen> {
  var _fieldsEditable = false;
  var _editorEditable = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.campusContentPageTitle,
      description: Text(l10n.campusContentPageDescription),
      children: [
        DemoCard(
          title: l10n.campusContentFieldsTitle,
          description: l10n.campusContentFieldsDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _EditableSwitch(
                value: _fieldsEditable,
                onChanged: (value) => setState(() => _fieldsEditable = value),
              ),
              const SizedBox(height: Space.md),
              MultiLanguageFields(
                caption: l10n.campusContentFieldsCaption,
                editable: _fieldsEditable,
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.campusContentEditorTitle,
          description: l10n.campusContentEditorDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _EditableSwitch(
                value: _editorEditable,
                onChanged: (value) => setState(() => _editorEditable = value),
              ),
              const SizedBox(height: Space.md),
              MultiLanguageEditor(
                caption: l10n.campusContentEditorCaption,
                editable: _editorEditable,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Add and remove": shows or hides the rows' buttons.
class _EditableSwitch extends StatelessWidget {
  const _EditableSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(context.l10n.campusContentEditable),
    value: value,
    onChanged: onChanged,
  );
}
