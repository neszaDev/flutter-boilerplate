import 'package:flutter_boilerplate/features/showcase/base/base_a_tones.dart';

// The data of the base demos (cards, carousels, list groups, switches), as on the web pages.

// ---------------------------------------------------------------------------------------------
// Cards

/// Outline and accent cards: the six card colours, with red pen left out (it only marks errors).
const cardRuledTones = [Tone.folder, Tone.ink, Tone.pass, Tone.deep, Tone.pencil, Tone.dark];

/// Filled cards with a quote.
const cardQuotedTones = [Tone.folder, Tone.pass, Tone.deep, Tone.pencil, Tone.dark, Tone.light];

/// Filled cards; a light card with header actions follows them.
const cardFilledTones = [Tone.folder, Tone.pass, Tone.deep, Tone.pencil, Tone.dark];

/// The count on the destructive badge of the "card with a label" example.
const cardBadgeCount = 42;

// ---------------------------------------------------------------------------------------------
// Carousels

/// The carousel moves on every 6 seconds (CoreUI's interval).
const carouselInterval = Duration(seconds: 6);

/// The three slides: two with captions, one with a picture.
enum CarouselSlide { first, blank, logo }

// ---------------------------------------------------------------------------------------------
// List groups

enum Subject { maths, physics, chemistry, biology, history }

/// The row shown as active in the "Active items" list.
const activeSubjectIndex = 1;

/// The rows shown as disabled in the "Disabled items" list.
const disabledSubjectIndexes = {0, 3};

/// Tests on file per subject, for the badges.
const subjectTestCounts = [
  (subject: Subject.maths, count: 14),
  (subject: Subject.physics, count: 2),
  (subject: Subject.chemistry, count: 1),
];

/// The subjects linked from the lists inside cards.
const cardListSubjects = [Subject.maths, Subject.physics, Subject.chemistry];

/// The rows of the custom-content list: how long ago each was marked, and its state.
enum CustomListItem {
  spanish(days: 3, isActive: true),
  physics(days: 5),
  disabled(days: 8, isDisabled: true);

  const CustomListItem({required this.days, this.isActive = false, this.isDisabled = false});

  final int days;
  final bool isActive;
  final bool isDisabled;
}

// ---------------------------------------------------------------------------------------------
// Switches

/// How the checked state of a `ToneSwitch` is drawn.
enum ToneSwitchVariant {
  /// The track fills with the tone.
  filled,

  /// Only the track's rim and the knob's rim take the tone.
  outline,

  /// An outline track with a knob filled in the tone.
  opposite,

  /// A raised knob as tall as the track, which fills with the tone (always a pill).
  threeD,
}

enum ToneSwitchShape { rounded, square, pill }

/// Track sizes: 32×22, 40×26 and 48×30 (8 wider with labels).
enum ToneSwitchSize { sm, md, lg }

/// On/off labels inside a row's tracks: icons, or icons with the first switch spelling yes/no.
enum SwitchRowLabels { icons, textFirst }

/// The cards after the radio and default ones, in order: each repeats the tone row in one style.
enum SwitchRowStyle {
  pills(shape: ToneSwitchShape.pill),
  threeD(variant: ToneSwitchVariant.threeD),
  threeDDisabled(variant: ToneSwitchVariant.threeD, disabled: true),
  threeDLabel(variant: ToneSwitchVariant.threeD, labels: SwitchRowLabels.icons),
  outline(variant: ToneSwitchVariant.outline),
  outlinePill(variant: ToneSwitchVariant.outline, shape: ToneSwitchShape.pill),
  opposite(variant: ToneSwitchVariant.opposite),
  oppositePill(variant: ToneSwitchVariant.opposite, shape: ToneSwitchShape.pill),
  label(labels: SwitchRowLabels.icons),
  labelPill(shape: ToneSwitchShape.pill, labels: SwitchRowLabels.icons),
  labelOutline(variant: ToneSwitchVariant.outline, labels: SwitchRowLabels.icons),
  labelOutlinePill(
    variant: ToneSwitchVariant.outline,
    shape: ToneSwitchShape.pill,
    labels: SwitchRowLabels.icons,
  ),
  labelOpposite(variant: ToneSwitchVariant.opposite, labels: SwitchRowLabels.icons),
  labelOppositePill(
    variant: ToneSwitchVariant.opposite,
    shape: ToneSwitchShape.pill,
    labels: SwitchRowLabels.textFirst,
  );

  const SwitchRowStyle({
    this.variant = ToneSwitchVariant.filled,
    this.shape = ToneSwitchShape.rounded,
    this.labels,
    this.disabled = false,
  });

  final ToneSwitchVariant variant;
  final ToneSwitchShape shape;
  final SwitchRowLabels? labels;

  /// Disables the tone switches too (the row's last switch always is).
  final bool disabled;
}

/// The radio demo lists the tones in the Vue order, where warning comes before success.
const radioSwitchTones = [
  Tone.folder,
  Tone.ink,
  Tone.pencil,
  Tone.pass,
  Tone.deep,
  Tone.pen,
  Tone.light,
  Tone.dark,
];

/// The tone the radio switches start on.
const radioSwitchInitial = Tone.pencil;

/// The rows of the sizes table, largest first.
const switchSizes = [ToneSwitchSize.lg, ToneSwitchSize.md, ToneSwitchSize.sm];
