import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeus_delivery/core/helpers/offline_cache/offline_cache_store.dart';
import 'package:storeus_delivery/core/helpers/offline_cache/offline_cache_connectivity.dart';

class PreferencesHelper {
  static SharedPreferences? preferences;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'Access Token';
  static const _sessionKey = 'StoreUs Offline Session ID';

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  static String _randomId() {
    final random = Random.secure();
    return List.generate(24, (_) => random.nextInt(256)
            .toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// A new login is a distinct sync session, preventing replay under a
  /// different user. Never store access tokens inside SQLite.
  static Future<void> saveToken(String token) async {
    final old = await _secureStorage.read(key: _tokenKey);
    if (old != token) {
      OfflineCacheStatus.instance.clear();
      final previousSession = await _secureStorage.read(key: _sessionKey);
      if (previousSession != null) {
        try {
          await OfflineCacheStore.instance.clearSession(previousSession);
        } catch (_) {
          // Never block login due to cache cleanup failures.
        }
      }
      await _secureStorage.write(key: _sessionKey, value: _randomId());
    }
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() =>
      _secureStorage.read(key: _tokenKey);

  static Future<String?> getOfflineSessionId() async {
    if (await getToken() == null) return null;
    final current = await _secureStorage.read(key: _sessionKey);
    if (current != null && current.isNotEmpty) return current;
    final generated = _randomId();
    await _secureStorage.write(key: _sessionKey, value: generated);
    return generated;
  }

  static Future<void> removeToken() async {
    OfflineCacheStatus.instance.clear();
    final session = await _secureStorage.read(key: _sessionKey);
    if (session != null) {
      try {
        await OfflineCacheStore.instance.clearSession(session);
      } catch (_) {
        // Never leave the user logged in because local cache cleanup failed.
      }
    }
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _sessionKey);
    // Unsent rows become quarantined: never replay them for a new login.
    // The account/logout screen should warn if unsent operations exist.
  }

  static void saveUserName(String name) =>
      preferences?.setString('User Name', name);

  static String? getUserName() => preferences?.getString('User Name');
}
