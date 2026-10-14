import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeus_delivery/core/helpers/apis/api_constants.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_notifications.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_store.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_worker.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';

/// Maintains in-app retry and catches results produced by background isolates.
/// Call once during startup (after WidgetsFlutterBinding initialization).
class OfflineSyncService with WidgetsBindingObserver {
  OfflineSyncService._();
  static final OfflineSyncService instance = OfflineSyncService._();
  Timer? _timer;
  bool _inProgress = false;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    await OfflineSyncStore.instance.db;
    await OfflineSyncStore.instance.pruneOldCompleted();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('storeus_offline_api_base_url', ApiConstants.baseUrl);
    await OfflineSyncScheduler.init();
    await OfflineSyncNotifications.instance.init(askPermission: true);
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(
      const Duration(seconds: 25),
      (_) => unawaited(check()),
    );
    await check();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(check());
    }
  }

  Future<void> check() async {
    if (_inProgress) return;
    _inProgress = true;
    try {
      final session = await PreferencesHelper.getOfflineSessionId();
      if (session == null) return;
      // UI foreground: timely attempts instead of waiting for WorkManager.
      if (await OfflineSyncStore.instance.pendingCount(session) > 0) {
        await OfflineSyncWorker.drain();
      }
      final results = await OfflineSyncStore.instance.unsurfacedCompletions(
        session,
      );
      if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }
      for (final row in results) {
        final title = row['title'] as String;
        await OfflineSyncNotifications.instance.foregroundToast(title);
        await OfflineSyncStore.instance.clearToastFlag(row['id'] as String);
      }
    } catch (_) {
      // A failure here must not crash the app; the periodic worker remains.
    } finally {
      _inProgress = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
    _started = false;
  }
}
