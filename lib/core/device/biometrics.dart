import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final _log = appLogger('device.biometrics');

/// The way this phone checks who is holding it, in the words the user knows.
enum UnlockMethod { faceId, touchId, face, fingerprint, iris, biometrics, passcode, none }

/// What the device offers, read from the OS (`local_auth`).
@immutable
class BiometricStatus {
  const BiometricStatus({
    required this.deviceSupported,
    required this.canCheckBiometrics,
    required this.enrolled,
  });

  static const unavailable = BiometricStatus(
    deviceSupported: false,
    canCheckBiometrics: false,
    enrolled: [],
  );

  /// The device has a lock of some kind (biometrics, or a passcode/PIN/pattern).
  final bool deviceSupported;

  /// It has biometric hardware.
  final bool canCheckBiometrics;

  /// The biometrics enrolled and available to this app.
  final List<BiometricType> enrolled;

  /// What the lock prompt will ask for.
  UnlockMethod get method {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    if (enrolled.contains(BiometricType.face)) {
      return ios ? UnlockMethod.faceId : UnlockMethod.face;
    }
    if (enrolled.contains(BiometricType.fingerprint)) {
      return ios ? UnlockMethod.touchId : UnlockMethod.fingerprint;
    }
    if (enrolled.contains(BiometricType.iris)) {
      return UnlockMethod.iris;
    }
    if (enrolled.isNotEmpty) {
      return UnlockMethod.biometrics;
    }
    return deviceSupported ? UnlockMethod.passcode : UnlockMethod.none;
  }
}

/// How an authentication attempt ended.
enum AuthOutcome { success, failed, canceled, notAvailable, lockedOut, error }

/// Fingerprint, face and device-passcode checks. Wraps `local_auth` so screens get a plain
/// outcome and tests can fake it.
class BiometricService {
  BiometricService([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<BiometricStatus> status() async {
    try {
      return BiometricStatus(
        deviceSupported: await _auth.isDeviceSupported(),
        canCheckBiometrics: await _auth.canCheckBiometrics,
        enrolled: await _auth.getAvailableBiometrics(),
      );
    } on MissingPluginException {
      // Tests, or a platform without the plugin.
      return BiometricStatus.unavailable;
    } on PlatformException catch (error) {
      _log.warning('Biometric status failed', error);
      return BiometricStatus.unavailable;
    }
  }

  /// Shows the system prompt with [reason]. [biometricOnly] refuses the passcode fallback
  /// (use it only where a passcode isn't good enough).
  Future<AuthOutcome> authenticate({required String reason, bool biometricOnly = false}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
      return ok ? AuthOutcome.success : AuthOutcome.failed;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.timeout ||
        LocalAuthExceptionCode.userRequestedFallback => AuthOutcome.canceled,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout => AuthOutcome.lockedOut,
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable => AuthOutcome.notAvailable,
        _ => AuthOutcome.error,
      };
    } on MissingPluginException {
      return AuthOutcome.notAvailable;
    } on PlatformException catch (error) {
      _log.warning('Biometric authentication failed', error);
      return AuthOutcome.error;
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());

final biometricStatusProvider = FutureProvider<BiometricStatus>(
  (ref) => ref.watch(biometricServiceProvider).status(),
);

/// "Face ID", "fingerprint", "device passcode"…
String unlockMethodName(AppLocalizations l10n, UnlockMethod method) => switch (method) {
  UnlockMethod.faceId => l10n.biometricsFaceId,
  UnlockMethod.touchId => l10n.biometricsTouchId,
  UnlockMethod.face => l10n.biometricsFace,
  UnlockMethod.fingerprint => l10n.biometricsFingerprint,
  UnlockMethod.iris => l10n.biometricsIris,
  UnlockMethod.biometrics => l10n.biometricsGeneric,
  UnlockMethod.passcode || UnlockMethod.none => l10n.biometricsPasscode,
};
