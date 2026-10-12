import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/forms/form_demo_widgets.dart';
import 'package:flutter_boilerplate/features/showcase/forms/forms_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// The input-group cards of the basic forms page: addons (text, icons, buttons, menus) inside
// the field's border, the split grids, the example forms and the closable card.

/// A compact filled button that fits inside a field; [base] wins where it sets a value.
ButtonStyle _addonButtonStyle(BuildContext context, {ButtonStyle? base}) {
  final compact = FilledButton.styleFrom(
    minimumSize: const Size(44, 40),
    padding: const EdgeInsets.symmetric(horizontal: Space.md),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
  return base == null ? compact : base.merge(compact);
}

/// Text inside a field, before or after the input (the web's `InputGroupText`).
class _AddonText extends StatelessWidget {
  const _AddonText(this.text, {this.strong = false});

  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.md),
      child: Text(
        text,
        style: context.text.bodyMedium?.copyWith(
          color: strong ? context.colors.ink700 : context.colors.ink600,
          fontWeight: strong ? FontWeight.w600 : null,
        ),
      ),
    ),
  );
}

/// Room around a button inside a field.
class _AddonSlot extends StatelessWidget {
  const _AddonSlot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(Space.xs), child: child);
}

/// An input with addons attached inside its border (the web's `FieldGroup`). [label] names it
/// for screen readers when it has no printed label; inside a [LabeledField], leave it null.
class GroupField extends StatelessWidget {
  const GroupField({
    this.label,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.helperText,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.figures = false,
    super.key,
  });

  final String? label;
  final String? placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final String? helperText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;

  /// Tabular figures, for amounts.
  final bool figures;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: !obscureText && keyboardType != TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: autofillHints,
      style: figures ? context.type.table.copyWith(fontSize: 15) : null,
      decoration: InputDecoration(
        hintText: placeholder,
        helperText: helperText,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
    );
    final label = this.label;
    return label == null ? field : Semantics(label: label, child: field);
  }
}

const _iconSize = 18.0;
const _rows = SizedBox(height: Space.page);

/// One input of the grids, sized `span` of 12 columns.
class GridInput extends StatelessWidget {
  const GridInput({required this.span, super.key});

  final int span;

  @override
  Widget build(BuildContext context) {
    final text = context.l10n.basicFormsPageGridPlaceholder('$span');
    return Semantics(
      label: text,
      child: TextFormField(decoration: InputDecoration(hintText: text)),
    );
  }
}

/// Icons and text attached before or after the input.
class IconGroupsCard extends StatelessWidget {
  const IconGroupsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.basicFormsPageIconGroupsTitle,
      description: l10n.basicFormsPageIconGroupsDescription,
      child: DemoForm(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GroupField(
              label: l10n.basicFormsPageUsername,
              placeholder: l10n.basicFormsPageUsername,
              prefix: const Icon(LucideIcons.user, size: _iconSize),
            ),
            _rows,
            GroupField(
              label: l10n.basicFormsPageEmail,
              placeholder: l10n.basicFormsPageEmail,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              suffix: const Icon(LucideIcons.mailOpen, size: _iconSize),
            ),
            _rows,
            GroupField(
              label: l10n.basicFormsPageAmount,
              placeholder: l10n.basicFormsPageAmountPlaceholder,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              figures: true,
              prefix: const Icon(LucideIcons.euro, size: _iconSize),
              suffix: const _AddonText('.00'),
            ),
            const SizedBox(height: Space.card),
            const SubmitResetActions(),
          ],
        ),
      ),
    );
  }
}

