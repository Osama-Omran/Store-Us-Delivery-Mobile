import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart'
    show StringExtension;
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_notifications.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_store.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;
import 'package:workmanager/workmanager.dart';

const _workName = 'com.storeus.delivery.offline.sync';
const _periodicWorkName = 'storeus_offline_sync_periodic';
const _workTask = 'storeus_offline_sync';

@pragma('vm:entry-point')
void storeUsOfflineCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    try {
      // Background isolate: do not use navigatorKey, GetIt or UI Cubits.
      if (task != _workTask && task != Workmanager.iOSBackgroundTask) {
        return true;
      }
      return await OfflineSyncWorker.drain();
    } catch (_) {
      return false; // WorkManager is free to retry this task later.
    }
  });
}

class OfflineSyncScheduler {
  OfflineSyncScheduler._();
  static bool _ready = false;

  static Future<void> init() async {
    if (_ready) return;
    await Workmanager().initialize(storeUsOfflineCallbackDispatcher);
    _ready = true;
    // Recovery fallback on Android. Network constraint prevents useless runs.
    if (Platform.isAndroid) {
      await Workmanager().registerPeriodicTask(
        _periodicWorkName,
        _workTask,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected),
      );
    }
  }

  static Future<void> schedule() async {
    if (!_ready) return;
    await Workmanager().registerOneOffTask(
      _workName, // Static ID required for iOS BGTaskScheduler allow-list.
      _workTask,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}

class OfflineSyncWorker {
  OfflineSyncWorker._();

  static Future<bool> drain() async {
    final session = await PreferencesHelper.getOfflineSessionId();
    final prefToken = await PreferencesHelper.getToken();
    if (session == null) {
      return true;
    }
    if ((prefToken == null || prefToken.trim().isEmpty) &&
        token.isNullOrEmpty()) {
      return true;
    }
    final authToken = prefToken != null && prefToken.trim().isNotEmpty
        ? prefToken
        : token;

    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('storeus_offline_api_base_url');
    if (baseUrl == null || !baseUrl.startsWith('https://')) {
      return false;
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 35),
        headers: {'Accept': 'application/json'},
      ),
    );
    final store = OfflineSyncStore.instance;
    final notifier = OfflineSyncNotifications.instance;
    bool allDone = true;

    // Keep jobs bounded so iOS can expire a background execution window.
    for (var i = 0; i < 8; i++) {
      final row = await store.claimNext(session);
      if (row == null) break;
      final id = row['id'] as String;
      final title = row['title'] as String;
      final attempts = row['attempts'] as int;
      try {
        try {
          await notifier.sending(title);
        } catch (_) {
          /* Notifications are best effort. */
        }
        final response = await dio.request<dynamic>(
          row['endpoint'] as String,
          data: row['body_json'] == null
              ? null
              : jsonDecode(row['body_json'] as String),
          queryParameters: Map<String, dynamic>.from(
            jsonDecode(row['query_json'] as String) as Map,
          ),
          options: Options(
            method: row['method'] as String,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Idempotency-Key': id,
              if ((row['language'] as String?) != null)
                'Accept-Language': row['language'],
            },
            contentType: Headers.jsonContentType,
          ),
        );
        if (response.data is Map &&
            (response.data as Map)['success'] == false) {
          throw StateError('Backend returned success=false');
        }
        await store.completed(id, needsToast: true);
        try {
          await notifier.finished(title);
        } catch (_) {
          /* Keep successful sync. */
        }
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        if (_retryable(e)) {
          await store.retryLater(id, attempts, '${e.type}: ${e.message}');
          // A future job will retry when backoff/network allow.
          allDone = false;
          if (attempts >= 12) {
            try {
              await notifier.error(title);
            } catch (_) {}
          } else {
            try {
              await notifier.waiting();
            } catch (_) {}
          }
        } else if (code == 401 || code == 403) {
          await store.failed(id, 'Authorization required ($code)');
          try {
            await notifier.error(title);
          } catch (_) {}
        } else {
          await store.failed(id, 'HTTP ${code ?? 'unknown'}');
          try {
            await notifier.error(title);
          } catch (_) {}
        }
      } catch (e) {
        await store.failed(id, e.toString());
        try {
          await notifier.error(title);
        } catch (_) {}
      }
    }
    // Do not show a stuck progress notification when all candidates complete.
    dio.close();
    return allDone;
  }

  static bool _retryable(DioException error) {
    final code = error.response?.statusCode;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        code == 429 ||
        (code != null && code >= 500);
  }
}
