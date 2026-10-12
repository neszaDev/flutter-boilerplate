# Releasing

## Before the first release

- [ ] Application id / bundle id changed from `com.example…` ([configuration](configuration.md#app-identity)).
- [ ] App name, icons, splash screen replaced.
- [ ] `env/prod.json` points at the production backend (https, public ingress).
- [ ] Permission texts in `Info.plist` describe your product (and are translated).
- [ ] Features you don't use removed with their permissions ([phone features](device-features.md)).
- [ ] Privacy: store listings need a privacy policy URL and data-safety / privacy-label answers.
      This template collects account email, test results and files on your backend; the device
      features keep camera, location and biometric data on the phone.
- [ ] A crash-reporting service chosen and plugged into `ErrorReporter` (or the decision not to).

## Android

**Signing key** (once, keep it forever — losing it means a new app listing; enrol in Play App
Signing so Google holds the app signing key and yours is only the upload key):

```sh
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Locally, create `android/key.properties` (git-ignored):

```properties
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

In CI, add the secrets `ANDROID_KEYSTORE_BASE64` (`base64 -i upload-keystore.jks`),
`ANDROID_STORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` to the `main` environment;
`build-release.yml` writes `key.properties` from them.

**Build:** `make build-appbundle ENV=prod` → `build/app/outputs/bundle/release/app-release.aab`.
Upload it to Play Console (internal testing → closed → production). Without a key the build is
debug-signed: fine for testers, refused by Play.

## iOS

Needs an Apple Developer account.

1. Xcode → `ios/Runner.xcworkspace` → Runner → Signing & Capabilities: your team, your bundle id,
   automatic signing.
2. `make build-ipa ENV=prod` → `build/ios/ipa/*.ipa`.
3. Upload with Transporter or `xcrun altool`, then TestFlight → App Store.

For CI uploads, add an App Store Connect API key and signing certificate as secrets and extend
`build-release.yml` (fastlane `match` or Xcode's cloud signing); the unsigned build there already
proves the project compiles.

## Obfuscation and crash stack traces

Release builds use `--obfuscate --split-debug-info=build/symbols/<env>`. Stack traces from those
builds are unreadable without the matching symbols, kept as the `symbols-*` CI artifacts (90 days;
copy them somewhere permanent for store releases). To read one:

```sh
flutter symbolize -i stacktrace.txt -d build/symbols/prod/app.android-arm64.symbols
```

Upload them to your crash-reporting service if you add one.

## Versioning

`version: <semver>+<build>` in `pubspec.yaml`. The build number (Android `versionCode`, iOS
`CFBundleVersion`) must increase with every store upload; the semver is what users see. Tag the
commit `v<semver>`.

## Forcing an update

The backend can't push an app update. If an API change would break old app versions, keep the
old behaviour on the backend until users have updated, or add a "minimum version" check: an
endpoint returning the oldest supported version, compared with `AppInfo.version` at startup.
