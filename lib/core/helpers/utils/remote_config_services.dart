import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:storeus_delivery/core/helpers/apis/environment_config.dart';
import 'package:storeus_delivery/core/helpers/utils/app_update_config.dart';
import 'package:storeus_delivery/core/helpers/utils/firebase_options.dart';
import 'package:version/version.dart';

class RemoteConfigServices {
  static const String _baseUrlParameter = 'base_url';

  static FirebaseRemoteConfig? _remoteConfig;
  static Future<void>? _initialization;
  static AppUpdateParameterKeys? _parameterKeys;
  static String? _currentVersion;

  static String? _occasion;
  static String? _storeVersion;
  static String? _minimumVersion;
  static String? _storeURL;
  static String? _iosGuestModeVersion;
  static bool? _iosGuestModeEnabled;

  static String? get occasion => _occasion;
  static String? get storeVersion => _storeVersion;
  static String? get minimumVersion => _minimumVersion;
  static String? get storeURL => _storeURL;
  static String get apiBaseUrl => EnvironmentConfig.baseUrl;
  static String? get iosGuestModeVersion => _iosGuestModeVersion;
  static bool? get iosGuestModeEnabled => _iosGuestModeEnabled;

  static Future<void> init({required String currentVersion}) {
    return _initialization ??= _initialize(currentVersion);
  }

  static Future<void> _initialize(String currentVersion) async {
    EnvironmentConfig.setRemoteConfigBaseUrl(null);
    _currentVersion = currentVersion;
    _minimumVersion = currentVersion;
    _storeVersion = currentVersion;
    _storeURL = '';

    final platform = defaultTargetPlatform;
    final keys = AppUpdateParameterKeys.forPlatform(platform);
    if (keys == null) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 4));
      }

      final remoteConfig = FirebaseRemoteConfig.instance;
      _remoteConfig = remoteConfig;
      _parameterKeys = keys;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 3),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 12),
        ),
      );
      await remoteConfig.setDefaults({
        _baseUrlParameter: EnvironmentConfig.environment.baseUrl,
        keys.minimumVersion: currentVersion,
        keys.latestVersion: currentVersion,
        keys.storeUrl: '',
      });

      try {
        await remoteConfig.fetchAndActivate().timeout(
          const Duration(seconds: 4),
        );
      } catch (_) {
        // Activated values remain readable when a fetch is unavailable.
      }

      _readApiBaseUrl(remoteConfig);
      _readUpdateValues(remoteConfig, keys, currentVersion);

      if (platform == TargetPlatform.iOS) {
        _iosGuestModeVersion = remoteConfig
            .getString('iOS_guest_mode_version')
            .trim();
        _iosGuestModeEnabled = remoteConfig.getBool('iOS_guest_mode_enabled');
      }
    } catch (_) {
      // Remote Config must never prevent the app from starting.
      _initialization = null;
    }
  }

  static Future<void> refresh() async {
    final remoteConfig = _remoteConfig;
    final keys = _parameterKeys;
    final currentVersion = _currentVersion;
    if (remoteConfig == null || keys == null || currentVersion == null) return;

    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: Duration(seconds: 3),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await remoteConfig.fetchAndActivate().timeout(const Duration(seconds: 4));
      _readApiBaseUrl(remoteConfig);
      _readUpdateValues(remoteConfig, keys, currentVersion);
    } catch (_) {
      // Keep the last activated values and let the caller retry.
    } finally {
      try {
        await remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 3),
            minimumFetchInterval: kDebugMode
                ? Duration.zero
                : const Duration(hours: 12),
          ),
        );
      } catch (_) {
        // Configuration refresh failure must not affect app usage.
      }
    }
  }

  static void _readApiBaseUrl(FirebaseRemoteConfig remoteConfig) {
    final configuredBaseUrl = remoteConfig.getString(_baseUrlParameter).trim();
    EnvironmentConfig.setRemoteConfigBaseUrl(configuredBaseUrl);
  }

  static void _readUpdateValues(
    FirebaseRemoteConfig remoteConfig,
    AppUpdateParameterKeys keys,
    String currentVersion,
  ) {
    final minimumVersion = remoteConfig.getString(keys.minimumVersion).trim();
    final latestVersion = remoteConfig.getString(keys.latestVersion).trim();
    _minimumVersion = _validVersion(minimumVersion)
        ? minimumVersion
        : currentVersion;
    _storeVersion = _validVersion(latestVersion)
        ? latestVersion
        : currentVersion;
    _storeURL = remoteConfig.getString(keys.storeUrl).trim();
  }

  static bool _validVersion(String value) {
    try {
      Version.parse(value.trim());
      return value.trim().isNotEmpty;
    } on FormatException {
      return false;
    }
  }

  static Future<bool> shouldUseGuestMode() async {
    if (defaultTargetPlatform != TargetPlatform.iOS ||
        _iosGuestModeEnabled != true ||
        !_validVersion(_iosGuestModeVersion ?? '')) {
      return false;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return Version.parse(packageInfo.version) ==
          Version.parse(_iosGuestModeVersion!);
    } on FormatException {
      return false;
    }
  }
}
