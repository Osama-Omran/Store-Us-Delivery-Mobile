import 'package:flutter/foundation.dart';
import 'package:version/version.dart';

enum AppUpdateStatus { none, optional, required }

class AppUpdateParameterKeys {
  const AppUpdateParameterKeys({
    required this.minimumVersion,
    required this.latestVersion,
    required this.storeUrl,
  });

  final String minimumVersion;
  final String latestVersion;
  final String storeUrl;

  static AppUpdateParameterKeys? forPlatform(TargetPlatform platform) =>
      switch (platform) {
        TargetPlatform.android => const AppUpdateParameterKeys(
          minimumVersion: 'google_play_last_allowed_version',
          latestVersion: 'google_play_last_version',
          storeUrl: 'google_play_url',
        ),
        TargetPlatform.iOS => const AppUpdateParameterKeys(
          minimumVersion: 'app_store_last_allowed_version',
          latestVersion: 'app_store_last_version',
          storeUrl: 'app_store_url',
        ),
        _ => null,
      };
}

class AppUpdateResult {
  const AppUpdateResult({
    required this.status,
    required this.installedVersion,
    required this.latestVersion,
    required this.storeUrl,
  });

  final AppUpdateStatus status;
  final String installedVersion;
  final String latestVersion;
  final String storeUrl;

  bool get needsUpdate => status != AppUpdateStatus.none;
}

AppUpdateStatus decideAppUpdate({
  required String installedVersion,
  required String minimumVersion,
  required String latestVersion,
}) {
  try {
    final installed = Version.parse(installedVersion);
    final minimum = Version.parse(minimumVersion);
    final latest = Version.parse(latestVersion);

    if (installed < minimum) return AppUpdateStatus.required;
    if (installed < latest) return AppUpdateStatus.optional;
    return AppUpdateStatus.none;
  } on FormatException {
    return AppUpdateStatus.none;
  }
}

bool isValidStoreUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.isNotEmpty;
}
