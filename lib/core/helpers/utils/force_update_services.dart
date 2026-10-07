import 'package:package_info_plus/package_info_plus.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/remote_config_services.dart';
import 'package:version/version.dart';

class ForceUpdateServices {
  Future<Version> _getCurrentVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version;
    return Version.parse(version);
  }

  Version? _getRemoteVersion() {
    final String? version = RemoteConfigServices.storeVersion;

    if (!version.isNullOrEmpty()) {
      return Version.parse(version!);
    }
    return null;
  }

  Future<bool> isUpdateAvailable() async {
    final Version currentVersion = await _getCurrentVersion();
    final Version? remoteVersion = _getRemoteVersion();
    if (remoteVersion != null) {
      if (currentVersion < remoteVersion) {
        return true;
      }
    }
    return false;
  }

  Future<bool> shouldUpdate() async {
    final bool forceUpdate = RemoteConfigServices.forceUpdate ?? true;
    if ((await isUpdateAvailable()) && forceUpdate) {
      return true;
    }
    return false;
  }
}
