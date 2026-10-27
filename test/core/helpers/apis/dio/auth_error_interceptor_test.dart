import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:storeus_delivery/core/helpers/apis/api_constants.dart';
import 'package:storeus_delivery/core/helpers/apis/dio/auth_error_interceptor.dart';
import 'package:storeus_delivery/core/helpers/offline_cache/offline_cache_connectivity.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;
import 'package:storeus_delivery/core/routing/routes_names.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  late GoRouter router;
  late Dio dio;
  late _Backend adapter;
  String? previousToken;
  var loginNavigations = 0;
  final deletedSessions = <Object?>[];

  setUpAll(() {
    databaseFactory = databaseFactorySqflitePlugin;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.tekartik.sqflite'),
      (call) async {
        switch (call.method) {
          case 'getDatabasesPath':
            return 'C:/test-cache';
          case 'openDatabase':
            return {'id': 1};
          case 'query':
            return [
              {'user_version': 1},
            ];
          case 'update':
            final arguments = call.arguments as Map;
            expect(
              arguments['sql'],
              'DELETE FROM read_cache WHERE session_id = ?',
            );
            deletedSessions.addAll(arguments['arguments'] as List);
            return 1;
          default:
            throw StateError('Unexpected SQLite call: ${call.method}');
        }
      },
    );
  });

  setUp(() async {
    previousToken = token;
    deletedSessions.clear();
    token = 'current-token';
    FlutterSecureStorage.setMockInitialValues({
      'Access Token': 'current-token',
      'StoreUs Offline Session ID': 'current-session',
      'storeus_read_cache_aes_current-session': 'cache-key',
    });
    SharedPreferences.setMockInitialValues({'User Name': 'Driver'});
    await PreferencesHelper.init();
    loginNavigations = 0;
    router = GoRouter(
      initialLocation: '/protected',
      routes: [
        GoRoute(
          path: '/protected',
          builder: (_, _) => const Scaffold(body: Text('Protected')),
        ),
        GoRoute(
          path: '/details',
          builder: (_, _) => const Scaffold(body: Text('Details')),
        ),
        GoRoute(
          name: RoutesNames.login,
          path: RoutesNames.login,
          builder: (_, _) => const Scaffold(body: Text('Login')),
        ),
      ],
    );
    router.routeInformationProvider.addListener(() {
      if (router.routeInformationProvider.value.uri.path == RoutesNames.login) {
        loginNavigations++;
      }
    });
    adapter = _Backend();
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl))
      ..httpClientAdapter = adapter
      ..interceptors.add(AuthErrorInterceptor(router: router));
  });

  tearDown(() {
    dio.close(force: true);
    router.dispose();
    token = previousToken;
    FlutterSecureStorage.setMockInitialValues({});
    OfflineCacheStatus.instance.clear();
  });

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  Future<void> expectFailure(
    WidgetTester tester, {
    String path = '/me',
    String? authorization = 'Bearer current-token',
  }) async {
    await tester.runAsync(() async {
      await expectLater(
        dio.get<dynamic>(
          path,
          options: Options(headers: {'Authorization': ?authorization}),
        ),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'original status',
            adapter.status,
          ),
        ),
      );
    });
    await tester.pumpAndSettle();
  }

  for (final status in [401, 403]) {
    testWidgets('$status clears session and replaces the protected stack', (
      tester,
    ) async {
      await mount(tester);
      unawaited(router.push<void>('/details'));
      await tester.pumpAndSettle();
      expect(router.canPop(), isTrue);
      OfflineCacheStatus.instance.cached('snapshot', DateTime.now());
      adapter.status = status;

      await expectFailure(tester);

      expect(find.text('Login'), findsOneWidget);
      expect(router.canPop(), isFalse);
      expect(loginNavigations, 1);
      expect(token, isNull);
      expect(await PreferencesHelper.getToken(), isNull);
      expect(await PreferencesHelper.getOfflineSessionId(), isNull);
      expect(deletedSessions, ['current-session']);
      expect(
        await const FlutterSecureStorage().read(
          key: 'storeus_read_cache_aes_current-session',
        ),
        isNull,
      );
      expect(PreferencesHelper.getUserName(), '');
      expect(OfflineCacheStatus.instance.value.showingSavedData, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  for (final scenario in [
    (status: 400, path: '/me', auth: 'Bearer current-token'),
    (status: 500, path: '/me', auth: 'Bearer current-token'),
    (status: 403, path: '/me', auth: null),
    (status: 403, path: '/me', auth: 'Bearer '),
    (status: 403, path: '/login', auth: 'Bearer current-token'),
    (
      status: 403,
      path: 'https://other.invalid/me',
      auth: 'Bearer current-token',
    ),
    (
      status: 403,
      path: '${Uri.parse(ApiConstants.baseUrl).origin}/outside-api',
      auth: 'Bearer current-token',
    ),
  ]) {
    testWidgets('preserves session for $scenario', (tester) async {
      await mount(tester);
      adapter.status = scenario.status;
      await expectFailure(
        tester,
        path: scenario.path,
        authorization: scenario.auth,
      );
      expect(find.text('Protected'), findsOneWidget);
      expect(token, 'current-token');
      expect(await PreferencesHelper.getToken(), 'current-token');
      expect(loginNavigations, 0);
    });
  }

  testWidgets('network failures preserve the session', (tester) async {
    await mount(tester);
    adapter.networkFailure = true;
    adapter.status = null;
    await expectFailure(tester);
    expect(token, 'current-token');
    expect(loginNavigations, 0);
  });

  testWidgets('concurrent failures share one cleanup and redirect', (
    tester,
  ) async {
    await mount(tester);
    var cleanups = 0;
    await tester.runAsync(() async {
      final cleaning = Completer<void>();
      final release = Completer<void>();
      dio.interceptors
        ..clear()
        ..add(
          AuthErrorInterceptor(
            router: router,
            clearSession: () async {
              cleanups++;
              cleaning.complete();
              await release.future;
              await PreferencesHelper.removeToken();
            },
          ),
        );
      final first = expectLater(
        dio.get<dynamic>('/me', options: _authenticated()),
        throwsA(isA<DioException>()),
      );
      await cleaning.future;
      final secondStarted = Completer<void>();
      adapter.requested = () => secondStarted.complete();
      final second = expectLater(
        dio.get<dynamic>('/notifications', options: _authenticated()),
        throwsA(isA<DioException>()),
      );
      await secondStarted.future;
      release.complete();
      await Future.wait([first, second]);
    });
    await tester.pumpAndSettle();
    expect(cleanups, 1);
    expect(loginNavigations, 1);
  });

  testWidgets('late old-token failure cannot expire a new login', (
    tester,
  ) async {
    await mount(tester);
    await tester.runAsync(() async {
      final requested = Completer<void>();
      final response = Completer<void>();
      adapter.requested = () => requested.complete();
      adapter.responseGate = response.future;
      final failure = expectLater(
        dio.get<dynamic>('/me', options: _authenticated()),
        throwsA(isA<DioException>()),
      );
      await requested.future;
      await PreferencesHelper.saveToken('new-token');
      token = 'new-token';
      response.complete();
      await failure;
    });
    await tester.pumpAndSettle();
    expect(await PreferencesHelper.getToken(), 'new-token');
    expect(token, 'new-token');
    expect(loginNavigations, 0);
  });

  testWidgets('cleanup failure still redirects and forwards original error', (
    tester,
  ) async {
    await mount(tester);
    dio.interceptors
      ..clear()
      ..add(
        AuthErrorInterceptor(
          router: router,
          clearSession: () async => throw StateError('Storage unavailable'),
        ),
      );
    await expectFailure(tester);
    expect(token, isNull);
    expect(find.text('Login'), findsOneWidget);
    expect(loginNavigations, 1);
  });

  testWidgets('already on login does not navigate again', (tester) async {
    await mount(tester);
    router.goNamed(RoutesNames.login);
    await tester.pumpAndSettle();
    loginNavigations = 0;
    await expectFailure(tester);
    expect(loginNavigations, 0);
    expect(token, isNull);
  });

  testWidgets('a new login succeeds and can later expire again', (
    tester,
  ) async {
    await mount(tester);
    await expectFailure(tester);
    await tester.runAsync(() => PreferencesHelper.saveToken('new-token'));
    token = 'new-token';
    router.go('/protected');
    await tester.pumpAndSettle();
    adapter.status = 200;
    await tester.runAsync(() async {
      final response = await dio.get<dynamic>(
        '/me',
        options: Options(headers: {'authorization': 'bearer new-token'}),
      );
      expect(response.statusCode, 200);
    });
    expect(find.text('Protected'), findsOneWidget);
    adapter.status = 403;
    await expectFailure(tester, authorization: 'Bearer new-token');
    expect(find.text('Login'), findsOneWidget);
    expect(loginNavigations, 2);
  });
}

Options _authenticated() =>
    Options(headers: {'Authorization': 'Bearer current-token'});

class _Backend implements HttpClientAdapter {
  int? status = 403;
  bool networkFailure = false;
  VoidCallback? requested;
  Future<void>? responseGate;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requested?.call();
    await responseGate;
    if (networkFailure) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    return ResponseBody.fromString(
      '{"message":"لا تملك صلاحية تنفيذ هذا الإجراء."}',
      status!,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
