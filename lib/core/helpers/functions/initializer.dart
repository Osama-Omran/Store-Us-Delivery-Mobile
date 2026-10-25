import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/deferred_startup.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_notifications.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_service.dart';
import 'package:storeus_delivery/core/helpers/offline_cache/offline_cache_connectivity.dart';
import 'package:storeus_delivery/core/helpers/utils/bloc_observer.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/remote_config_services.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';

class Initializer {
  static Future<void> initializeServices() async {
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final watch = Stopwatch()..start();

    await PreferencesHelper.init();

    if (kDebugMode) {
      debugPrint(
        '[STARTUP] Preferences: '
        '${watch.elapsedMilliseconds}ms',
      );
    }

    token = await PreferencesHelper.getToken();

    if (kDebugMode) {
      debugPrint(
        '[STARTUP] Token: '
        '${watch.elapsedMilliseconds}ms',
      );
    }

    setupLocator();

    await getIt.allReady();

    if (kDebugMode) {
      debugPrint(
        '[STARTUP] GetIt ready: '
        '${watch.elapsedMilliseconds}ms',
      );
    }

    if (kDebugMode) {
      Bloc.observer = MyBlocObserver();
    }
  }

  static Future<void> initializeDeferredServices() => runDeferredStartup(
    firstFrame: WidgetsBinding.instance.waitUntilFirstFrameRasterized,
    tasks: [
      () async {
        await OfflineCacheConnectivity.instance.start();

        await OfflineSyncService.instance.start();

        await OfflineSyncService.instance.check();
      },

      RemoteConfigServices.init,

      () => OfflineSyncNotifications.instance.init(askPermission: true),
    ],
    onError: (error, stackTrace) {
      CustomLogger.logger?.e(
        'Error When Initializing Deferred Services: $error',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
