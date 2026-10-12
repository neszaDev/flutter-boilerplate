import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

/// A place pinned on the map, drawn as a marker with a one-letter label.
class MapPlace {
  const MapPlace({
    required this.label,
    required this.name,
    required this.position,
    required this.website,
  });

  final String label;
  final String name;
  final LatLng position;
  final String website;
}

/// The Vue demo's markers: four places around Palo Alto.
const mapPlaces = [
  MapPlace(
    label: 'S',
    name: 'Stanford',
    position: LatLng(37.431489, -122.163719),
    website: 'https://www.stanford.edu/',
  ),
  MapPlace(
    label: 'T',
    name: 'Tesla',
    position: LatLng(37.394694, -122.150333),
    website: 'https://www.tesla.com/',
  ),
  MapPlace(
    label: 'A',
    name: 'Apple',
    position: LatLng(37.331681, -122.0301),
    website: 'https://www.apple.com/',
  ),
  MapPlace(
    label: 'F',
    name: 'Facebook',
    position: LatLng(37.484722, -122.148333),
    website: 'https://www.facebook.com/',
  ),
];

/// Where the map opens (Stanford) and how close.
const mapCenter = LatLng(37.431489, -122.163719);
const mapInitialZoom = 11.0;
const mapMinZoom = 3.0;
const mapMaxZoom = 18.0;

/// Where the OpenStreetMap licence and attribution live.
final osmCopyright = Uri.parse('https://www.openstreetmap.org/copyright');

/// The place whose info is open after tapping [label]: tapping the open one closes it.
String? toggledPlace(String? open, String label) => open == label ? null : label;

/// One zoom step from [zoom], kept within the map's limits.
double zoomStep(double zoom, {required bool zoomIn}) =>
    (zoomIn ? zoom + 1 : zoom - 1).clamp(mapMinZoom, mapMaxZoom).toDouble();

/// A coordinate with at most five decimals, in the [localeName] format (`37.43149`,
/// `37,43149`).
String formatCoordinate(double value, String localeName) =>
    (NumberFormat.decimalPattern(localeName)..maximumFractionDigits = 5).format(value);
