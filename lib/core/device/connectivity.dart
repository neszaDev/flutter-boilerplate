import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The network interfaces that are up. A Wi-Fi connection without internet still counts as
/// "online" here; requests then fail with `ApiFailure.network` and say so.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});

/// False only when the phone reports no network at all. Unknown counts as online.
final isOnlineProvider = Provider<bool>((ref) {
  final results = ref.watch(connectivityProvider).value;
  return results == null || results.any((result) => result != ConnectivityResult.none);
});
