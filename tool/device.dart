// Prints the id of a running phone, simulator or emulator, starting one when none is running.
// `make run` and `make e2e` use it, so they work like VS Code's device picker:
//
//   make run                       the running device, else start one (iOS simulator first on a Mac)
//   make run DEVICE=emulator-5554  that device
//   make run EMULATOR=fb_test      start that emulator if nothing runs (`flutter emulators` lists ids)
//
// Logs go to stderr; the device id is the only line on stdout.
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final requested = Platform.environment['DEVICE'] ?? '';
  if (requested.isNotEmpty) {
    stdout.writeln(requested);
    return;
  }

  final running = await _runningMobileDevice();
  if (running != null) {
    stdout.writeln(running);
    return;
  }

  final emulator = await _pickEmulator();
  if (emulator == null) {
    stderr.writeln(
      'device: no phone connected and no emulator or simulator to start.\n'
      '  Android: create one in Android Studio (Device Manager) or `flutter emulators --create`.\n'
      '  iOS: install a simulator runtime in Xcode (Settings → Components).',
    );
    exitCode = 1;
    return;
  }

  stderr.writeln('device: starting $emulator…');
  // `flutter emulators --launch apple_ios_simulator` only opens Simulator.app, which boots
  // nothing on a Mac where no simulator was used yet; boot an iPhone explicitly instead.
  final launch = emulator == 'apple_ios_simulator'
      ? await _bootIosSimulator()
      : await Process.run('flutter', ['emulators', '--launch', emulator], runInShell: true);
  if (launch.exitCode != 0) {
    stderr.writeln('device: could not start $emulator:\n${launch.stdout}${launch.stderr}');
    exitCode = 1;
    return;
  }

  // Booting takes a while, longest for a cold Android emulator.
  final deadline = DateTime.now().add(const Duration(minutes: 4));
  while (DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(seconds: 3));
    final booted = await _runningMobileDevice();
    if (booted != null) {
      stderr.writeln('device: $booted is ready.');
      stdout.writeln(booted);
      return;
    }
  }
  stderr.writeln('device: $emulator did not come up within 4 minutes.');
  exitCode = 1;
}

/// The first connected Android or iOS target (phone, simulator or emulator).
Future<String?> _runningMobileDevice() async {
  final result = await Process.run('flutter', [
    'devices',
    '--machine',
    '--device-timeout',
    '3',
  ], runInShell: true);
  final output = result.stdout as String;
  final start = output.indexOf('[');
  if (result.exitCode != 0 || start < 0) {
    return null;
  }
  final devices = jsonDecode(output.substring(start)) as List<Object?>;
  for (final device in devices.whereType<Map<String, Object?>>()) {
    final platform = device['targetPlatform'] as String? ?? '';
    if (platform.startsWith('android') || platform.startsWith('ios')) {
      return device['id'] as String?;
    }
  }
  return null;
}

/// Boots the newest available iPhone simulator (`IOS_SIMULATOR=<name>` picks another) and shows
/// the Simulator window.
Future<ProcessResult> _bootIosSimulator() async {
  final list = await Process.run('xcrun', ['simctl', 'list', 'devices', 'available', '--json']);
  if (list.exitCode != 0) {
    return list;
  }
  final runtimes =
      (jsonDecode(list.stdout as String) as Map<String, Object?>)['devices']
          as Map<String, Object?>;
  // Runtime keys end in the version (…SimRuntime.iOS-26-3): newest last once sorted.
  final iosRuntimes = runtimes.keys.where((key) => key.contains('.iOS-')).toList()..sort();
  final wanted = Platform.environment['IOS_SIMULATOR'] ?? '';
  for (final runtime in iosRuntimes.reversed) {
    final devices = (runtimes[runtime]! as List<Object?>).whereType<Map<String, Object?>>();
    final phone = devices.where(
      (device) => wanted.isEmpty
          ? (device['name'] as String? ?? '').startsWith('iPhone')
          : device['name'] == wanted,
    );
    if (phone.isEmpty) {
      continue;
    }
    final udid = phone.first['udid']! as String;
    stderr.writeln('device: booting ${phone.first['name']} ($udid)…');
    final boot = await Process.run('xcrun', ['simctl', 'boot', udid]);
    // Already booted is fine.
    if (boot.exitCode != 0 && !(boot.stderr as String).contains('Booted')) {
      return boot;
    }
    final window = await Process.run('open', ['-a', 'Simulator']);
    if (window.exitCode != 0) {
      return window;
    }
    // Waits until the simulator has finished booting: installing earlier fails ("Shutdown").
    return Process.run('xcrun', ['simctl', 'bootstatus', udid, '-b']);
  }
  return ProcessResult(0, 1, '', 'no iPhone simulator found (Xcode → Settings → Components)');
}

/// EMULATOR when set; otherwise the iOS simulator on a Mac, else the first Android emulator.
Future<String?> _pickEmulator() async {
  final result = await Process.run('flutter', ['emulators'], runInShell: true);
  // Rows look like "fb_test • fb test • Google • android".
  final rows = LineSplitter.split(result.stdout as String)
      .map((line) => line.split('•').map((cell) => cell.trim()).toList())
      .where((cells) => cells.length >= 4 && cells.first != 'Id')
      .toList();
  final ids = [for (final cells in rows) cells.first];
  final requested = Platform.environment['EMULATOR'] ?? '';
  if (requested.isNotEmpty) {
    return ids.contains(requested) ? requested : null;
  }
  if (Platform.isMacOS && ids.contains('apple_ios_simulator')) {
    return 'apple_ios_simulator';
  }
  for (final cells in rows) {
    if (cells.last == 'android') {
      return cells.first;
    }
  }
  return null;
}
