/// The Marksheet stand-ins for the Bootstrap colour variants the CoreUI widgets used:
/// primary → folder, success → pass, info → ink, warning → slate (ink 600/400), danger → pencil.
/// Red pen stays reserved for errors, so no demo variant uses it. Colours: `ToneColors`.
enum Tone { folder, pass, ink, slate, pencil }

/// The default series of the CoreUI simple charts, one value per month.
const salesPoints = <double>[10, 22, 34, 46, 58, 70, 46, 23, 45, 78, 34, 12];

/// The progress bars' value in every widget demo, in percent.
const progressValue = 25.0;

enum SparklineKind { line, bar }

/// The small chart of a dropdown widget.
typedef DropdownChart = ({
  SparklineKind kind,
  List<double> points,
  bool pointed,
  bool linear,
  bool area,
});

enum DropdownIcon { settings, pin }

/// A filled widget with a menu and a sparkline (`WidgetsDropdown.vue`).
typedef DropdownWidget = ({
  String id,
  Tone tone,
  int value,
  DropdownIcon icon,
  DropdownChart chart,
});

/// The four filled widgets with a menu and a sparkline.
const dropdownWidgets = <DropdownWidget>[
  (
    id: 'members-folder',
    tone: Tone.folder,
    value: 9823,
    icon: DropdownIcon.settings,
    chart: (
      kind: SparklineKind.line,
      points: [65, 59, 84, 84, 51, 55, 40],
      pointed: true,
      linear: false,
      area: false,
    ),
  ),
  (
    id: 'members-ink',
    tone: Tone.ink,
    value: 9823,
    icon: DropdownIcon.pin,
    chart: (
      kind: SparklineKind.line,
      points: [1, 18, 9, 17, 34, 22, 11],
      pointed: true,
      linear: true,
      area: false,
    ),
  ),
  (
    id: 'members-slate',
    tone: Tone.slate,
    value: 9823,
    icon: DropdownIcon.settings,
    chart: (
      kind: SparklineKind.line,
      points: [78, 81, 80, 45, 34, 12, 40],
      pointed: false,
      linear: false,
      area: true,
    ),
  ),
  (
    id: 'members-pencil',
    tone: Tone.pencil,
    value: 9823,
    icon: DropdownIcon.settings,
    chart: (
      kind: SparklineKind.bar,
      points: salesPoints,
      pointed: false,
      linear: false,
      area: false,
    ),
  ),
];

/// One-colour brand logos (Font Awesome stands in for `@coreui/icons`).
enum Brand { facebook, twitter, linkedin, mastercard, visa, stripe, paypal, googlePay, amex }

enum BrandWidgetIcon { facebook, twitter, linkedin, calendar }

enum BrandLabel { friends, feeds, followers, tweets, contacts, events, meetings }

/// A figure of a brand widget: [compact] prints 89K, [atLeast] prints 500+.
typedef BrandFigure = ({int value, BrandLabel label, bool compact, bool atLeast});

/// A social widget (`WidgetsBrand.vue`): a logo band, a sparkline and two figures.
typedef BrandWidget = ({
  BrandWidgetIcon icon,
  Tone tone,
  List<double> points,
  BrandFigure left,
  BrandFigure right,
});

const brandWidgets = <BrandWidget>[
  (
    icon: BrandWidgetIcon.facebook,
    tone: Tone.ink,
    points: [65, 59, 84, 84, 51, 55, 40],
    left: (value: 89000, label: BrandLabel.friends, compact: true, atLeast: false),
    right: (value: 459, label: BrandLabel.feeds, compact: false, atLeast: false),
  ),
  (
    icon: BrandWidgetIcon.twitter,
    tone: Tone.slate,
    points: [1, 13, 9, 17, 34, 41, 38],
    left: (value: 973000, label: BrandLabel.followers, compact: true, atLeast: false),
    right: (value: 1792, label: BrandLabel.tweets, compact: false, atLeast: false),
  ),
  (
    icon: BrandWidgetIcon.linkedin,
    tone: Tone.folder,
    points: [78, 81, 80, 45, 34, 12, 40],
    left: (value: 500, label: BrandLabel.contacts, compact: false, atLeast: true),
    right: (value: 292, label: BrandLabel.feeds, compact: false, atLeast: false),
  ),
  (
    icon: BrandWidgetIcon.calendar,
    tone: Tone.pencil,
    points: [35, 23, 56, 22, 97, 23, 64],
    left: (value: 12, label: BrandLabel.events, compact: false, atLeast: false),
    right: (value: 4, label: BrandLabel.meetings, compact: false, atLeast: false),
  ),
];

/// The four tones the progress, icon and simple widget rows walk through, in Vue order.
const rowTones = [Tone.pass, Tone.ink, Tone.slate, Tone.pencil];

/// The tones of the icon widgets (primary, info, warning, danger in Vue).
const iconTones = [Tone.folder, Tone.ink, Tone.slate, Tone.pencil];

enum ProgressIconId { visitors, newClients, productsSold, returning, avgTime, comments }

/// The progress-icon widgets (`CWidgetProgressIcon`), in Vue order; the sixth only shows in
/// grids.
const progressIconWidgets = <({ProgressIconId id, Tone tone})>[
  (id: ProgressIconId.visitors, tone: Tone.ink),
  (id: ProgressIconId.newClients, tone: Tone.pass),
  (id: ProgressIconId.productsSold, tone: Tone.slate),
  (id: ProgressIconId.returning, tone: Tone.folder),
  (id: ProgressIconId.avgTime, tone: Tone.pencil),
  (id: ProgressIconId.comments, tone: Tone.ink),
];

enum SimpleWidgetId { sessions, signUps, downloads, orders, refunds, reviews }

/// The simple widgets with a small chart (`CWidgetSimple`).
const simpleWidgets = <({SimpleWidgetId id, int value, SparklineKind kind, Tone tone})>[
  (id: SimpleWidgetId.sessions, value: 1123, kind: SparklineKind.line, tone: Tone.pencil),
  (id: SimpleWidgetId.signUps, value: 1123, kind: SparklineKind.line, tone: Tone.folder),
  (id: SimpleWidgetId.downloads, value: 1123, kind: SparklineKind.line, tone: Tone.pass),
  (id: SimpleWidgetId.orders, value: 1123, kind: SparklineKind.bar, tone: Tone.pencil),
  (id: SimpleWidgetId.refunds, value: 1123, kind: SparklineKind.bar, tone: Tone.folder),
  (id: SimpleWidgetId.reviews, value: 1123, kind: SparklineKind.bar, tone: Tone.pass),
];
