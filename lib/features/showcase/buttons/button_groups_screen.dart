import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/button_group.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/demo_button.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/menu_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Below this window width (Material's compact class) a few buttons drop out of the groups,
/// like the web page's `max-md:hidden`.
const _wideFrom = 600.0;

/// `/dashboard/buttons/button-groups`: joined buttons, toolbars and toggle groups.
class ButtonGroupsScreen extends StatelessWidget {
  const ButtonGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wide = MediaQuery.sizeOf(context).width >= _wideFrom;

    List<Widget> menuItems() => [
      menuItem(l10n.buttonGroupsPageItem('1')),
      menuItem(l10n.buttonGroupsPageItem('2')),
      const MenuSeparator(),
      menuItem(l10n.buttonGroupsPageItem('3')),
    ];
    DemoButton outline(String label, {DemoSize size = DemoSize.normal}) =>
        DemoButton(label: label, variant: DemoVariant.outline, size: size);
    DemoIconButton iconButton(IconData icon, String tooltip) =>
        DemoIconButton(icon: Icon(icon), tooltip: tooltip);
    Widget toolbar(String label, List<Widget> children) => Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Wrap(
        spacing: Space.sm,
        runSpacing: Space.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
    Widget stack(List<Widget> children, {double gap = Space.lg}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) SizedBox(height: gap),
          child,
        ],
      ],
    );

    return AppPage(
      title: l10n.buttonGroupsPageTitle,
      description: Text(l10n.buttonGroupsPageDescription),
      children: [
        DemoCard(
          title: l10n.buttonGroupsPageBasicTitle,
          description: l10n.buttonGroupsPageBasicDescription,
          child: stack([
            ButtonGroup(
              label: l10n.buttonGroupsPageNumbersLabel,
              children: [
                outline(l10n.buttonGroupsPageOne),
                outline(l10n.buttonGroupsPageTwo),
                outline(l10n.buttonGroupsPageThree),
                outline(l10n.buttonGroupsPageFour),
                if (wide) outline(l10n.buttonGroupsPageFive),
              ],
            ),
            ButtonGroup(
              label: l10n.buttonGroupsPageVariantsLabel,
              children: [
                for (final variant in cardVariants)
                  if (wide ||
                      const [
                        DemoVariant.secondary,
                        DemoVariant.ghost,
                        DemoVariant.link,
                      ].contains(variant))
                    DemoButton(label: variantLabel(l10n, variant), variant: variant),
              ],
            ),
          ]),
        ),
        DemoCard(
          title: l10n.buttonGroupsPageSizingTitle,
          child: stack([
            for (final (size, label) in [
              (DemoSize.normal, l10n.buttonGroupsPageSizeDefault),
              (DemoSize.sm, l10n.buttonGroupsPageSizeSm),
              (DemoSize.lg, l10n.buttonGroupsPageSizeLg),
            ])
              ButtonGroup(
                label: label,
                children: [
                  outline(l10n.buttonGroupsPageLeft, size: size),
                  outline(l10n.buttonGroupsPageMiddle, size: size),
                  outline(l10n.buttonGroupsPageRight, size: size),
                ],
              ),
          ]),
        ),
        DemoCard(
          title: l10n.buttonGroupsPageDropdownTitle,
          description: l10n.buttonGroupsPageDropdownDescription,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ButtonGroup(
              label: l10n.buttonGroupsPageDropdownLabel,
              children: [
                if (wide) ...[
                  outline(l10n.buttonGroupsPageButton('1')),
                  outline(l10n.buttonGroupsPageButton('2')),
                ],
                MenuButton(
                  label: l10n.buttonGroupsPageMenu,
                  variant: DemoVariant.primary,
                  placement: const MenuPlacement(align: MenuAlign.end),
                  menuChildren: [
                    ...menuItems(),
                    const MenuSeparator(),
                    SubmenuButton(
                      menuChildren: [
                        menuItem(l10n.buttonGroupsPageItem('4')),
                        menuItem(l10n.buttonGroupsPageItem('5')),
                      ],
                      child: Text(l10n.buttonGroupsPageMore),
                    ),
                  ],
                ),
                if (wide) outline(l10n.buttonGroupsPageButton('3')),
                DemoButton(label: l10n.buttonGroupsPageSplitMenu, variant: DemoVariant.secondary),
                MenuCaretButton(
                  variant: DemoVariant.secondary,
                  placement: const MenuPlacement(align: MenuAlign.end),
                  menuChildren: menuItems(),
                ),
              ],
            ),
          ),
        ),
        DemoCard(
          title: l10n.buttonGroupsPageVerticalTitle,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ButtonGroup(
              label: l10n.buttonGroupsPageVerticalLabel,
              vertical: true,
              children: [
                outline(l10n.buttonGroupsPageTop),
                outline(l10n.buttonGroupsPageMiddle),
                outline(l10n.buttonGroupsPageBottom),
              ],
            ),
          ),
        ),
        DemoCard(
          title: l10n.buttonGroupsPageToolbarTitle,
          description: l10n.buttonGroupsPageToolbarDescription,
          child: stack(gap: Space.card, [
            toolbar(l10n.buttonGroupsPageToolbarPagesLabel, [
              ButtonGroup(
                label: l10n.buttonGroupsPageBackLabel,
                children: [
                  if (wide) iconButton(LucideIcons.chevronsLeft, l10n.buttonGroupsPageFirst),
                  iconButton(LucideIcons.chevronLeft, l10n.buttonGroupsPagePrevious),
                ],
              ),
              ButtonGroup(
                label: l10n.buttonGroupsPageEditLabel,
                children: [
                  if (wide) outline(l10n.buttonGroupsPageEdit),
                  outline(l10n.buttonGroupsPageUndo),
                  outline(l10n.buttonGroupsPageRedo),
                ],
              ),
              ButtonGroup(
                label: l10n.buttonGroupsPageForwardLabel,
                children: [
                  iconButton(LucideIcons.chevronRight, l10n.buttonGroupsPageNext),
                  if (wide) iconButton(LucideIcons.chevronsRight, l10n.buttonGroupsPageLast),
                ],
              ),
            ]),
            if (wide) ...[
              const Divider(),
              toolbar(l10n.buttonGroupsPageToolbarInputsLabel, [
                ButtonGroup(
                  label: l10n.buttonGroupsPageCreateLabel,
                  children: [
                    outline(l10n.buttonGroupsPageNew, size: DemoSize.sm),
                    outline(l10n.buttonGroupsPageEdit, size: DemoSize.sm),
                  ],
                ),
                const _AmountField(),
                const _SizeSelect(),
                ButtonGroup(
                  label: l10n.buttonGroupsPageSaveLabel,
                  children: [
                    outline(l10n.buttonGroupsPageSave, size: DemoSize.sm),
                    outline(l10n.buttonGroupsPageCancel, size: DemoSize.sm),
                  ],
                ),
              ]),
            ],
            const Divider(),
            toolbar(l10n.buttonGroupsPageToolbarMenuLabel, [
              if (wide)
                ButtonGroup(
                  label: l10n.buttonGroupsPageCreateLabel,
                  children: [
                    outline(l10n.buttonGroupsPageNew),
                    outline(l10n.buttonGroupsPageEdit),
                    outline(l10n.buttonGroupsPageUndo),
                  ],
                ),
              MenuButton(
                label: l10n.buttonGroupsPageMenu,
                placement: const MenuPlacement(align: MenuAlign.end),
                menuChildren: [
                  menuItem(l10n.buttonGroupsPageItem('1')),
                  menuItem(l10n.buttonGroupsPageItem('2')),
                  menuItem(l10n.buttonGroupsPageItem('3')),
                ],
              ),
              ButtonGroup(
                label: l10n.buttonGroupsPageSaveLabel,
                children: [
                  outline(l10n.buttonGroupsPageSave),
                  outline(l10n.buttonGroupsPageCancel),
                ],
              ),
            ]),
          ]),
        ),
        DemoCard(
          title: l10n.buttonGroupsPageToggleTitle,
          description: l10n.buttonGroupsPageToggleDescription,
          child: const Wrap(
            spacing: Space.lg,
            runSpacing: Space.lg,
            children: [_AlignmentToggles(), _FormattingToggles()],
          ),
        ),
      ],
    );
  }
}

