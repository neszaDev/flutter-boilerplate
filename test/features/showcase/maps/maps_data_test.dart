import 'package:flutter_boilerplate/features/showcase/maps/maps_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapPlaces', () {
    test('keeps the four places of the Vue demo, each with a website', () {
      expect(mapPlaces.map((place) => place.label), ['S', 'T', 'A', 'F']);
      expect(mapPlaces.first.website, 'https://www.stanford.edu/');
      expect(mapCenter, mapPlaces.first.position);
    });
  });

  group('toggledPlace', () {
    test('opens a place, and closes it when tapped again', () {
      expect(toggledPlace(null, 'S'), 'S');
      expect(toggledPlace('S', 'T'), 'T');
      expect(toggledPlace('T', 'T'), isNull);
    });
  });

  group('zoomStep', () {
    test('zooms one level in or out within the limits', () {
      expect(zoomStep(11, zoomIn: true), 12);
      expect(zoomStep(11, zoomIn: false), 10);
      expect(zoomStep(mapMaxZoom, zoomIn: true), mapMaxZoom);
      expect(zoomStep(mapMinZoom, zoomIn: false), mapMinZoom);
    });
  });

  group('formatCoordinate', () {
    test('keeps five decimals in the locale format', () {
      expect(formatCoordinate(37.4314891234, 'en'), '37.43149');
      expect(formatCoordinate(-122.1637, 'fr'), contains('122,1637'));
    });
  });
}