/// Buttons attached to the input, brand icon buttons included.
class ButtonGroupsCard extends StatelessWidget {
  const ButtonGroupsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final iconStyle = IconButton.styleFrom(
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
    );
    return DemoCard(
      title: l10n.basicFormsPageButtonGroupsTitle,
      description: l10n.basicFormsPageButtonGroupsDescription,
      child: DemoForm(
        child: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GroupField(
                label: l10n.basicFormsPageUsername,
                placeholder: l10n.basicFormsPageUsername,
                prefix: _AddonSlot(
                  child: FilledButton.icon(
                    style: _addonButtonStyle(context),
                    onPressed: () {},
                    icon: const Icon(LucideIcons.search, size: 16),
                    label: Text(l10n.basicFormsPageSearch),
                  ),
                ),
              ),
              _rows,
              GroupField(
                label: l10n.basicFormsPageEmail,
                placeholder: l10n.basicFormsPageEmail,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                suffix: _AddonSlot(
                  child: FilledButton(
                    style: _addonButtonStyle(context),
                    onPressed: DemoForm.of(context).submit,
                    child: Text(l10n.basicFormsPageSubmit),
                  ),
                ),
              ),
              _rows,
              GroupField(
                label: l10n.basicFormsPageEmail,
                placeholder: l10n.basicFormsPageEmail,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                prefix: _AddonSlot(
                  child: IconButton(
                    style: iconStyle,
                    tooltip: l10n.basicFormsPageFacebook,
                    onPressed: () {},
                    icon: const FaIcon(FontAwesomeIcons.facebookF, size: 16),
                  ),
                ),
                suffix: _AddonSlot(
                  child: IconButton(
                    style: iconStyle,
                    tooltip: l10n.basicFormsPageTwitter,
                    onPressed: () {},
                    icon: const FaIcon(FontAwesomeIcons.twitter, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: Space.card),
              const SubmitResetActions(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "Action" menu attached to an input, or a split button ("Split" plus a caret that opens
/// the menu) with [split]. The menu items do nothing, as on the web.
class ActionMenu extends StatelessWidget {
  const ActionMenu({this.split = false, super.key});

  final bool split;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(onPressed: () {}, child: Text(l10n.basicFormsPageAction)),
        MenuItemButton(onPressed: () {}, child: Text(l10n.basicFormsPageAnotherAction)),
        MenuItemButton(onPressed: () {}, child: Text(l10n.basicFormsPageSomethingElse)),
        MenuItemButton(child: Text(l10n.basicFormsPageDisabledAction)),
      ],
      builder: (context, controller, _) {
        void toggle() => controller.isOpen ? controller.close() : controller.open();
        if (!split) {
          return FilledButton.icon(
            style: _addonButtonStyle(context),
            onPressed: toggle,
            iconAlignment: IconAlignment.end,
            icon: const Icon(LucideIcons.chevronDown, size: 16),
            label: Text(l10n.basicFormsPageAction),
          );
        }
        const radius = Radius.circular(Radii.md);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              style: _addonButtonStyle(
                context,
                base: FilledButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(left: radius),
                  ),
                ),
              ),
              onPressed: () {},
              child: Text(l10n.basicFormsPageSplit),
            ),
            const SizedBox(width: 1),
            Tooltip(
              message: l10n.basicFormsPageMoreActions,
              child: FilledButton(
                style: _addonButtonStyle(
                  context,
                  base: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(right: radius),
                    ),
                  ),
                ),
                onPressed: toggle,
                child: const Icon(LucideIcons.chevronDown, size: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Action menus and a split button attached to the input.
class DropdownGroupsCard extends StatelessWidget {
  const DropdownGroupsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: l10n.basicFormsPageDropdownGroupsTitle,
      description: l10n.basicFormsPageDropdownGroupsDescription,
      child: DemoForm(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GroupField(
              label: l10n.basicFormsPageUsername,
              placeholder: l10n.basicFormsPageUsername,
              prefix: const _AddonSlot(child: ActionMenu()),
            ),
            _rows,
            GroupField(
              label: l10n.basicFormsPageEmail,
              placeholder: l10n.basicFormsPageEmail,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              suffix: const _AddonSlot(child: ActionMenu()),
            ),
            _rows,
            GroupField(
              label: l10n.basicFormsPageNotes,
              placeholder: '…',
              prefix: const _AddonSlot(child: ActionMenu(split: true)),
              suffix: const _AddonSlot(child: ActionMenu()),
            ),
            const SizedBox(height: Space.card),
            const SubmitResetActions(),
          ],
        ),
      ),
    );
  }
}

/// The buttons of the split grids: one of each Marksheet variant.
class _VariantActions extends StatelessWidget {
  const _VariantActions();

  @override
  Widget build(BuildContext context) {
    final action = Text(context.l10n.basicFormsPageAction);
    return FormActions(
      children: [
        FilledButton(onPressed: () {}, child: action),
        FilledButton(style: destructiveButtonStyle(context), onPressed: () {}, child: action),
        OutlinedButton(onPressed: () {}, child: action),
        FilledButton.tonal(onPressed: () {}, child: action),
        TextButton(onPressed: () {}, child: action),
      ],
    );
  }
}

/// Pairs of inputs splitting 12 columns: [stackOnPhones] stacks them below the breakpoint (the
/// web's grid for large screens), otherwise they keep their split at every width.
class SplitGridCard extends StatelessWidget {
  const SplitGridCard({required this.stackOnPhones, super.key});

  final bool stackOnPhones;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DemoCard(
      title: stackOnPhones ? l10n.basicFormsPageGridLargeTitle : l10n.basicFormsPageGridSmallTitle,
      description: stackOnPhones
          ? l10n.basicFormsPageGridLargeDescription
          : l10n.basicFormsPageGridSmallDescription,
      child: DemoForm(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = stackOnPhones && constraints.maxWidth < HorizontalField.breakpoint;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final span in splitSpans) ...[
                  // The large grid puts the rest first, the small one the span.
                  if (stacked) ...[
                    GridInput(span: 12 - span),
                    const SizedBox(height: Space.md),
                    GridInput(span: span),
                  ] else
                    Row(
                      children: [
                        for (final (index, part)
                            in (stackOnPhones ? [12 - span, span] : [span, 12 - span]).indexed) ...[
                          if (index > 0) const SizedBox(width: Space.md),
                          Expanded(
                            flex: part,
                            child: GridInput(span: part),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: Space.md),
                ],
                const SizedBox(height: Space.sm),
                const _VariantActions(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Which example form: text in front and an icon at the end, icons at the end, or in front.
enum ExampleFormVariant { text, append, prepend }

/// One of the three example sign-in forms, by [variant].
class ExampleFormCard extends StatelessWidget {
  const ExampleFormCard({required this.variant, super.key});

  final ExampleFormVariant variant;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fields = [
      (l10n.basicFormsPageUsername, LucideIcons.user, AutofillHints.username, false),
      (l10n.basicFormsPageEmail, LucideIcons.mail, AutofillHints.email, false),
      (l10n.basicFormsPagePassword, LucideIcons.lockKeyhole, AutofillHints.password, true),
    ];
    final submit = Text(l10n.basicFormsPageSubmit);
    return DemoCard(
      title: l10n.basicFormsPageExampleTitle,
      description: switch (variant) {
        ExampleFormVariant.text => l10n.basicFormsPageExampleTextDescription,
        ExampleFormVariant.append => l10n.basicFormsPageExampleAppendDescription,
        ExampleFormVariant.prepend => l10n.basicFormsPageExamplePrependDescription,
      },
      child: DemoForm(
        child: AutofillGroup(
          child: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (label, icon, autofill, secret) in fields) ...[
                  GroupField(
                    label: label,
                    placeholder: variant == ExampleFormVariant.text ? null : label,
                    obscureText: secret,
                    keyboardType: autofill == AutofillHints.email
                        ? TextInputType.emailAddress
                        : null,
                    autofillHints: [autofill],
                    prefix: switch (variant) {
                      ExampleFormVariant.text => _AddonText(label, strong: true),
                      ExampleFormVariant.prepend => Icon(icon, size: _iconSize),
                      ExampleFormVariant.append => null,
                    },
                    suffix: variant == ExampleFormVariant.prepend
                        ? null
                        : Icon(icon, size: _iconSize),
                  ),
                  _rows,
                ],
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: switch (variant) {
                    ExampleFormVariant.text => FilledButton(
                      onPressed: DemoForm.of(context).submit,
                      child: submit,
                    ),
                    ExampleFormVariant.append => FilledButton.tonal(
                      onPressed: DemoForm.of(context).submit,
                      child: submit,
                    ),
                    ExampleFormVariant.prepend => OutlinedButton(
                      onPressed: DemoForm.of(context).submit,
                      child: submit,
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A demo card whose header collapses its body and closes the card; a closed card leaves a
/// note with a button to bring it back (the web's `ClosableCard` with the form elements).
class FormElementsCard extends StatefulWidget {
  const FormElementsCard({super.key});

  @override
  State<FormElementsCard> createState() => _FormElementsCardState();
}

class _FormElementsCardState extends State<FormElementsCard> {
  bool _open = true;
  bool _shown = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final title = l10n.basicFormsPageFormElementsTitle;

    if (!_shown) {
      return Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Space.card, vertical: Space.page),
          decoration: BoxDecoration(
            border: Border.all(color: colors.ink300),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Wrap(
            spacing: Space.md,
            runSpacing: Space.md,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.basicFormsPageCardClosed(title),
                style: context.text.bodyMedium?.copyWith(color: colors.ink600),
              ),
              OutlinedButton(
                onPressed: () => setState(() => _shown = true),
                child: Text(l10n.basicFormsPageShowCard),
              ),
            ],
          ),
        ),
      );
    }

    return DemoCard(
      title: title,
      padding: _open ? const EdgeInsets.all(Space.card) : EdgeInsets.zero,
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: _open ? l10n.basicFormsPageCollapseCard : l10n.basicFormsPageExpandCard,
            icon: Icon(_open ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 18),
            onPressed: () => setState(() => _open = !_open),
          ),
          IconButton(
            tooltip: l10n.basicFormsPageCloseCard,
            icon: const Icon(LucideIcons.x, size: 18),
            onPressed: () => setState(() => _shown = false),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: _open ? const _FormElements() : const SizedBox(width: double.infinity),
      ),
    );
  }
}

class _FormElements extends StatelessWidget {
  const _FormElements();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final help = l10n.basicFormsPageHelpText;
    const decimal = TextInputType.numberWithOptions(decimal: true);

    Widget row(String label, Widget field) => LabeledField(label: label, child: field);

    return DemoForm(
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row(
              l10n.basicFormsPagePrependedLabel,
              GroupField(
                helperText: help,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                prefix: const _AddonText('@'),
              ),
            ),
            const SizedBox(height: Space.card),
            row(
              l10n.basicFormsPageAppendedLabel,
              GroupField(
                helperText: help,
                keyboardType: decimal,
                figures: true,
                suffix: const _AddonText('.00'),
              ),
            ),
            const SizedBox(height: Space.card),
            row(
              l10n.basicFormsPageAppendedPrependedLabel,
              GroupField(
                helperText: help,
                keyboardType: decimal,
                figures: true,
                prefix: const _AddonText(r'$'),
                suffix: const _AddonText('.00'),
              ),
            ),
            const SizedBox(height: Space.card),
            row(
              l10n.basicFormsPageAppendButtonLabel,
              GroupField(
                helperText: help,
                suffix: _AddonSlot(
                  child: FilledButton(
                    style: _addonButtonStyle(context),
                    onPressed: () {},
                    child: Text(l10n.basicFormsPageGo),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Space.card),
            row(
              l10n.basicFormsPageTwoButtonsLabel,
              GroupField(
                suffix: _AddonSlot(
                  // Long translations shrink the pair rather than push the input out.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          style: _addonButtonStyle(context),
                          onPressed: () {},
                          child: Text(l10n.basicFormsPageSearch),
                        ),
                        const SizedBox(width: Space.xs),
                        FilledButton(
                          style: _addonButtonStyle(context, base: destructiveButtonStyle(context)),
                          onPressed: () {},
                          child: Text(l10n.basicFormsPageOptions),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Space.card),
            FormActions(
              children: [
                FilledButton(
                  onPressed: DemoForm.of(context).submit,
                  child: Text(l10n.basicFormsPageSaveChanges),
                ),
                OutlinedButton(
                  onPressed: DemoForm.of(context).reset,
                  child: Text(l10n.basicFormsPageCancel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
