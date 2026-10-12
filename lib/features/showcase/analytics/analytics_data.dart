import 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart';

/// The traffic chart's periods, in toggle order.
enum Period { day, month, year }

int _pointsOf(Period period) => switch (period) {
  Period.day => 24,
  Period.month => 28,
  Period.year => 12,
};

int _seedOf(Period period) => switch (period) {
  Period.day => 24,
  Period.month => 28,
  Period.year => 2017,
};

/// The dashed target line of the traffic chart.
const trafficTarget = 65;

/// The traffic chart's y-axis ceiling.
const trafficMax = 250.0;

/// A small seeded generator (Park-Miller), so the "random" demo series is the same on every
/// run and matches the web app's.
double Function() _seeded(int seed) {
  const modulus = 2147483647;
  var state = seed % modulus;
  if (state == 0) {
    state = 1;
  }
  return () {
    state = state * 16807 % modulus;
    return (state - 1) / (modulus - 1);
  };
}

typedef TrafficPoint = ({int index, int visits, int unique});

/// The traffic chart's two series for [period] (`MainChartExample.vue`): visits between 50
/// and 200 and unique visitors between 80 and 100, one point per hour (day), day of the four
/// weeks (month) or month (year), the same on every call.
List<TrafficPoint> trafficSeries(Period period) {
  final random = _seeded(_seedOf(period));
  int between(int min, int max) => (random() * (max - min + 1) + min).floor();
  return [
    for (var index = 0; index < _pointsOf(period); index++)
      (index: index, visits: between(50, 200), unique: between(80, 100)),
  ];
}

/// Quotes a CSV field when it holds a comma, a quote or a line break.
String _csvField(Object field) {
  final text = '$field';
  return RegExp(r'[",\n\r]').hasMatch(text) ? '"${text.replaceAll('"', '""')}"' : text;
}

/// The traffic series as CSV, for the chart's share button: [header] (the x label, visits,
/// unique visitors, target), then one line per row, CRLF line ends.
String trafficCsv(List<String> header, List<(String, num, num, num)> rows) => [
  header.map(_csvField).join(','),
  for (final (label, visits, unique, target) in rows)
    [label, visits, unique, target].map(_csvField).join(','),
].join('\r\n');

enum TrafficTotalId { visits, unique, pageviews, newUsers, bounceRate }

/// The traffic card's footer figures, left to right.
const trafficTotals = <({TrafficTotalId id, int count, double percent, Tone tone})>[
  (id: TrafficTotalId.visits, count: 29703, percent: 40, tone: Tone.pass),
  (id: TrafficTotalId.unique, count: 24093, percent: 20, tone: Tone.ink),
  (id: TrafficTotalId.pageviews, count: 78706, percent: 60, tone: Tone.slate),
  (id: TrafficTotalId.newUsers, count: 22123, percent: 80, tone: Tone.pencil),
  (id: TrafficTotalId.bounceRate, count: 0, percent: 40.15, tone: Tone.folder),
];

/// New and recurring clients per weekday (percentages), Monday first.
const clientsByDay = <({double fresh, double recurring})>[
  (fresh: 34, recurring: 78),
  (fresh: 56, recurring: 94),
  (fresh: 12, recurring: 67),
  (fresh: 43, recurring: 91),
  (fresh: 22, recurring: 73),
  (fresh: 53, recurring: 82),
  (fresh: 9, recurring: 69),
];

/// The callout figures of the traffic and sales card.
const salesCallouts = (newClients: 9123, recurringClients: 22643, pageviews: 78623, organic: 49123);

/// Visitors by gender, in percent.
const genderSplit = (male: 43.0, female: 37.0);

enum SourceId { organic, facebook, twitter, linkedin }

/// Visits by source: a count and its share in percent.
const sources = <({SourceId id, Brand? brand, int count, double percent})>[
  (id: SourceId.organic, brand: null, count: 191235, percent: 56),
  (id: SourceId.facebook, brand: Brand.facebook, count: 51223, percent: 15),
  (id: SourceId.twitter, brand: Brand.twitter, count: 37564, percent: 11),
  (id: SourceId.linkedin, brand: Brand.linkedin, count: 27319, percent: 8),
];

enum Presence { online, busy, away, offline }

/// The moment the sample activity is measured from, fixed so the screen reads the same
/// everywhere.
final activityNow = DateTime.utc(2026, 10, 2, 9);

const _minute = 60;
const _hour = 60 * _minute;
const _day = 24 * _hour;

