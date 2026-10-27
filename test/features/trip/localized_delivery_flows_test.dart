import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/retry_collection_request_body.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/get_order_details_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/update_delivery_location_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/utils/order_collection_policy.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_retry_collection_sheet.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/data/models/reschedule_order_request_body.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/domain/usecases/reschedule_order_usecase.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/cubit/reschedule_order_cubit.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/widgets/reschedule_order_sheet.dart';

class _RecordingDetails extends Fake implements GetOrderDetailsUsecase {
  final requests = <RetryCollectionRequestBody>[];
  ApiResult<dynamic> result = const ApiResult.success({'success': true});
  Completer<ApiResult<dynamic>>? pending;

  @override
  Future<ApiResult<dynamic>> retryCollection({
    required int tripId,
    required int orderId,
    required RetryCollectionRequestBody body,
  }) async {
    expect(tripId, 7);
    expect(orderId, 1);
    requests.add(body);
    return pending == null ? result : await pending!.future;
  }
}

class _UnusedTripOrders extends Fake implements GetTripOrdersUsecase {}

class _UnusedLocation extends Fake
    implements UpdateOrderDeliveryLocationUsecase {}

class _CollectionCubit extends OrderDetailsCubit {
  _CollectionCubit(_RecordingDetails details, TripOrderData order)
    : super(details, _UnusedTripOrders(), _UnusedLocation()) {
    emit(
      OrderDetailsSuccessState(
        const OrderDetailsData(
          salesOrder: 'SO-1',
          items: [],
          deliveryStatus: 'DELIVERED',
        ),
        tripOrder: order,
      ),
    );
  }
}

TripOrderData collectionOrder({
  String payment = 'UNPAID',
  bool canRetry = true,
  bool multiple = false,
}) => TripOrderData(
  id: 1,
  salesOrder: 'SO-1',
  stopOrder: 1,
  orderTotal: 150.25,
  deliveryStatus: 'DELIVERED',
  paymentStatus: payment,
  canRetryCollection: canRetry,
  pendingCollections: [
    const TripPendingCollection(clientOperationId: 'original-operation'),
    if (multiple)
      const TripPendingCollection(clientOperationId: 'other-operation'),
  ],
);

class _RecordingReschedule extends Fake implements RescheduleOrderUsecase {
  RescheduleOrderRequestBody? body;

  @override
  Future<ApiResult<dynamic>> call({
    required int tripId,
    required int orderId,
    required RescheduleOrderRequestBody body,
  }) async {
    this.body = body;
    return const ApiResult.success({'success': true});
  }
}

