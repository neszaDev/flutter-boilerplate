# Phone features

Each feature has a service in `lib/core/device/` (what the rest of the app uses) and a demo
screen under **Phone** (`lib/features/device/`, `Permission.useDeviceFeatures`). Every one of
them asks for its permission only when the user first needs it, explains a refusal, and offers
the system settings when the refusal is permanent.

| Feature | Package | Used by the app | Demo |
|---|---|---|---|
| Fingerprint / Face ID / face unlock | `local_auth` | **App lock** (Settings) | `/dashboard/device/biometrics` |
| Shake | `sensors_plus` + `ShakeDetector` | **Quick menu** on shake (Settings) | `/dashboard/device/shake` |
| Motion sensors, compass | `sensors_plus` | — | `/dashboard/device/motion` |
| Camera and photo library | `image_picker` | **Files** upload (photo, gallery) | `/dashboard/device/camera` |
| Document picker | `file_picker` | **Files** upload | — |
| QR / barcode scanning | `mobile_scanner` | — | `/dashboard/device/scanner` |
| QR generation | `qr_flutter` | Campus QR code | `/dashboard/device/scanner` |
| Location | `geolocator` | — | `/dashboard/device/location` |
| Haptics | Flutter `HapticFeedback` via `Haptics` | toasts, sign-in errors, unlock | `/dashboard/device/haptics` |
| Local notifications | `flutter_local_notifications` | — | `/dashboard/device/notifications` |
| Battery, device, connectivity | `battery_plus`, `device_info_plus`, `connectivity_plus` | **Offline banner**, debug info | `/dashboard/device/info` |
| Share sheet, links, clipboard | `share_plus`, `url_launcher` | Files open/share | `/dashboard/device/share` |
| Secure storage | `flutter_secure_storage` | **Session tokens** | — |

## App lock (fingerprint / face)

`lib/features/lock/app_lock.dart`. Off by default; turning it on in Settings first asks for a
successful authentication, so nobody locks themselves out.

- Locks a session restored at launch, and after more than `AppConfig.appLockGrace` (30 s) in the
  background. A session started with the password in this run isn't locked again.
- Unlock accepts biometrics **or the device passcode** (`biometricOnly: false`): a hurt finger or
  a mask must not lock someone out of their data. Use `biometricOnly: true` only for a step that
  must be biometric.
- "Sign out instead" is always offered.
- While the lock is on, the app switcher shows the cover, not the last screen.
- Biometric data never reaches the app: the OS answers yes or no.

"Face scan" is Face ID on iPhone. On Android, `local_auth` offers face unlock only where the
phone classes it as a strong biometric (e.g. Pixel 8+); elsewhere the prompt offers fingerprint
or the passcode. Camera-based face *detection* (ML Kit) is a different thing and is not
included: it adds large native libraries and doesn't prove identity.

## Shake

`ShakeDetector` (`lib/core/device/shake_detector.dart`) is pure logic, unit-tested: a shake is two
jolts above 2.7 g within a second, then a 1.5 s cooldown. `ShakeListener` listens only while the
app is in front, unlocked, and the setting is on (sensors cost battery). The quick menu offers:
report a problem (email to `SUPPORT_EMAIL` with app/device info, no tokens), theme switch,
shortcuts, and — outside `prod` — debug info (backend, environment, version, role, token expiry).

## Native configuration

Already set up; remove the entries of features you drop.

**Android** (`android/app/src/main/AndroidManifest.xml`, `build.gradle.kts`):
- Permissions: `USE_BIOMETRIC`, `CAMERA`, `ACCESS_COARSE/FINE_LOCATION`, `POST_NOTIFICATIONS`,
  `RECEIVE_BOOT_COMPLETED` (scheduled notifications survive a reboot), `VIBRATE`,
  `ACCESS_NETWORK_STATE`, `INTERNET`.
- Camera, GPS and accelerometer are `required="false"`: the app installs without them.
- `MainActivity` extends `FlutterFragmentActivity` (`local_auth` needs it).
- Core library desugaring on (`flutter_local_notifications`); `minSdk` 24.
- `<queries>` for https, mailto, tel and sms (Android 11+ package visibility).
- `allowBackup="false"`: tokens are tied to this install's Keystore keys.

**iOS** (`ios/Runner/Info.plist`):
- `NSFaceIDUsageDescription`, `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`,
  `NSLocationWhenInUseUsageDescription`, `NSMotionUsageDescription`. A missing one crashes the
  app the first time the feature is used.
- `LSApplicationQueriesSchemes` for `canLaunchUrl`; `NSAllowsLocalNetworking` for http to a
  development backend.
- Plugins are linked with Swift Package Manager (Flutter's default); CocoaPods isn't needed.

### iOS permission texts

The `NS*UsageDescription` texts are in English. To translate them, add `InfoPlist.strings` files
in Xcode (File → New → Strings File named `InfoPlist`, then Localize… for each language) with
lines like `"NSCameraUsageDescription" = "Marksheet utilise l'appareil photo…";`.

## Push notifications

Not included: they need a server-side sender and an account with Firebase Cloud Messaging and/or
APNs (a third-party service; record the decision in `docs/plans/`). `LocalNotifications` is the
place to show them once received; the backend would need an endpoint to register device tokens.

## Testing device code

Plugins don't exist in unit tests. Keep logic pure and test it directly (`ShakeDetector`,
`headingFromMagnetometer`, `linkIn`), and put plugin calls behind a small service with a
provider (`BiometricService`, `biometricServiceProvider`) so widget tests can override it.
Everything else is checked on a device or simulator: simulators fake biometrics
(Features → Face ID / Touch ID → Enrolled, then Matching Face/Touch), location (Features →
Location) and shakes (Device → Shake on iOS; the emulator's extended controls → Virtual sensors on
Android).
