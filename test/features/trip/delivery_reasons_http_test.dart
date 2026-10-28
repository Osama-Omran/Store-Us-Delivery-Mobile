import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/repo/concrete_delivery_outcome_repo.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/repo/concrete_delivery_reasons_repo.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/usecases/get_delivery_reasons_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/usecases/submit_delivery_outcome_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_state.dart';

/// Run against a freshly started local delivery-reasons Postman simulation with
/// `--dart-define=DELIVERY_REASONS_SIMULATION_URL=http://127.0.0.1:PORT/delivery/api/mobile/v1`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('DELIVERY_REASONS_SIMULATION_URL');

  test(
    'real repositories and generated Retrofit client preserve JSON and retry UUIDs',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'Access Token': 'delivery-reasons-test',
      });
      await HttpOverrides.runWithHttpOverrides(() async {
        final dio = Dio(
          BaseOptions(
            baseUrl: url,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        addTearDown(() => dio.close(force: true));
        final api = TripApiService(dio);
        DeliveryOutcomeCubit createCubit() => DeliveryOutcomeCubit(
          SubmitDeliveryOutcomeUsecase(ConcreteDeliveryOutcomeRepo(api)),
          DeliveryReasonsCubit(
            GetDeliveryReasonsUsecase(ConcreteDeliveryReasonsRepo(api)),
          ),
        );

        final cancellation = createCubit();
        addTearDown(cancellation.close);
        await cancellation.reasonsCubit.loadReasons();
        expect(cancellation.reasonsCubit.state, isA<DeliveryReasonsFailure>());
        await cancellation.reasonsCubit.loadReasons();
        expect(cancellation.reasonsCubit.state, isA<DeliveryReasonsSuccess>());
        await cancellation.reasonsCubit
            .loadReasons(); // Uses the loaded response.
        Future<void> cancel() => cancellation.submit(
          tripId: 7,
          orderId: 42,
          outcome: DeliveryOutcomeType.cancelled,
          reason: 'Price Change ',
        );
        await cancel();
        expect(cancellation.state, isA<DeliveryOutcomeFailure>());
        cancellation.resetFailure();
        await cancel();
        expect(cancellation.state, isA<DeliveryOutcomeSuccess>());

        final rescheduling = createCubit();
        addTearDown(rescheduling.close);
        await rescheduling.reasonsCubit.loadReasons();
        final reasons =
            (rescheduling.reasonsCubit.state as DeliveryReasonsSuccess).data;
        final selectedDate = DateTime.now().add(const Duration(days: 2));
        final date = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          14,
        );
        final serialized = DeliveryOutcomeRequestBody.formatRescheduledFor(
          date,
        );
        Future<void> reschedule() => rescheduling.submit(
          tripId: 7,
          orderId: 43,
          outcome: DeliveryOutcomeType.rescheduled,
          reason: reasons.rescheduling.first,
          rescheduledFor: serialized,
        );
        await reschedule();
        expect(rescheduling.state, isA<DeliveryOutcomeFailure>());
        await reschedule();
        expect(rescheduling.state, isA<DeliveryOutcomeSuccess>());

        final response = await dio.get<Map<String, dynamic>>(
          '$url/_verification',
        );
        final observations = response.data!;
        expect(observations['reasonsRequests'], 3);
        final requests = (observations['requests'] as List)
            .cast<Map<String, dynamic>>();
        expect(requests, hasLength(4));
        expect(requests[0], requests[1]);
        expect(requests[2], requests[3]);
        for (final request in requests) {
          expect(request['authorization'], 'Bearer delivery-reasons-test');
        }
        expect(
          requests[0]['path'],
          '/api/mobile/v1/trips/7/orders/42/delivery-outcome',
        );
        final cancelled = requests[0]['body'] as Map;
        expect(cancelled['reason'], 'Price Change ');
        expect(cancelled['outcome'], 'CANCELLED');
        expect(cancelled.containsKey('rescheduled_for'), isFalse);
        expect(
          requests[2]['path'],
          '/api/mobile/v1/trips/7/orders/43/delivery-outcome',
        );
        final rescheduled = requests[2]['body'] as Map;
        expect(rescheduled['reason'], 'طلب العميل موعدًا آخر');
        expect(rescheduled['outcome'], 'RESCHEDULED');
        expect(rescheduled['rescheduled_for'], serialized);
        expect(DateTime.parse(serialized).isAtSameMomentAs(date), isTrue);
        expect(
          rescheduled['client_operation_id'],
          isNot(cancelled['client_operation_id']),
        );
      }, _LocalHttpOverrides());
    },
    skip: url.isEmpty
        ? 'Requires a running local delivery-reasons simulation.'
        : false,
  );
}

// Permit real localhost HTTP instead of flutter_test's synthetic HTTP 400 client.
class _LocalHttpOverrides extends HttpOverrides {}