Future<void> openSheet(WidgetTester tester, WidgetBuilder sheet) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<dynamic>(
              context: context,
              isScrollControlled: true,
              builder: sheet,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> confirmCollection(
  WidgetTester tester,
  AppLocalizations strings,
) async {
  final send = find.widgetWithText(
    ElevatedButton,
    strings.retry_collection_confirm_full_amount,
  );
  await tester.ensureVisible(send);
  await tester.tap(send);
  await tester.pumpAndSettle();
  await tester.tap(
    find.widgetWithText(FilledButton, strings.retry_collection_confirm),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('collection presentation aliases do not alter eligibility policy', () {
    for (final status in [
      'PAID',
      'FULLY_PAID',
      'COLLECTED',
      'PARTIAL',
      'PARTIALLY_PAID',
      'PARTIAL_COLLECTED',
    ]) {
      expect(OrderCollectionPolicy.showCollectButton(status), isFalse);
    }
    for (final status in [
      'NOT_STARTED',
      'UNPAID',
      'PENDING',
      'FAILED',
      'NEW_STATUS',
    ]) {
      expect(OrderCollectionPolicy.showCollectButton(status), isTrue);
    }
  });

  test(
    'collection guards return stable messages without sending invalid requests',
    () async {
      final details = _RecordingDetails();
      final cubit = _CollectionCubit(details, collectionOrder());
      addTearDown(cubit.close);
      for (final amount in [0, -1, double.nan, double.infinity, 1.001]) {
        expect(
          await cubit.retryCollection(
            tripId: 7,
            orderId: 1,
            clientOperationId: 'original-operation',
            collectedAmount: amount,
          ),
          'order_collection_invalid_details',
        );
      }
      expect(
        await cubit.retryCollection(
          tripId: 7,
          orderId: 1,
          clientOperationId: 'wrong-operation',
          collectedAmount: 150.25,
        ),
        'order_collection_not_available',
      );
      expect(details.requests, isEmpty);
    },
  );

  test(
    'in-flight collection guard and backend messages remain intact',
    () async {
      final details = _RecordingDetails()
        ..pending = Completer<ApiResult<dynamic>>();
      final cubit = _CollectionCubit(details, collectionOrder());
      addTearDown(cubit.close);
      final first = cubit.retryCollection(
        tripId: 7,
        orderId: 1,
        clientOperationId: 'original-operation',
        collectedAmount: 150.25,
      );
      expect(
        await cubit.retryCollection(
          tripId: 7,
          orderId: 1,
          clientOperationId: 'original-operation',
          collectedAmount: 150.25,
        ),
        'order_collection_in_progress',
      );
      details.pending!.complete(
        const ApiResult.success({'success': false, 'message': 'رسالة الخادم'}),
      );
      expect(await first, 'رسالة الخادم');
      expect(details.requests, hasLength(1));
    },
  );

  testWidgets(
    'localized collection submits the full amount and original operation ID',
    (tester) async {
      final strings = await AppLocalizations.delegate.load(const Locale('ar'));
      final order = collectionOrder();
      final details = _RecordingDetails();
      final cubit = _CollectionCubit(details, order);
      addTearDown(cubit.close);
      await openSheet(
        tester,
        (_) => OrderRetryCollectionSheet(
          cubit: cubit,
          tripId: 7,
          order: order,
          salesOrder: 'SO-1',
          orderTotal: 150.25,
        ),
      );
      // Only optional notes are editable; no partial amount input is introduced.
      expect(find.byType(TextField), findsOneWidget);
      await confirmCollection(tester, strings);
      expect(details.requests, hasLength(1));
      expect(details.requests.single.clientOperationId, 'original-operation');
      expect(details.requests.single.collectedAmount, 150.25);
      expect(find.byType(OrderRetryCollectionSheet), findsNothing);
    },
  );

  testWidgets('ambiguous collection result is localized and requires refresh', (
    tester,
  ) async {
    final strings = await AppLocalizations.delegate.load(const Locale('ar'));
    final order = collectionOrder();
    final details = _RecordingDetails()
      ..result = ApiResult.failure(
        ErrorHandler.handle(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.connectionError,
          ),
        ),
      );
    final cubit = _CollectionCubit(details, order);
    addTearDown(cubit.close);
    await openSheet(
      tester,
      (_) => OrderRetryCollectionSheet(
        cubit: cubit,
        tripId: 7,
        order: order,
        salesOrder: 'SO-1',
        orderTotal: 150.25,
      ),
    );
    await confirmCollection(tester, strings);
    expect(find.text(strings.no_internet_please_try_again), findsOneWidget);
    expect(find.text('api_no_internet'), findsNothing);
    expect(
      find.widgetWithText(
        ElevatedButton,
        strings.retry_collection_close_refresh,
      ),
      findsOneWidget,
    );
    expect(details.requests, hasLength(1));
  });

  for (final scenario in [
    'partial',
    'unauthorized',
    'multiple',
    'missing_amount',
  ]) {
    testWidgets('collection stays disabled for $scenario', (tester) async {
      final strings = await AppLocalizations.delegate.load(const Locale('ar'));
      final order = collectionOrder(
        payment: scenario == 'partial' ? 'PARTIAL' : 'UNPAID',
        canRetry: scenario != 'unauthorized',
        multiple: scenario == 'multiple',
      );
      final details = _RecordingDetails();
      final cubit = _CollectionCubit(details, order);
      addTearDown(cubit.close);
      await openSheet(
        tester,
        (_) => OrderRetryCollectionSheet(
          cubit: cubit,
          tripId: 7,
          order: order,
          salesOrder: 'SO-1',
          orderTotal: scenario == 'missing_amount' ? null : 150.25,
        ),
      );
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(
          ElevatedButton,
          strings.retry_collection_confirm_full_amount,
        ),
      );
      expect(button.onPressed, isNull);
      expect(details.requests, isEmpty);
    });
  }

  for (final custom in [false, true]) {
    testWidgets(
      'localized rescheduling preserves ${custom ? 'custom' : 'canonical'} reason payload',
      (tester) async {
        tester.view.physicalSize = const Size(1000, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final strings = await AppLocalizations.delegate.load(
          const Locale('ar'),
        );
        final usecase = _RecordingReschedule();
        final cubit = RescheduleOrderCubit(usecase);
        addTearDown(cubit.close);
        await openSheet(
          tester,
          (_) => BlocProvider.value(
            value: cubit,
            child: const RescheduleOrderSheet(
              tripId: 7,
              orderId: 1,
              salesOrder: 'SO-1',
              customerName: 'عميل',
              address: 'عنوان',
            ),
          ),
        );
        await tester.tap(find.byIcon(Icons.calendar_today_outlined));
        await tester.pumpAndSettle();
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        tester
            .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
            .onDateChanged(tomorrow);
        await tester.pump();
        final dateOk = MaterialLocalizations.of(
          tester.element(find.byType(DatePickerDialog)),
        ).okButtonLabel;
        await tester.tap(find.text(dateOk));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.access_time_outlined));
        await tester.pumpAndSettle();
        final timeOk = MaterialLocalizations.of(
          tester.element(find.byType(TimePickerDialog)),
        ).okButtonLabel;
        await tester.tap(find.text(timeOk));
        await tester.pumpAndSettle();
        final label = custom
            ? strings.cancel_reason_other
            : strings.cancel_reason_shop_closed;
        final chip = find.widgetWithText(ChoiceChip, label);
        final formScroll = find
            .descendant(
              of: find.byType(RescheduleOrderSheet),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(chip, 160, scrollable: formScroll);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        if (custom) {
          final field = find.byWidgetPredicate(
            (widget) =>
                widget is TextField &&
                widget.decoration?.hintText ==
                    strings.reschedule_other_reason_hint,
          );
          await tester.scrollUntilVisible(field, 120, scrollable: formScroll);
          await tester.enterText(field, 'سبب يكتبه المستخدم');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }
        final submit = find.byType(ElevatedButton);
        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(usecase.body, isNotNull);
        expect(
          usecase.body!.reason,
          custom ? 'سبب يكتبه المستخدم' : 'المحل مغلق',
        );
        expect(usecase.body!.rescheduledFor.day, tomorrow.day);
      },
    );
  }
}
