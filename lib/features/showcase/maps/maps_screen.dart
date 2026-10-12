import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/config/env.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/maps/maps_data.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// `/dashboard/google-maps`: the Vue map demo on OpenStreetMap tiles (flutter_map, no API
/// key). Four places as markers with an info card, zoom and recentre buttons, the coordinates
/// of a tap, and the places as a list (the map's accessible counterpart).
class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key, this.tileProvider});

  /// Where the tiles come from; null fetches [Env.mapTileUrl] over the network. Tests pass an
  /// offline provider.
  final TileProvider? tileProvider;

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final _map = MapController();
  String? _open;
  LatLng? _tapped;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  /// Opens or closes a place's info card; from the list, also brings the place into view.
  void _toggle(MapPlace place, {bool reveal = false}) {
    final next = toggledPlace(_open, place.label);
    setState(() => _open = next);
    if (reveal && next != null) {
      _map.move(place.position, _map.camera.zoom);
    }
  }

  void _zoom({required bool zoomIn}) =>
      _map.move(_map.camera.center, zoomStep(_map.camera.zoom, zoomIn: zoomIn));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tapped = _tapped;
    return AppPage(
      title: l10n.googleMapsPageTitle,
      description: Text(l10n.googleMapsPageDescription),
      children: [
        DemoCard(
          title: l10n.googleMapsPageCardTitle,
          description: l10n.googleMapsPageCardDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PlacesMap(
                controller: _map,
                tileProvider: widget.tileProvider,
                open: mapPlaces.where((place) => place.label == _open).firstOrNull,
                tapped: tapped,
                onTapMap: (point) => setState(() => _tapped = point),
                onToggle: _toggle,
                onZoomIn: () => _zoom(zoomIn: true),
                onZoomOut: () => _zoom(zoomIn: false),
                onRecenter: () => _map.move(mapCenter, mapInitialZoom),
              ),
              const SizedBox(height: Space.sm),
              Semantics(
                liveRegion: true,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 22),
                  child: Text(
                    key: const Key('maps.tapped'),
                    tapped == null
                        ? ''
                        : l10n.googleMapDemoClickedAt(
                            formatCoordinate(tapped.latitude, l10n.localeName),
                            formatCoordinate(tapped.longitude, l10n.localeName),
                          ),
                    style: context.text.bodyMedium?.copyWith(color: context.colors.ink700),
                  ),
                ),
              ),
              const SizedBox(height: Space.md),
              _PlaceList(open: _open, onShow: (place) => _toggle(place, reveal: true)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Opens [url] in the browser, or says it could not.
Future<void> _launch(BuildContext context, Uri url) async {
  final l10n = context.l10n;
  var opened = false;
  try {
    opened = await launchUrl(url, mode: LaunchMode.externalApplication);
  } on PlatformException {
    opened = false;
  }
  if (!opened && context.mounted) {
    showToast(context, l10n.commonErrorGeneric, tone: ToastTone.error);
  }
}

class _PlacesMap extends StatelessWidget {
  const _PlacesMap({
    required this.controller,
    required this.tileProvider,
    required this.open,
    required this.tapped,
    required this.onTapMap,
    required this.onToggle,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
  });

  final MapController controller;
  final TileProvider? tileProvider;
  final MapPlace? open;
  final LatLng? tapped;
  final ValueChanged<LatLng> onTapMap;
  final void Function(MapPlace place) onToggle;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tapped = this.tapped;
    final open = this.open;

    return Container(
      height: 380,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: colors.ink300),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Stack(
        children: [
          Semantics(
            label: l10n.googleMapDemoMapLabel,
            child: FlutterMap(
              mapController: controller,
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: mapInitialZoom,
                minZoom: mapMinZoom,
                maxZoom: mapMaxZoom,
                backgroundColor: colors.ink100,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onTap: (_, point) => onTapMap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: Env.mapTileUrl,
                  userAgentPackageName: 'com.example.flutter_boilerplate',
                  tileProvider: tileProvider,
                  // The light tiles, inverted at night so the map does not glare.
                  tileBuilder: dark ? darkModeTileBuilder : null,
                ),
                MarkerLayer(
                  markers: [
                    if (tapped != null)
                      Marker(
                        point: tapped,
                        width: 28,
                        height: 28,
                        alignment: Alignment.topCenter,
                        child: ExcludeSemantics(
                          child: Icon(LucideIcons.mapPin, color: colors.pen, size: 28),
                        ),
                      ),
                    for (final place in mapPlaces)
                      Marker(
                        key: Key('maps.marker.${place.label}'),
                        point: place.position,
                        width: 44,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: Semantics(
                          button: true,
                          selected: place == open,
                          label: place.name,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onToggle(place),
                            child: Center(
                              child: _MarkerBadge(place.label, selected: place == open),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // The tile licence asks for this line; a narrow map shrinks it rather than
                // cutting it.
                Align(
                  alignment: Alignment.bottomRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SimpleAttributionWidget(
                      source: Text(
                        l10n.googleMapDemoAttribution,
                        semanticsLabel: l10n.googleMapDemoAttributionLink,
                        style: context.text.bodySmall?.copyWith(
                          color: colors.ink900,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      backgroundColor: colors.paperCard.withValues(alpha: 0.9),
                      onTap: () => _launch(context, osmCopyright),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: Space.sm,
            right: Space.sm,
            child: _MapControls(onZoomIn: onZoomIn, onZoomOut: onZoomOut, onRecenter: onRecenter),
          ),
          if (open != null)
            Positioned(
              left: Space.sm,
              right: Space.sm,
              // Above the attribution line.
              bottom: Space.xl,
              child: _InfoCard(place: open, onClose: () => onToggle(open)),
            ),
        ],
      ),
    );
  }
}

/// A place's one-letter label, as drawn on its marker.
class _MarkerBadge extends StatelessWidget {
  const _MarkerBadge(this.label, {this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: AnimatedScale(
        scale: selected ? 1.15 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.folder,
            shape: BoxShape.circle,
            border: Border.all(color: colors.folderInk, width: 2),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.25),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: context.text.labelLarge?.copyWith(
              color: colors.folderInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Zoom in, zoom out and back to the starting view.
class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Material(
      color: colors.ply,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        side: BorderSide(color: colors.ink300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: const Key('maps.zoomIn'),
            tooltip: l10n.googleMapDemoZoomIn,
            onPressed: onZoomIn,
            icon: const Icon(LucideIcons.plus, size: 20),
          ),
          Container(width: 28, height: 1, color: colors.ink200),
          IconButton(
            key: const Key('maps.zoomOut'),
            tooltip: l10n.googleMapDemoZoomOut,
            onPressed: onZoomOut,
            icon: const Icon(LucideIcons.minus, size: 20),
          ),
          Container(width: 28, height: 1, color: colors.ink200),
          IconButton(
            key: const Key('maps.recenter'),
            tooltip: l10n.googleMapDemoRecenter,
            onPressed: onRecenter,
            icon: const Icon(LucideIcons.locateFixed, size: 20),
          ),
        ],
      ),
    );
  }
}

/// The open place: its name and website (the web's info window).
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.place, required this.onClose});

  final MapPlace place;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        key: const Key('maps.info'),
        color: colors.ply,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: colors.ink300),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.xs, Space.sm),
          child: Row(
            children: [
              _MarkerBadge(place.label),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(place.name, style: context.text.titleMedium),
                    ),
                    Semantics(
                      link: true,
                      child: InkWell(
                        onTap: () => _launch(context, Uri.parse(place.website)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Space.xs),
                          child: Text(
                            place.website,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(
                              color: colors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('maps.closeInfo'),
                tooltip: l10n.commonClose,
                onPressed: onClose,
                icon: const Icon(LucideIcons.x, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The places as a list, each with "Show on map" and a link to its website.
class _PlaceList extends StatelessWidget {
  const _PlaceList({required this.open, required this.onShow});

  final String? open;
  final void Function(MapPlace place) onShow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    Widget row(MapPlace place) => Container(
      key: Key('maps.place.${place.label}'),
      padding: const EdgeInsets.fromLTRB(Space.md, Space.xs, Space.xs, Space.xs),
      decoration: BoxDecoration(
        color: colors.paperCard,
        border: Border.all(color: colors.ink200),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        children: [
          _MarkerBadge(place.label),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              place.name,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleSmall?.copyWith(color: colors.ink950),
            ),
          ),
          Semantics(
            selected: open == place.label,
            child: TextButton(
              key: Key('maps.show.${place.label}'),
              style: TextButton.styleFrom(
                backgroundColor: open == place.label ? colors.ink100 : null,
              ),
              onPressed: () => onShow(place),
              child: Text(l10n.googleMapDemoShowOnMap),
            ),
          ),
          IconButton(
            tooltip: l10n.googleMapDemoWebsiteOf(place.name),
            onPressed: () => _launch(context, Uri.parse(place.website)),
            icon: const Icon(LucideIcons.externalLink, size: 18),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 2 : 1;
        final width = (constraints.maxWidth - Space.sm * (columns - 1)) / columns;
        return Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final place in mapPlaces) SizedBox(width: width, child: row(place)),
          ],
        );
      },
    );
  }
}
