import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/alice.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeus_delivery/core/helpers/apis/api_constants.dart';
import 'package:storeus_delivery/core/helpers/apis/dio/locale_interceptor.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/runtime_variables.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';

/// Builds and configures the single shared [Dio] instance used across
/// the app: base options, TLS handling, and all interceptors
/// (auth, locale, logging, alice, cache).
class DioFactory {
  DioFactory._();

  static Dio? dio;

  static Future<Dio> getDio() async {
    if (dio != null) return dio!;

    dio = Dio();
    await _configureBaseOptions(dio!);
    _configureHttpClient(dio!);
    await _addInterceptors(dio!);

    return dio!;
  }

  static void updateLanguageHeader(String languageCode) {
    dio?.options.headers['Accept-Language'] = languageCode;
  }

  // ---------------------------------------------------------------------
  // Setup steps, each doing exactly one thing.
  // ---------------------------------------------------------------------

  static Future<void> _configureBaseOptions(Dio dio) async {
    final prefs = await SharedPreferences.getInstance();
    final String? localeCode = prefs.getString('locale');
    final Locale deviceLocale =
        WidgetsBinding.instance.platformDispatcher.locale;

    dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.headers = {
        'Accept-Language':
            navigatorKey.currentContext?.language ??
            localeCode ??
            deviceLocale.languageCode,
        'Accept': 'application/json',
      };
  }

  static void _configureHttpClient(Dio dio) {
    final ioAdapter = IOHttpClientAdapter();
    ioAdapter.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) => true;
      return client;
    };
    dio.httpClientAdapter = ioAdapter;
  }

  static Future<void> _addInterceptors(Dio dio) async {
    dio.interceptors.add(LocaleInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          requestHeader: true,
          responseHeader: true,
        ),
      );
    }

    if (RuntimeVariables.useAlice && !kDebugMode) {
      final alice = Alice(navigatorKey: navigatorKey);
      dio.interceptors.add(alice.getDioInterceptor());
    }
  }
}