/// The toolbar's amount: a number between a currency sign and its cents.
class _AmountField extends StatelessWidget {
  const _AmountField();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 144,
    child: TextFormField(
      initialValue: '100',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: context.l10n.buttonGroupsPageAmount,
        prefixText: r'$ ',
        suffixText: '.00',
      ),
    ),
  );
}

/// The toolbar's size picker.
class _SizeSelect extends StatelessWidget {
  const _SizeSelect();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DropdownMenu<String>(
      width: 160,
      initialSelection: 'medium',
      label: Text(l10n.buttonGroupsPageSize),
      requestFocusOnTap: false,
      dropdownMenuEntries: [
        DropdownMenuEntry(value: 'large', label: l10n.buttonGroupsPageToolbarSizeLarge),
        DropdownMenuEntry(value: 'medium', label: l10n.buttonGroupsPageToolbarSizeMedium),
        DropdownMenuEntry(value: 'small', label: l10n.buttonGroupsPageToolbarSizeSmall),
      ],
    );
  }
}

enum _Alignment { left, center, right, justify }

enum _Format { bold, italic, underline }

/// A toggle group that keeps one choice.
class _AlignmentToggles extends StatefulWidget {
  const _AlignmentToggles();

  @override
  State<_AlignmentToggles> createState() => _AlignmentTogglesState();
}