/// A row of the dashboard's users table, like a row from an API.
typedef AnalyticsUser = ({
  int id,
  String name,
  Presence presence,
  bool isNew,
  DateTime registered,
  String country,
  double usage,
  DateTime usageFrom,
  DateTime usageTo,
  Brand payment,
  String paymentName,
  int lastSeenSecondsAgo,
});

final analyticsUsers = <AnalyticsUser>[
  (
    id: 1,
    name: 'Yiorgos Avraamu',
    presence: Presence.online,
    isNew: true,
    registered: DateTime.utc(2026),
    country: 'US',
    usage: 50,
    usageFrom: DateTime.utc(2026, 8, 11),
    usageTo: DateTime.utc(2026, 9, 10),
    payment: Brand.mastercard,
    paymentName: 'Mastercard',
    lastSeenSecondsAgo: 10,
  ),
  (
    id: 2,
    name: 'Avram Tarasios',
    presence: Presence.busy,
    isNew: false,
    registered: DateTime.utc(2026),
    country: 'BR',
    usage: 22,
    usageFrom: DateTime.utc(2026, 8, 11),
    usageTo: DateTime.utc(2026, 9, 10),
    payment: Brand.visa,
    paymentName: 'Visa',
    lastSeenSecondsAgo: 5 * _minute,
  ),
  (
    id: 3,
    name: 'Quintin Ed',
    presence: Presence.away,
    isNew: true,
    registered: DateTime.utc(2026),
    country: 'IN',
    usage: 74,
    usageFrom: DateTime.utc(2026, 8, 11),
    usageTo: DateTime.utc(2026, 9, 10),
    payment: Brand.stripe,
    paymentName: 'Stripe',
    lastSeenSecondsAgo: _hour,
  ),
  (
    id: 4,
    name: 'Enéas Kwadwo',
    presence: Presence.offline,
    isNew: true,
    registered: DateTime.utc(2026),
    country: 'FR',
    usage: 98,
    usageFrom: DateTime.utc(2026, 8, 11),
    usageTo: DateTime.utc(2026, 9, 10),
    payment: Brand.paypal,
    paymentName: 'PayPal',
    lastSeenSecondsAgo: 31 * _day,
  ),
  (
    id: 5,
    name: 'Agapetus Tadeáš',
    presence: Presence.online,
    isNew: true,
    registered: DateTime.utc(2026),
    country: 'ES',
    usage: 22,
    usageFrom: DateTime.utc(2026, 8, 11),
    usageTo: DateTime.utc(2026, 9, 10),
    payment: Brand.googlePay,
    paymentName: 'Google Pay',
    lastSeenSecondsAgo: 7 * _day,
  ),
  (
    id: 6,
    name: 'Friderik Dávid',
    presence: Presence.busy,
    isNew: true,
    registered: DateTime.utc(2026),
    country: 'PL',
    usage: 43,
    usageFrom: DateTime.utc(2026, 8, 11),
    usageTo: DateTime.utc(2026, 9, 10),
    payment: Brand.amex,
    paymentName: 'American Express',
    lastSeenSecondsAgo: 7 * _day,
  ),
];

/// The bar colour for a usage share, by quarter (info, success, warning, danger in Vue).
Tone usageTone(double value) {
  if (value <= 25) {
    return Tone.ink;
  }
  if (value <= 50) {
    return Tone.pass;
  }
  if (value <= 75) {
    return Tone.slate;
  }
  return Tone.pencil;
}

enum RelativeUnit { second, minute, hour, day, week, month, year }

/// How long ago [seconds] is, in the unit next-intl's `relativeTime` picks: seconds under a
/// minute, minutes under an hour… months under a year (a month being 365/12 days), rounded.
({RelativeUnit unit, int value}) relativeTime(int seconds) {
  const week = 7 * _day;
  const month = _day * 365 / 12;
  const year = 365 * _day;
  final size = seconds.abs();
  final (unit, length) = switch (size) {
    < _minute => (RelativeUnit.second, 1.0),
    < _hour => (RelativeUnit.minute, _minute.toDouble()),
    < _day => (RelativeUnit.hour, _hour.toDouble()),
    < week => (RelativeUnit.day, _day.toDouble()),
    < month => (RelativeUnit.week, week.toDouble()),
    < year => (RelativeUnit.month, month),
    _ => (RelativeUnit.year, year.toDouble()),
  };
  return (unit: unit, value: (seconds / length).round());
}
