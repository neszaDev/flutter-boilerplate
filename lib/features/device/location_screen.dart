import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/device/device_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Why there is no position.
enum LocationProblem { serviceOff, denied, deniedForever }

/// Checks the location service and permission, asking once if needed. Null when the position
/// can be read.
Future<LocationProblem?> ensureLocationAccess() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    return LocationProblem.serviceOff;
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  return switch (permission) {
    LocationPermission.denied => LocationProblem.denied,
    LocationPermission.deniedForever => LocationProblem.deniedForever,
    _ => null,
  };
}

/// `/dashboard/device/location`: the position once, or followed while the screen is open.
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  static const _settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);

  Position? _position;
  LocationProblem? _problem;
  StreamSubscription<Position>? _follow;
  bool _busy = false;

  @override
  void dispose() {
    unawaited(_follow?.cancel());
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() => _busy = true);
    try {
      final problem = await ensureLocationAccess();
      final position = problem == null
          ? await Geolocator.getCurrentPosition(locationSettings: _settings)
          : null;
      if (mounted) {
        setState(() {
          _problem = problem;
          _position = position ?? _position;
        });
      }
    } on Exception {
      if (mounted) {
        showToast(context, context.l10n.commonNotAvailable, tone: ToastTone.error);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _toggleFollow({required bool follow}) async {
    if (!follow) {
      await _follow?.cancel();
      setState(() => _follow = null);
      return;
    }
    final problem = await ensureLocationAccess();
    if (!mounted) {
      return;
    }
    if (problem != null) {
      setState(() => _problem = problem);
      return;
    }
    setState(() {
      _problem = null;
      _follow = Geolocator.getPositionStream(locationSettings: _settings).listen(
        (position) => setState(() => _position = position),
        onError: (Object _) => setState(() => _follow = null),
      );
    });
  }

  Widget? _problemNotice(AppLocalizations l10n) => switch (_problem) {
    null => null,
    LocationProblem.serviceOff => DeviceNotice(
      message: l10n.locationPageServiceOff,
      error: true,
      action: OutlinedButton(
        onPressed: Geolocator.openLocationSettings,
        child: Text(l10n.locationPageTurnOn),
      ),
    ),
    LocationProblem.denied => DeviceNotice(message: l10n.locationPageDenied, error: true),
    LocationProblem.deniedForever => DeviceNotice(
      message: l10n.locationPageDeniedForever,
      error: true,
      action: OutlinedButton(
        onPressed: Geolocator.openAppSettings,
        child: Text(l10n.commonOpenSettings),
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final position = _position;
    final coordinate = NumberFormat.decimalPatternDigits(
      locale: context.localeName,
      decimalDigits: 6,
    );
    final whole = NumberFormat.decimalPatternDigits(locale: context.localeName, decimalDigits: 0);
    final notice = _problemNotice(l10n);

    return AppPage(
      title: l10n.locationPageTitle,
      description: Text(l10n.locationPageDescription),
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            FilledButton.icon(
              onPressed: _busy ? null : _locate,
              icon: const Icon(Icons.my_location, size: 18),
              label: Text(l10n.locationPageLocate),
            ),
          ],
        ),
        Card(
          child: SwitchListTile(
            value: _follow != null,
            onChanged: (follow) => _toggleFollow(follow: follow),
            title: Text(l10n.locationPageFollow),
            subtitle: Text(l10n.locationPageFollowHint),
          ),
        ),
        ?notice,
        DemoCard(
          title: l10n.locationPageTitle,
          child: position == null
              ? Text(l10n.locationPageEmpty, style: context.text.bodyMedium)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ValueRow(
                      label: l10n.locationPageLatitude,
                      value: coordinate.format(position.latitude),
                    ),
                    ValueRow(
                      label: l10n.locationPageLongitude,
                      value: coordinate.format(position.longitude),
                    ),
                    ValueRow(
                      label: l10n.locationPageAccuracy,
                      value: l10n.locationPageAccuracyValue(whole.format(position.accuracy)),
                    ),
                    ValueRow(
                      label: l10n.locationPageAltitude,
                      value: l10n.locationPageAltitudeValue(whole.format(position.altitude)),
                    ),
                    if (position.speed > 0)
                      ValueRow(
                        label: l10n.locationPageSpeed,
                        value: l10n.locationPageSpeedValue(whole.format(position.speed * 3.6)),
                      ),
                    const SizedBox(height: Space.xs),
                    Text(
                      l10n.locationPageUpdated(context.formatTime(position.timestamp)),
                      style: context.text.bodySmall,
                    ),
                    const SizedBox(height: Space.md),
                    OutlinedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.https('www.openstreetmap.org', '/', {
                          'mlat': '${position.latitude}',
                          'mlon': '${position.longitude}',
                        }).replace(
                          fragment: 'map=17/${position.latitude}/${position.longitude}',
                        ),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(l10n.locationPageOpenMap),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
