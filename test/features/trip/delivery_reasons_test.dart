import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/repo/trip_orders_repo_interface.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/repo/order_details_repo_interface.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/get_order_details_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/update_delivery_location_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_action_bar.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_model.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/widgets/cancel_delivery_sheet.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/repo/delivery_outcome_repo_interface.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/repo/delivery_reasons_repo_interface.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/usecases/get_delivery_reasons_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/usecases/submit_delivery_outcome_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_reason_dropdown.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/widgets/reschedule_order_sheet.dart';

const _reasons = DeliveryReasonsData(
  cancellation: ['Order Delayed', 'Price Change ', 'Order Delayed', '', '  '],
  rescheduling: ['طلب العميل موعدًا آخر', 'تعذر التواصل مع العميل'],
  partialDelivery: ['Partial only'],
);

void main() {
  testWidgets(
    'accepted cancellation refreshes details and navigates even when refresh throws',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = _Fixture();
      final details = _RefreshDetailsCubit();
      addTearDown(fixture.cubit.close);
      addTearDown(details.close);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
                builder: (_, state) => state is OrderDetailsSuccessState
                    ? const OrderActionBar(tripId: 7, orderId: 42)
                    : const Text('Refreshing'),
              ),
            ),
          ),
          GoRoute(
            path: '/cancelled',
            name: RoutesNames.cancelDeliverySuccess,
            builder: (_, state) => Scaffold(
              body: Text('Cancelled: ${(state.extra as Map)['reason']}'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: fixture.cubit),
            BlocProvider<OrderDetailsCubit>.value(value: details),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.block_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Price Change ').last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'تأكيد إلغاء التسليم'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();
      expect(find.text('Cancelled: Price Change '), findsOneWidget);
      expect(details.refreshes, 1);
      expect(fixture.outcomes.requests.single['reason'], 'Price Change ');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test('parsing preserves every API value and its original whitespace', () {
    final values = List.generate(12, (index) => 'Server reason $index ');
    final response = DeliveryReasonsResponse.fromJson({
      'success': true,
      'data': {
        'cancellation': values,
        'rescheduling': ['طلب العميل موعدًا آخر'],
        'partial_delivery': <String>[],
      },
    });
    expect(response.data.cancellation, values);
    expect(response.data.cancellation.last, 'Server reason 11 ');
    expect(response.data.partialDelivery, isEmpty);
  });

  test(
    'reasons deduplicate requests, cache success, and explicitly reload',
    () async {
      final repo = _ReasonsRepo();
      final pending = Completer<ApiResult<DeliveryReasonsData>>();
      repo.next = () => pending.future;
      final cubit = DeliveryReasonsCubit(GetDeliveryReasonsUsecase(repo));
      addTearDown(cubit.close);
      final loading = cubit.loadReasons();
      await cubit.loadReasons();
      expect(repo.calls, 1);
      expect(cubit.state, isA<DeliveryReasonsLoading>());
      pending.complete(const ApiResult.success(_reasons));
      await loading;
      await cubit.loadReasons();
      expect(repo.calls, 1);
      repo.next = () async => ApiResult.failure(_failure());
      await cubit.loadReasons(force: true);
      expect(cubit.state, isA<DeliveryReasonsFailure>());
      expect(
        cubit.containsReason(
          DeliveryReasonCategory.cancellation,
          'Order Delayed',
        ),
        isFalse,
      );
      repo.next = null;
      await cubit.loadReasons();
      expect(repo.calls, 3);
      expect(cubit.state, isA<DeliveryReasonsSuccess>());
    },
  );

  test(
    'submission rejects unavailable, blank, stale, or wrong-category reasons',
    () async {
      final fixture = _Fixture();
      addTearDown(fixture.cubit.close);
      await fixture.cancel('Order Delayed');
      expect(fixture.outcomes.requests, isEmpty);
      await fixture.cubit.reasonsCubit.loadReasons();
      for (final reason in [
        '',
        '  ',
        'Price Change',
        'Manual text',
        'Partial only',
        _reasons.rescheduling.first,
      ]) {
        await fixture.cancel(reason);
        expect(fixture.cubit.state, isA<DeliveryOutcomeFailure>());
      }
      await fixture.reschedule('Order Delayed', _future());
      expect(fixture.outcomes.requests, isEmpty);
      fixture.reasons.next = () async => const ApiResult.success(
        DeliveryReasonsData(
          cancellation: [],
          rescheduling: [],
          partialDelivery: [],
        ),
      );
      await fixture.cubit.reasonsCubit.loadReasons(force: true);
      await fixture.cancel('Order Delayed');
      expect(fixture.outcomes.requests, isEmpty);
    },
  );

  test(
    'cancellation sends exact whitespace and no rescheduled_for field',
    () async {
      final fixture = _Fixture();
      addTearDown(fixture.cubit.close);
      await fixture.cubit.reasonsCubit.loadReasons();
      await fixture.cancel('Price Change ');
      final request = fixture.outcomes.requests.single;
      expect(request['outcome'], 'CANCELLED');
      expect(request['reason'], 'Price Change ');
      expect(request.containsKey('rescheduled_for'), isFalse);
      expect(
        request['client_operation_id'],
        matches(
          RegExp(
            r'^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$',
          ),
        ),
      );
      expect(fixture.cubit.state, isA<DeliveryOutcomeSuccess>());
    },
  );

  test('rescheduling requires a future time with an explicit offset', () async {
    final fixture = _Fixture();
    addTearDown(fixture.cubit.close);
    await fixture.cubit.reasonsCubit.loadReasons();
    for (final date in [
      null,
      'invalid',
      '2035-10-29T14:00:00',
      '2020-10-29T14:00:00+02:00',
    ]) {
      await fixture.reschedule(_reasons.rescheduling.first, date);
      expect(fixture.cubit.state, isA<DeliveryOutcomeFailure>());
    }
    expect(fixture.outcomes.requests, isEmpty);
    await fixture.reschedule(
      _reasons.rescheduling.first,
      '2035-10-29T14:00:00+02:00',
    );
    expect(
      fixture.outcomes.requests.single['reason'],
      _reasons.rescheduling.first,
    );
    expect(
      fixture.outcomes.requests.single['rescheduled_for'],
      '2035-10-29T14:00:00+02:00',
    );
    expect(fixture.outcomes.requests.single['outcome'], 'RESCHEDULED');
  });

  test('local serialization preserves selected wall time and date-specific offset', () {
    for (final date in [
      DateTime(2035, 1, 29, 14, 7),
      DateTime(2035, 7, 29, 14, 7),
      DateTime.utc(2035, 10, 29, 14, 7),
    ]) {
      final serialized = DeliveryOutcomeRequestBody.formatRescheduledFor(date);
      expect(serialized, contains('T14:07:00'));
      expect(DateTime.parse(serialized).isAtSameMomentAs(date), isTrue);
      final offset = date.timeZoneOffset.inMinutes;
      final suffix =
          '${offset < 0 ? '-' : '+'}${(offset.abs() ~/ 60).toString().padLeft(2, '0')}:${(offset.abs() % 60).toString().padLeft(2, '0')}';
      expect(serialized, endsWith(suffix));
    }
  });

  test('uncertain retries reuse UUID; edited payloads and definite rejections reset it', () async {
    final fixture = _Fixture();
    addTearDown(fixture.cubit.close);
    await fixture.cubit.reasonsCubit.loadReasons();
    fixture.outcomes.next = () async => ApiResult.failure(_failure(503));
    await fixture.cancel('Price Change ');
    fixture.cubit.resetFailure(); // Closing/reopening a sheet retains its order-scoped Cubit.
    await fixture.cancel('Price Change ');
    expect(fixture.outcomes.requests[0], fixture.outcomes.requests[1]);
    await fixture.cancel('Order Delayed');
    expect(
      fixture.outcomes.requests[2]['client_operation_id'],
      isNot(fixture.outcomes.requests[1]['client_operation_id']),
    );
    fixture.outcomes.next = () async =>
        const ApiResult.success({'success': false, 'message': 'Rejected'});
    await fixture.cancel('Order Delayed');
    await fixture.cancel('Order Delayed');
    expect(
      fixture.outcomes.requests[4]['client_operation_id'],
      isNot(fixture.outcomes.requests[3]['client_operation_id']),
    );
    fixture.outcomes.next = () async => ApiResult.failure(_failure(422));
    await fixture.cancel('Order Delayed');
    await fixture.cancel('Order Delayed');
    expect(
      fixture.outcomes.requests[6]['client_operation_id'],
      isNot(fixture.outcomes.requests[5]['client_operation_id']),
    );
  });

  test(
    'duplicate submissions are blocked during loading and after success',
    () async {
      final fixture = _Fixture();
      addTearDown(fixture.cubit.close);
      await fixture.cubit.reasonsCubit.loadReasons();
      final pending = Completer<ApiResult<dynamic>>();
      fixture.outcomes.next = () => pending.future;
      final first = fixture.cancel('Order Delayed');
      expect(fixture.cubit.state, isA<DeliveryOutcomeLoading>());
      await fixture.cancel('Order Delayed');
      expect(fixture.outcomes.requests, hasLength(1));
      pending.complete(const ApiResult.success({'success': true}));
      await first;
      await fixture.cancel('Order Delayed');
      expect(fixture.outcomes.requests, hasLength(1));
    },
  );

  testWidgets(
    'dropdown shows loading/error/empty/retry and preserves external ownership',
    (tester) async {
      final fixture = _Fixture();
      addTearDown(fixture.cubit.close);
      final pending = Completer<ApiResult<DeliveryReasonsData>>();
      fixture.reasons.next = () => pending.future;
      await tester.pumpWidget(
        _app(
          fixture.cubit,
          DeliveryReasonDropdown(
            cubit: fixture.cubit.reasonsCubit,
            category: DeliveryReasonCategory.cancellation,
            value: null,
            label: 'Reason',
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete(ApiResult.failure(_failure()));
      await tester.pumpAndSettle();
      expect(
        find.text('تعذر تحميل أسباب التسليم. حاول مرة أخرى.'),
        findsOneWidget,
      );
      fixture.reasons.next = () async => const ApiResult.success(
        DeliveryReasonsData(
          cancellation: [],
          rescheduling: [],
          partialDelivery: [],
        ),
      );
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();
      expect(find.text('لا توجد أسباب متاحة حاليًا'), findsOneWidget);
      fixture.reasons.next = null;
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();
      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(dropdown.onChanged, isNotNull);
      await tester.pumpWidget(const SizedBox());
      expect(fixture.cubit.reasonsCubit.isClosed, isFalse);
      await fixture.cubit.reasonsCubit.loadReasons();
      expect(fixture.reasons.calls, 3);
    },
  );

  testWidgets(
    'cancellation requires API selection, confirmation, and sends exact reason',
    (tester) async {
      final fixture = _Fixture();
      addTearDown(fixture.cubit.close);
      Map<String, dynamic>? result;
      await _openSheet(
        tester,
        fixture.cubit,
        const CancelDeliverySheet(
          tripId: 7,
          orderId: 42,
          customerName: 'Customer',
          salesOrder: 'SO-42',
        ),
        (value) => result = value,
      );
      final confirm = find.widgetWithText(
        ElevatedButton,
        'تأكيد إلغاء التسليم',
      );
      expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(
        find.byType(TextField),
        findsOneWidget,
      ); // Separate optional notes remain.
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      expect(find.text(_reasons.rescheduling.first), findsNothing);
      await tester.tap(find.text('Price Change ').last);
      await tester.pumpAndSettle();
      expect(tester.widget<ElevatedButton>(confirm).onPressed, isNotNull);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(fixture.outcomes.requests, isEmpty);
      final buttons = find.byType(ElevatedButton);
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();
      expect(fixture.outcomes.requests.single['reason'], 'Price Change ');
      expect(result?['reason'], 'Price Change ');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'rescheduling preserves date/time pickers and requires a reason plus future time',
    (tester) async {
      final fixture = _Fixture();
      addTearDown(fixture.cubit.close);
      await _openSheet(
        tester,
        fixture.cubit,
        const RescheduleOrderSheet(
          tripId: 7,
          orderId: 42,
          customerName: 'Customer',
          salesOrder: 'SO-42',
          address: 'Address',
        ),
        (_) {},
      );
      final confirm = find.widgetWithText(
        ElevatedButton,
        'تأكيد إعادة الجدولة',
      );
      expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      expect(find.text('Price Change '), findsNothing);
      await tester.tap(find.text(_reasons.rescheduling.first).last);
      await tester.pumpAndSettle();
      expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);
      final dateButton = find.ancestor(
        of: find.byIcon(Icons.calendar_today_outlined),
        matching: find.byType(OutlinedButton),
      );
      await tester.tap(dateButton);
      await tester.pumpAndSettle();
      final localizations = MaterialLocalizations.of(
        tester.element(find.byType(DatePickerDialog)),
      );
      await tester.tap(find.byTooltip(localizations.inputDateModeButtonLabel));
      await tester.pumpAndSettle();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await tester.enterText(
        find.byType(TextField).last,
        localizations.formatCompactDate(tomorrow),
      );
      await tester.tap(find.text(localizations.okButtonLabel));
      await tester.pumpAndSettle();
      final timeButton = find.ancestor(
        of: find.byIcon(Icons.access_time_outlined),
        matching: find.byType(OutlinedButton),
      );
      await tester.tap(timeButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text(localizations.okButtonLabel));
      await tester.pumpAndSettle();
      expect(tester.widget<ElevatedButton>(confirm).onPressed, isNotNull);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      final body = fixture.outcomes.requests.single;
      expect(body['reason'], _reasons.rescheduling.first);
      expect(body['outcome'], 'RESCHEDULED');
      final date = DateTime.parse(body['rescheduled_for'] as String).toLocal();
      expect(
        [date.year, date.month, date.day],
        [tomorrow.year, tomorrow.month, tomorrow.day],
      );
      expect(
        body['rescheduled_for'],
        DeliveryOutcomeRequestBody.formatRescheduledFor(date),
      );
      expect(tester.takeException(), isNull);
    },
  );
}

String _future() => DeliveryOutcomeRequestBody.formatRescheduledFor(
  DateTime.now().add(const Duration(days: 1)),
);

ErrorHandler _failure([int? code]) =>
    ErrorHandler.handle(StateError('Failed'))
      ..apiErrorModel = ApiErrorModel(message: 'Failed', errorCode: code);

class _ReasonsRepo implements DeliveryReasonsRepoInterface {
  int calls = 0;
  Future<ApiResult<DeliveryReasonsData>> Function()? next;
  @override
  Future<ApiResult<DeliveryReasonsData>> getDeliveryReasons() {
    calls++;
    return next?.call() ?? Future.value(const ApiResult.success(_reasons));
  }
}

class _OutcomeRepo implements DeliveryOutcomeRepoInterface {
  final requests = <Map<String, dynamic>>[];
  Future<ApiResult<dynamic>> Function()? next;
  @override
  Future<ApiResult<dynamic>> submitDeliveryOutcome({
    required int tripId,
    required int orderId,
    required DeliveryOutcomeRequestBody body,
  }) {
    expect([tripId, orderId], [7, 42]);
    requests.add(body.toJson());
    return next?.call() ??
        Future.value(const ApiResult.success({'success': true}));
  }
}

class _Fixture {
  final reasons = _ReasonsRepo();
  final outcomes = _OutcomeRepo();
  late final cubit = DeliveryOutcomeCubit(
    SubmitDeliveryOutcomeUsecase(outcomes),
    DeliveryReasonsCubit(GetDeliveryReasonsUsecase(reasons)),
  );
  Future<void> cancel(String reason) => cubit.submit(
    tripId: 7,
    orderId: 42,
    outcome: DeliveryOutcomeType.cancelled,
    reason: reason,
  );
  Future<void> reschedule(String reason, String? date) => cubit.submit(
    tripId: 7,
    orderId: 42,
    outcome: DeliveryOutcomeType.rescheduled,
    reason: reason,
    rescheduledFor: date,
  );
}

class _UnusedRepos
    implements OrderDetailsRepoInterface, TripOrdersRepoInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _RefreshDetailsCubit extends OrderDetailsCubit {
  _RefreshDetailsCubit()
    : super(
        GetOrderDetailsUsecase(_UnusedRepos()),
        GetTripOrdersUsecase(_UnusedRepos()),
        UpdateOrderDeliveryLocationUsecase(_UnusedRepos()),
      ) {
    emit(
      OrderDetailsSuccessState(
        const OrderDetailsData(
          salesOrder: 'SO-42',
          items: [],
          deliveryStatus: 'PENDING',
        ),
      ),
    );
  }
  int refreshes = 0;
  @override
  Future<void> getOrderDetails({
    required int tripId,
    required int orderId,
  }) async {
    refreshes++;
    emit(OrderDetailsLoadingState());
    throw StateError('Simulated refresh failure after accepted cancellation');
  }
}

Widget _app(DeliveryOutcomeCubit cubit, Widget child) => BlocProvider.value(
  value: cubit,
  child: MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);

Future<void> _openSheet(
  WidgetTester tester,
  DeliveryOutcomeCubit cubit,
  Widget sheet,
  ValueChanged<Map<String, dynamic>?> onResult,
) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    _app(
      cubit,
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async => onResult(
            await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              builder: (_) => sheet,
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
