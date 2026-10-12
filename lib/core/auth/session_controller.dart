import 'dart:async';

import 'package:flutter_boilerplate/core/api/api_client.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/profile_repository.dart';
import 'package:flutter_boilerplate/core/auth/session_tokens.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _log = appLogger('auth.session');

/// Where the app stands with the backend. The router redirects on every change.
sealed class SessionState {
  const SessionState();
}

/// Reading the stored session at startup (the splash screen).
class SessionRestoring extends SessionState {
  const SessionRestoring();
}

class SignedOut extends SessionState {
  const SignedOut({this.expired = false});

  /// The backend ended the session (refresh token revoked or expired): say so on sign-in.
  final bool expired;
}

class SignedIn extends SessionState {
  const SignedIn(this.user);

  final UserProfile user;
}

/// Tokens are stored but the backend couldn't be reached and there is no cached profile to
/// open with. The session is kept; the user retries when back online.
class RestoreFailed extends SessionState {
  const RestoreFailed(this.error);

  final ApiException error;
}

/// Sign-in, sign-up, sign-out and the startup restore. The only code that starts or ends a
/// session; screens call these methods and react to [sessionProvider].
class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    final tokens = ref.watch(tokenManagerProvider);
    final expired = tokens.onExpired.listen((_) => state = const SignedOut(expired: true));
    ref.onDispose(expired.cancel);
    unawaited(_restore());
    return const SessionRestoring();
  }

  Future<void> _restore() async {
    final tokens = ref.read(tokenManagerProvider);
    await tokens.load();
    if (!tokens.hasSession) {
      state = const SignedOut();
      return;
    }
    final cached = await ref.read(tokenStoreProvider).readProfile();
    if (cached != null) {
      // Open right away with the last known profile; refresh it (and its role) in the background.
      state = SignedIn(cached);
      unawaited(refreshProfile());
      return;
    }
    await retryRestore();
  }

  /// Loads the profile for a stored session; used by the "try again" button of [RestoreFailed].
  Future<void> retryRestore() async {
    state = const SessionRestoring();
    try {
      await _loadProfile();
    } on ApiException catch (error) {
      if (error.failure == ApiFailure.unauthorized) {
        await _endLocally(expired: true);
      } else {
        state = RestoreFailed(error);
      }
    }
  }

  /// Signs in with email and password. Throws [ApiException] (401 wrong credentials, 429 rate
  /// limited, network…) for the form to show.
  Future<void> signIn({required String email, required String password}) => _start(
    () => ref.read(authRepositoryProvider).login(email: email, password: password),
  );

  /// Creates an account and signs in. Throws [ApiException] (409 email taken, 400 invalid…).
  Future<void> signUp({required String email, required String password}) => _start(
    () => ref.read(authRepositoryProvider).register(email: email, password: password),
  );

  /// Revokes the refresh token on the backend (best effort) and forgets the session.
  Future<void> signOut() async {
    final refreshToken = ref.read(tokenManagerProvider).current?.refreshToken;
    await _endLocally();
    if (refreshToken != null) {
      await ref.read(authRepositoryProvider).logout(refreshToken);
    }
  }

  /// Re-reads `/users/me`, e.g. after the app comes back to the foreground, so a role changed
  /// by an admin shows up. Network failures keep the current profile.
  Future<void> refreshProfile() async {
    if (state is! SignedIn) {
      return;
    }
    try {
      await _loadProfile();
    } on ApiException catch (error) {
      if (error.failure != ApiFailure.unauthorized) {
        _log.info('Profile refresh failed: ${error.failure.name}');
      }
    }
  }

  Future<void> _start(Future<SessionTokens> Function() authenticate) async {
    final tokens = await authenticate();
    await ref.read(tokenManagerProvider).save(tokens);
    try {
      await _loadProfile();
    } on ApiException {
      // Signed in without a profile is no use: undo, and let the form show the error.
      await _endLocally();
      rethrow;
    }
  }

  Future<void> _loadProfile() async {
    final user = await ref.read(profileRepositoryProvider).me();
    await ref.read(tokenStoreProvider).writeProfile(user);
    state = SignedIn(user);
  }

  Future<void> _endLocally({bool expired = false}) async {
    await ref.read(tokenManagerProvider).clear();
    state = SignedOut(expired: expired);
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

/// The signed-in user, or null.
final currentUserProvider = Provider<UserProfile?>((ref) {
  final session = ref.watch(sessionProvider);
  return session is SignedIn ? session.user : null;
});
