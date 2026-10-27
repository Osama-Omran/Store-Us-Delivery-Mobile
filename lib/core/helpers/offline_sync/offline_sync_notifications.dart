import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class OfflineSyncNotifications {
  OfflineSyncNotifications._();

  static final OfflineSyncNotifications instance = OfflineSyncNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  AppLocalizations? _strings;

  /// Also used by the background isolate, where there is no widget context.
  static Future<AppLocalizations> loadStrings() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString('locale');
    final locale = AppLocalizations.supportedLocales.firstWhere(
      (locale) => locale.languageCode == saved,
      orElse: () => const Locale('ar'),
    );
    return AppLocalizations.delegate.load(locale);
  }

  String _operationTitle(String title) => title == 'offline_operation_title'
      ? _strings!.offline_operation_title
      : title;

  static const int _syncNotificationId = 90210;
  static const int _successNotificationId = 90211;
  static const int _errorNotificationId = 90212;

  Future<void> init({bool askPermission = false}) async {
    _strings = await loadStrings();
    if (!_initialized) {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );

      _initialized = true;
    }

    if (askPermission) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> waiting() async {
    await init();

    await _plugin.show(
      id: _syncNotificationId,
      title: _strings!.offline_notifications_waiting,
      body: _strings!.offline_notifications_waiting_body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'storeus_offline_sync',
          _strings!.offline_notifications_channel,
          channelDescription:
              _strings!.offline_notifications_channel_description,
          importance: Importance.low,
          priority: Priority.low,
          color: AppColors.primary,
          onlyAlertOnce: true,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true),
      ),
    );
  }

  Future<void> sending(String title) async {
    await init();

    await _plugin.show(
      id: _syncNotificationId,
      title: _strings!.offline_notifications_sending,
      body: _strings!.offline_notifications_sending_body(
        _operationTitle(title),
      ),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'storeus_offline_sync',
          _strings!.offline_notifications_channel,
          channelDescription:
              _strings!.offline_notifications_channel_description,
          importance: Importance.low,
          priority: Priority.low,
          color: AppColors.primary,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showProgress: true,
          indeterminate: true,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true),
      ),
    );
  }

  Future<void> finished(String title) async {
    await init();

    await _plugin.cancel(id: _syncNotificationId);

    await _plugin.show(
      id: _successNotificationId,
      title: _strings!.offline_notifications_finished,
      body: _strings!.offline_notifications_finished_body(
        _operationTitle(title),
      ),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'storeus_offline_sync_results',
          _strings!.offline_notifications_results_channel,
          channelDescription:
              _strings!.offline_notifications_results_description,
          importance: Importance.high,
          priority: Priority.high,
          color: AppColors.primary,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true),
      ),
    );
  }

  Future<void> error(String title) async {
    await init();

    await _plugin.cancel(id: _syncNotificationId);

    await _plugin.show(
      id: _errorNotificationId,
      title: _strings!.offline_notifications_review,
      body: _strings!.offline_notifications_error_body(_operationTitle(title)),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'storeus_offline_sync_results',
          _strings!.offline_notifications_results_channel,
          channelDescription:
              _strings!.offline_notifications_results_description,
          importance: Importance.high,
          priority: Priority.high,
          color: AppColors.syncError,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true),
      ),
    );
  }

  Future<void> foregroundToast(String title) async {
    if (kIsWeb) return;
    _strings = await loadStrings();

    await Fluttertoast.showToast(
      msg: _strings!.offline_notifications_toast(_operationTitle(title)),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primary,
      textColor: AppColors.white0,
    );
  }
}
