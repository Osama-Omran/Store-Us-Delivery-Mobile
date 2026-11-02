import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:storeus_delivery/core/helpers/utils/app_update_config.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/helpers/utils/remote_config_services.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateServices {
  static bool mandatoryUpdateRequired = false;
  static bool startupCheckComplete = false;

  Future<AppUpdateResult> checkForUpdate({
    bool refreshRemoteConfig = false,
  }) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final installedVersion = packageInfo.version;
      await RemoteConfigServices.init(currentVersion: installedVersion);
      if (refreshRemoteConfig) await RemoteConfigServices.refresh();

      final minimumVersion =
          RemoteConfigServices.minimumVersion ?? installedVersion;
      final latestVersion =
          RemoteConfigServices.storeVersion ?? installedVersion;
      final storeUrl = RemoteConfigServices.storeURL ?? '';
      final status = decideAppUpdate(
        installedVersion: installedVersion,
        minimumVersion: minimumVersion,
        latestVersion: latestVersion,
      );
      mandatoryUpdateRequired = status == AppUpdateStatus.required;

      return AppUpdateResult(
        status: status,
        installedVersion: installedVersion,
        latestVersion: latestVersion,
        storeUrl: storeUrl,
      );
    } catch (_) {
      return const AppUpdateResult(
        status: AppUpdateStatus.none,
        installedVersion: '',
        latestVersion: '',
        storeUrl: '',
      );
    }
  }

  Future<bool> isOptionalUpdateDismissed(String version) async =>
      PreferencesHelper.isOptionalUpdateDismissed(version);

  Future<void> dismissOptionalUpdate(String version) =>
      PreferencesHelper.dismissOptionalUpdate(version);

  Future<bool> openStore(String url) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    if (!isValidStoreUrl(url)) return false;
    final uri = Uri.parse(url.trim());

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
