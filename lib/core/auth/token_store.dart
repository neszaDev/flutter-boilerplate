import 'dart:convert';

import 'package:flutter_boilerplate/core/api/json.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/session_tokens.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _log = appLogger('auth.store');

/// Where the session survives an app restart: the tokens, plus the last profile seen so the app
/// opens (with the right role) before the network answers.
///
/// The mobile counterpart of the web app's httpOnly cookies: tokens live only here and in
/// memory, never in shared preferences, logs or files.
abstract interface class TokenStore {
  Future<SessionTokens?> readTokens();

  Future<void> writeTokens(SessionTokens tokens);

  Future<UserProfile?> readProfile();

  Future<void> writeProfile(UserProfile profile);

  /// Removes everything: tokens and profile.
  Future<void> clear();
}

/// [TokenStore] on the iOS Keychain / Android Keystore-backed storage.
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // Readable once the phone was unlocked after boot (background refreshes), never
            // synced to iCloud or restored onto another device.
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
          );

  static const _tokensKey = 'session.tokens';
  static const _profileKey = 'session.profile';

  final FlutterSecureStorage _storage;

  @override
  Future<SessionTokens?> readTokens() async {
    final json = await _readJson(_tokensKey);
    return json == null ? null : SessionTokens.fromJson(json);
  }

  @override
  Future<void> writeTokens(SessionTokens tokens) =>
      _storage.write(key: _tokensKey, value: jsonEncode(tokens.toJson()));

  @override
  Future<UserProfile?> readProfile() async {
    final json = await _readJson(_profileKey);
    return json == null ? null : UserProfile.fromJson(json);
  }

  @override
  Future<void> writeProfile(UserProfile profile) =>
      _storage.write(key: _profileKey, value: jsonEncode(profile.toJson()));

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokensKey);
    await _storage.delete(key: _profileKey);
  }

  Future<Json?> _readJson(String key) async {
    try {
      final raw = await _storage.read(key: key);
      return raw == null ? null : asJson(jsonDecode(raw));
    } on Object catch (error) {
      // A corrupt or undecryptable entry (restored backup, OS key reset) means "signed out",
      // not a crash on every launch.
      _log.warning('Discarding unreadable $key', error);
      await _storage.delete(key: key);
      return null;
    }
  }
}

/// In-memory [TokenStore] for tests and previews.
class MemoryTokenStore implements TokenStore {
  MemoryTokenStore({this.tokens, this.profile});

  SessionTokens? tokens;
  UserProfile? profile;

  @override
  Future<SessionTokens?> readTokens() async => tokens;

  @override
  Future<void> writeTokens(SessionTokens value) async => tokens = value;

  @override
  Future<UserProfile?> readProfile() async => profile;

  @override
  Future<void> writeProfile(UserProfile value) async => profile = value;

  @override
  Future<void> clear() async {
    tokens = null;
    profile = null;
  }
}
