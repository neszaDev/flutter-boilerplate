import 'dart:math' as math;
import 'dart:ui';

/// Two series over seven months (`CChartLineExample`).
const lineSeriesOne = <double>[30, 39, 10, 50, 30, 70, 35];
const lineSeriesTwo = <double>[39, 80, 40, 35, 40, 20, 45];

/// Commits per month over a year (`CChartBarExample`).
const commits = <double>[40, 20, 12, 39, 10, 40, 39, 80, 40, 20, 12, 11];

/// Share per framework, for the doughnut and pie (`CChartDoughnutExample`, `CChartPieExample`).
const frameworks = <({String name, double value})>[
  (name: 'Vue.js', value: 40),
  (name: 'Ember.js', value: 20),
  (name: 'React', value: 80),
  (name: 'Angular', value: 10),
];

enum Activity { eating, drinking, sleeping, designing, coding, cycling, running }

/// Hours per activity in two years (`CChartRadarExample`, `CChartPolarAreaExample`).
const activities = <({Activity id, double y2019, double y2020})>[
  (id: Activity.eating, y2019: 65, y2020: 28),
  (id: Activity.drinking, y2019: 59, y2020: 48),
  (id: Activity.sleeping, y2019: 90, y2020: 40),
  (id: Activity.designing, y2019: 81, y2020: 19),
  (id: Activity.coding, y2019: 56, y2020: 96),
  (id: Activity.cycling, y2019: 55, y2020: 27),
  (id: Activity.running, y2019: 40, y2020: 100),
];

/// The two years of the radar and polar charts, in legend order.
const activityYears = ['2019', '2020'];

/// The largest hour count of either year: the outer edge of the polar chart.
final double maxHours = activities.map((row) => math.max(row.y2019, row.y2020)).reduce(math.max);

/// The pie sectors start at twelve o'clock and run clockwise.
const pieStartDegrees = -90.0;

/// Which of [count] equal sectors of a circle filling [size] holds [position], or null when
/// [position] is outside the circle. Sectors start at [startDegrees] (0 is three o'clock) and
/// run clockwise, as fl_chart draws them.
int? sectorAt(Offset position, Size size, int count, {double startDegrees = pieStartDegrees}) {
  if (count <= 0) {
    return null;
  }
  final center = size.center(Offset.zero);
  final offset = position - center;
  if (offset.distance > size.shortestSide / 2) {
    return null;
  }
  final degrees = offset.direction * 180 / math.pi;
  final fromStart = (degrees - startDegrees) % 360;
  return (fromStart / (360 / count)).floor().clamp(0, count - 1);
}
