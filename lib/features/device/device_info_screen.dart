import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/config/app_info.dart';
import 'package:flutter_boilerplate/core/config/env.dart';
import 'package:flutter_boilerplate/core/device/connectivity.dart';
import 'package:flutter_boilerplate/core/device/device_info.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/device/device_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Battery level, state and saver mode; refreshed when the charging state changes.
final batteryProvider = StreamProvider.autoDispose<({int? level, BatteryState state, bool? saver})>(
  (ref) async* {
    final battery = Battery();
    Future<({int? level, BatteryState state, bool? saver})> read(BatteryState state) async {
      int? level;
      bool? saver;
      try {
        level = await battery.batteryLevel;
        saver = await battery.isInBatterySaveMode;
      } on Object {
        // Simulators and some devices don't report these.
      }
      return (level: level, state: state, saver: saver);
    }

    try {
      yield await read(await battery.batteryState);
    } on Object {
      yield await read(BatteryState.unknown);
    }
    await for (final state in battery.onBatteryStateChanged) {
      yield await read(state);
    }
  },
);

/// `/dashboard/device/info`: device, app, battery, network and screen.
class DeviceInfoScreen extends ConsumerWidget {
  const DeviceInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final info = ref.watch(appInfoProvider);
    final device = ref.watch(deviceSummaryProvider).value;
    final battery = ref.watch(batteryProvider).value;
    final network = ref.watch(connectivityProvider).value ?? const [];
    final media = MediaQuery.of(context);
    final decimal = NumberFormat.decimalPatternDigits(locale: context.localeName, decimalDigits: 1);

    String batteryState(BatteryState state) => switch (state) {
      BatteryState.charging => l10n.deviceInfoPageStateCharging,
      BatteryState.discharging => l10n.deviceInfoPageStateDischarging,
      BatteryState.full => l10n.deviceInfoPageStateFull,
      BatteryState.connectedNotCharging => l10n.deviceInfoPageStateConnected,
      BatteryState.unknown => l10n.deviceInfoPageStateUnknown,
    };
    String connection(ConnectivityResult result) => switch (result) {
      ConnectivityResult.wifi => l10n.deviceInfoPageWifi,
      ConnectivityResult.mobile => l10n.deviceInfoPageMobile,
      ConnectivityResult.ethernet => l10n.deviceInfoPageEthernet,
      ConnectivityResult.vpn => l10n.deviceInfoPageVpn,
      ConnectivityResult.bluetooth => l10n.deviceInfoPageBluetooth,
      ConnectivityResult.none => l10n.deviceInfoPageNone,
      ConnectivityResult.other || ConnectivityResult.satellite => l10n.deviceInfoPageOther,
    };

    return AppPage(
      title: l10n.deviceInfoPageTitle,
      description: Text(l10n.deviceInfoPageDescription),
      onRefresh: () async {
        ref
          ..invalidate(batteryProvider)
          ..invalidate(deviceSummaryProvider);
      },
      children: [
        DemoCard(
          title: l10n.deviceInfoPageSectionDevice,
          child: Column(
            children: [
              ValueRow(label: l10n.deviceInfoPageModel, value: device ?? '…'),
              ValueRow(
                label: l10n.deviceInfoPageKind,
                value: device == null
                    ? '…'
                    : device.contains('emulator') || device.contains('simulator')
                    ? l10n.deviceInfoPageEmulator
                    : l10n.deviceInfoPagePhysical,
              ),
              ValueRow(
                label: l10n.deviceInfoPageLanguage,
                value: Localizations.localeOf(context).toLanguageTag(),
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.deviceInfoPageSectionApp,
          child: Column(
            children: [
              ValueRow(
                label: l10n.deviceInfoPageVersion,
                value: '${info.version} (${info.buildNumber})',
              ),
              ValueRow(label: l10n.deviceInfoPageEnvironment, value: Env.name),
              ValueRow(label: l10n.deviceInfoPageBackend, value: Env.backendUrl),
            ],
          ),
        ),
        DemoCard(
          title: l10n.deviceInfoPageSectionBattery,
          child: Column(
            children: [
              ValueRow(
                label: l10n.deviceInfoPageLevel,
                value: battery?.level == null
                    ? '—'
                    : l10n.deviceInfoPageLevelValue('${battery!.level}'),
              ),
              ValueRow(
                label: l10n.deviceInfoPageState,
                value: battery == null ? '…' : batteryState(battery.state),
              ),
              ValueRow(
                label: l10n.deviceInfoPageSaver,
                value: switch (battery?.saver) {
                  true => l10n.commonOn,
                  false => l10n.commonOff,
                  null => '—',
                },
              ),
            ],
          ),
        ),
        DemoCard(
          title: l10n.deviceInfoPageSectionNetwork,
          child: ValueRow(
            label: l10n.deviceInfoPageConnection,
            value: network.isEmpty ? '…' : network.map(connection).join(', '),
          ),
        ),
        DemoCard(
          title: l10n.deviceInfoPageSectionScreen,
          child: Column(
            children: [
              ValueRow(
                label: l10n.deviceInfoPageSize,
                value: l10n.deviceInfoPageSizeValue(
                  '${media.size.width.round()}',
                  '${media.size.height.round()}',
                ),
              ),
              ValueRow(
                label: l10n.deviceInfoPagePixelRatio,
                value: decimal.format(media.devicePixelRatio),
              ),
              ValueRow(
                label: l10n.deviceInfoPageTextScale,
                value: '${decimal.format(media.textScaler.scale(100))} %',
              ),
              ValueRow(
                label: l10n.deviceInfoPageOrientation,
                value: media.orientation == Orientation.portrait
                    ? l10n.deviceInfoPagePortrait
                    : l10n.deviceInfoPageLandscape,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
