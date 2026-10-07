import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:version/version.dart';

class RemoteConfigServices {
  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  static String? _occasion;
  static String? _storeVersion;
  static String? _storeURL;
  static bool? _forceUpdate;
  static String? _iosGuestModeVersion;
  static bool? _iosGuestModeEnabled;

  static String? get occasion => _occasion;
  static String? get storeVersion => _storeVersion;
  static String? get storeURL => _storeURL;
  static bool? get forceUpdate => _forceUpdate;
  static String? get iosGuestModeVersion => _iosGuestModeVersion;
  static bool? get iosGuestModeEnabled => _iosGuestModeEnabled;

  static Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 1),
      ),
    );
    await _remoteConfig.fetchAndActivate();
    _storeVersion = _remoteConfig.getString(
      Platform.isAndroid ? 'android_version' : 'iOS_version',
    );
    _forceUpdate = _remoteConfig.getBool(
      Platform.isAndroid ? 'android_force_update' : 'ios_force_update',
    );
    _storeURL = _remoteConfig.getString(
      Platform.isAndroid ? 'google_play_url' : 'app_store_url',
    );
    _iosGuestModeVersion = _remoteConfig.getString('iOS_guest_mode_version');
    _iosGuestModeEnabled = _remoteConfig.getBool('iOS_guest_mode_enabled');
  }

  static bool _isVersionValid(String? version) {
    final RegExp versionRegex = RegExp(
      r"^([\d.]+)(-([0-9A-Za-z\-.]+))?(\+([0-9A-Za-z\-.]+))?$",
    );

    if (version.isNullOrEmpty()) {
      return false;
    }

    return versionRegex.hasMatch(version!);
  }

  static Future<Version> _getCurrentVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;
    return Version.parse(currentVersion);
  }

  static Future<Version?> _getRemoteVersion() async {
    if (_isVersionValid(_iosGuestModeVersion)) {
      return Version.parse(_iosGuestModeVersion!);
    }
    return null;
  }

  static Future<bool> shouldUseGuestMode() async {
    final Version currentVersion = await _getCurrentVersion();
    final Version? remoteVersion = await _getRemoteVersion();

    if (currentVersion == remoteVersion &&
        Platform.isIOS &&
        _iosGuestModeEnabled == true) {
      return true;
    }
    return false;
  }
}
