import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/routing/app_router.dart'
    show navigatorKey, token;
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_wallet_response.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/repo/concrete_treasury_wallet_repo.dart';

void main() {
  late String? previousToken;
  late Dio dio;
  late _RecordingAdapter adapter;
  late ConcreteTreasuryWalletRepo repository;

  setUp(() {
    previousToken = token;
    token = null;
    FlutterSecureStorage.setMockInitialValues({});
    adapter = _RecordingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
      ..httpClientAdapter = adapter;
    repository = ConcreteTreasuryWalletRepo(TripApiService(dio));
  });

  tearDown(() {
    dio.close(force: true);
    token = previousToken;
    FlutterSecureStorage.setMockInitialValues({});
  });

  const cases = [
    (
      description: 'rejects when both tokens are absent',
      prefToken: null,
      appToken: null,
      authorization: null,
    ),
    (
      description: 'rejects an absent preference and empty global token',
      prefToken: null,
      appToken: '',
      authorization: null,
    ),
    (
      description: 'rejects an empty preference and absent global token',
      prefToken: '',
      appToken: null,
      authorization: null,
    ),
    (
      description: 'rejects when both tokens are empty',
      prefToken: '',
      appToken: '',
      authorization: null,
    ),
    (
      description: 'rejects a whitespace preference and absent global token',
      prefToken: ' \t\n ',
      appToken: null,
      authorization: null,
    ),
    (
      description: 'rejects a whitespace preference and empty global token',
      prefToken: ' \t\n ',
      appToken: '',
      authorization: null,
    ),
    (
      description: 'uses the preference token when global token is absent',
      prefToken: 'persisted-token',
      appToken: null,
      authorization: 'Bearer persisted-token',
    ),
    (
      description: 'uses the preference token when global token is empty',
      prefToken: 'persisted-token',
      appToken: '',
      authorization: 'Bearer persisted-token',
    ),
    (
      description: 'uses the global token when preference token is absent',
      prefToken: null,
      appToken: 'memory-token',
      authorization: 'Bearer memory-token',
    ),
    (
      description: 'uses the global token when preference token is empty',
      prefToken: '',
      appToken: 'memory-token',
      authorization: 'Bearer memory-token',
    ),
    (
      description: 'uses the global token when preference token is whitespace',
      prefToken: ' \t\n ',
      appToken: 'memory-token',
      authorization: 'Bearer memory-token',
    ),
    (
      description: 'prefers the persisted token when both tokens are valid',
      prefToken: 'persisted-token',
      appToken: 'different-memory-token',
      authorization: 'Bearer persisted-token',
    ),
  ];

  for (final scenario in cases) {
    testWidgets(scenario.description, (tester) async {
      final prefToken = scenario.prefToken;
      FlutterSecureStorage.setMockInitialValues({'Access Token': ?prefToken});
      token = scenario.appToken;

      // The repository's existing error handler reads localized UI strings.
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();

      final result = await tester.runAsync(
        () => repository.getWallet(tripId: 42),
      );

      if (scenario.authorization == null) {
        expect(result, isA<Failure<TreasuryWalletResponse>>());
        expect(adapter.requests, isEmpty);
      } else {
        expect(
          result,
          isA<Success<TreasuryWalletResponse>>().having(
            (success) => success.data.success,
            'wallet response success',
            isTrue,
          ),
        );
        expect(adapter.requests, hasLength(1));
        final request = adapter.requests.single;
        expect(request.path, '/trips/42/wallet');
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], scenario.authorization);
      }
    });
  }
}

class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"success":true,"data":{"trip":"TRIP-42"}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