class _AlignmentTogglesState extends State<_AlignmentToggles> {
  var _alignment = _Alignment.left;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label: l10n.buttonGroupsPageAlignmentLabel,
      child: SegmentedButton<_Alignment>(
        showSelectedIcon: false,
        segments: [
          for (final (value, icon, label) in [
            (_Alignment.left, LucideIcons.textAlignStart, l10n.buttonGroupsPageAlignLeft),
            (_Alignment.center, LucideIcons.textAlignCenter, l10n.buttonGroupsPageAlignCenter),
            (_Alignment.right, LucideIcons.textAlignEnd, l10n.buttonGroupsPageAlignRight),
            (_Alignment.justify, LucideIcons.textAlignJustify, l10n.buttonGroupsPageAlignJustify),
          ])
            ButtonSegment(value: value, icon: Icon(icon), tooltip: label),
        ],
        selected: {_alignment},
        onSelectionChanged: (selection) {
          Haptics.selection();
          setState(() => _alignment = selection.first);
        },
      ),
    );
  }
}

/// A toggle group that keeps several choices, or none.
class _FormattingToggles extends StatefulWidget {
  const _FormattingToggles();

  @override
  State<_FormattingToggles> createState() => _FormattingTogglesState();
}

class _FormattingTogglesState extends State<_FormattingToggles> {
  var _formats = {_Format.bold};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label: l10n.buttonGroupsPageFormattingLabel,
      child: SegmentedButton<_Format>(
        showSelectedIcon: false,
        multiSelectionEnabled: true,
        emptySelectionAllowed: true,
        segments: [
          for (final (value, icon, label) in [
            (_Format.bold, LucideIcons.bold, l10n.buttonGroupsPageBold),
            (_Format.italic, LucideIcons.italic, l10n.buttonGroupsPageItalic),
            (_Format.underline, LucideIcons.underline, l10n.buttonGroupsPageUnderline),
          ])
            ButtonSegment(value: value, icon: Icon(icon), tooltip: label),
        ],
        selected: _formats,
        onSelectionChanged: (selection) {
          Haptics.selection();
          setState(() => _formats = selection);
        },
      ),
    );
  }
}
