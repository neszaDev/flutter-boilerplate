import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = appLogger('showcase.draggable');

/// Where the draggable demo keeps its saved layout (the web app's `layoutStorage`).
abstract interface class LayoutStore {
  /// The saved layout's JSON, or null when nothing is saved or storage is unavailable.
  Future<String?> read();

  /// Saves the layout's JSON. False when storage refused it.
  Future<bool> write(String json);
}

/// [LayoutStore] in the phone's preferences. Only this demo's layout goes there.
class PreferencesLayoutStore implements LayoutStore {
  PreferencesLayoutStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const key = 'showcase.draggable.layout';

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read() async {
    try {
      return await _preferences.getString(key);
    } on PlatformException catch (error) {
      // Behave as if nothing was saved.
      _log.warning('Could not read the saved layout', error);
      return null;
    }
  }

  @override
  Future<bool> write(String json) async {
    try {
      await _preferences.setString(key, json);
      return true;
    } on PlatformException catch (error) {
      _log.warning('Could not save the layout', error);
      return false;
    }
  }
}

/// The store the draggable demo uses; overridden in tests.
final layoutStoreProvider = Provider<LayoutStore>((ref) => PreferencesLayoutStore());
