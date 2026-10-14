
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OfflineSyncNotifications {
  OfflineSyncNotifications._();

  static final OfflineSyncNotifications instance =
  OfflineSyncNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const int _syncNotificationId = 90210;
  static const int _successNotificationId = 90211;
  static const int _errorNotificationId = 90212;

  static const Color _primaryColor = Color(0xFF0462D2);

  Future<void> init({bool askPermission = false}) async {
    if (!_initialized) {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(
            '@mipmap/ic_launcher',
          ),
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
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _plugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> waiting() async {
    await init();

    await _plugin.show(
      id: _syncNotificationId,
      title: 'عمليات محفوظة',
      body: 'سيتم إرسال العمليات بمجرد توفر اتصال بالإنترنت',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'storeus_offline_sync',
          'مزامنة عمليات ستوراس',
          channelDescription: 'حالة إرسال العمليات المحفوظة',
          importance: Importance.low,
          priority: Priority.low,
          color: _primaryColor,
          onlyAlertOnce: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
        ),
      ),
    );
  }

  Future<void> sending(String title) async {
    await init();

    await _plugin.show(
      id: _syncNotificationId,
      title: 'جاري مزامنة العمليات',
      body: 'جاري إرسال: $title',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'storeus_offline_sync',
          'مزامنة عمليات ستوراس',
          channelDescription: 'حالة إرسال العمليات المحفوظة',
          importance: Importance.low,
          priority: Priority.low,
          color: _primaryColor,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showProgress: true,
          indeterminate: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
        ),
      ),
    );
  }

  Future<void> finished(String title) async {
    await init();

    await _plugin.cancel(id: _syncNotificationId);

    await _plugin.show(
      id: _successNotificationId,
      title: 'اكتملت المزامنة',
      body: 'تم تنفيذ: $title',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'storeus_offline_sync_results',
          'نتائج مزامنة ستوراس',
          channelDescription: 'نتائج إرسال العمليات المحفوظة',
          importance: Importance.high,
          priority: Priority.high,
          color: _primaryColor,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
        ),
      ),
    );
  }

  Future<void> error(String title) async {
    await init();

    await _plugin.cancel(id: _syncNotificationId);

    await _plugin.show(
      id: _errorNotificationId,
      title: 'تحتاج عملية للمراجعة',
      body: 'تعذر إكمال $title. راجع التطبيق.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'storeus_offline_sync_results',
          'نتائج مزامنة ستوراس',
          channelDescription: 'نتائج إرسال العمليات المحفوظة',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFFE53935),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
        ),
      ),
    );
  }

  Future<void> foregroundToast(String title) async {
    if (kIsWeb) return;

    await Fluttertoast.showToast(
      msg: 'اكتملت المزامنة: $title',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: _primaryColor,
      textColor: Colors.white,
    );
  }
}
