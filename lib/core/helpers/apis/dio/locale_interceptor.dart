import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';

/// Attaches the correct `Accept-Language` header to every request,
/// preferring (in order): the current app context locale, the saved
/// locale in SharedPreferences, then the device locale.
class LocaleInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('locale');
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

    options.headers['Accept-Language'] =
        navigatorKey.currentContext?.language ??
        localeCode ??
        deviceLocale.languageCode;

    return handler.next(options);
  }
}
