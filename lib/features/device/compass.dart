import 'dart:math' as math;

/// Compass heading in degrees (0 = magnetic north, clockwise) from a magnetometer reading,
/// for a phone lying flat, screen up. A tilted phone needs the accelerometer as well
/// (tilt compensation); this demo keeps to the flat case.
double headingFromMagnetometer(double x, double y) {
  final degrees = math.atan2(-x, y) * 180 / math.pi;
  return (degrees + 360) % 360;
}

/// The eight compass points.
enum CompassPoint { n, ne, e, se, s, sw, w, nw }

/// The nearest of the eight points to [heading].
CompassPoint compassPoint(double heading) =>
    CompassPoint.values[((heading % 360) / 45).round() % 8];
