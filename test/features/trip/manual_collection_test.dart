import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/direct_sale_models.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/submit_pos_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/vehicle_stock_response.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/repo/submit_pos_repo_interface.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/create_customer_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/get_customer_options_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/get_vehicle_stock_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/submit_pos_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/cubit/direct_sale_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/cubit/direct_sale_state.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/widgets/direct_sale_amount_field.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/confirm_delivery_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/repo/confirm_delivery_repo_interface.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/usecases/confirm_delivery_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/confirm_delivery_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/confirm_delivery_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_payment_confirmation_sheet.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_payment_form.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_payment_submit_button.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/retry_collection_request_body.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/repo/order_details_repo_interface.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/get_order_details_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/update_delivery_location_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_retry_collection_sheet.dart';

ApiResult<T> _unconfirmed<T>() =>
    ApiResult.failure(ErrorHandler.handle(StateError('connection lost')));

class _ConfirmRepo extends Fake implements ConfirmDeliveryRepoInterface {
  final requests = <ConfirmDeliveryRequestBody>[];
  Completer<ApiResult<dynamic>>? pending;
  bool fail = false;

  @override
  Future<ApiResult<dynamic>> confirmDelivery({
    required int tripId,
    required int orderId,
    required ConfirmDeliveryRequestBody body,
  }) async {
    requests.add(body);
    if (pending != null) return pending!.future;
    return fail
        ? _unconfirmed<dynamic>()
        : const ApiResult.success({'success': true});
  }
}

class _OrderRepo extends Fake implements OrderDetailsRepoInterface {
  final requests = <RetryCollectionRequestBody>[];
  Completer<ApiResult<dynamic>>? pending;
  @override
  Future<ApiResult<OrderDetailsResponse>> getOrderDetails({
    required int tripId,
    required int orderId,
  }) async => const ApiResult.success(
    OrderDetailsResponse(
      success: true,
      data: OrderDetailsData(
        salesOrder: 'SO-1',
        originalTotal: 150.75,
        items: [],
        deliveryStatus: 'DELIVERED',
      ),
    ),
  );

  @override
  Future<ApiResult<dynamic>> retryCollection({
    required int tripId,
    required int orderId,
    required RetryCollectionRequestBody body,
  }) async {
    requests.add(body);
    if (pending != null) return pending!.future;
    return const ApiResult.success({'success': true});
  }
}

const _order = TripOrderData(
  id: 2,
  salesOrder: 'SO-1',
  stopOrder: 1,
  orderTotal: 150.75,
  deliveryStatus: 'DELIVERED',
  paymentStatus: 'UNPAID',
  canRetryCollection: true,
  pendingCollections: [
    TripPendingCollection(clientOperationId: 'original-operation'),
  ],
);

class _OrdersUsecase extends Fake implements GetTripOrdersUsecase {
  @override
  Future<ApiResult<TripOrdersResponse>> call({required int tripId}) async =>
      const ApiResult.success(
        TripOrdersResponse(success: true, data: [_order]),
      );
}

class _UnusedLocation extends Fake
    implements UpdateOrderDeliveryLocationUsecase {}

class _UnusedCreateCustomer extends Fake implements CreateCustomerUsecase {}

class _UnusedCustomerOptions extends Fake
    implements GetCustomerOptionsUsecase {}

class _StockUsecase extends Fake implements GetVehicleStockUsecase {
  @override
  Future<ApiResult<VehicleStockData>> call(int tripId) async =>
      _unconfirmed<VehicleStockData>();
}

class _PosRepo extends Fake implements SubmitPosRepoInterface {
  final requests = <SubmitPosRequestBody>[];
  bool fail = false;
  @override
  Future<ApiResult<SubmitPosResponse>> submitPos(
    int tripId,
    SubmitPosRequestBody request,
  ) async {
    requests.add(request);
    return fail
        ? _unconfirmed<SubmitPosResponse>()
        : const ApiResult.success(SubmitPosResponse(success: true));
  }
}

DeliveryFlowData _flow(bool partial) => DeliveryFlowData(
  tripId: 1,
  orderId: 2,
  salesOrder: 'SO-1',
  customerName: 'Customer',
  items: [
    DeliveryFlowItem(
      itemCode: 'ITEM',
      itemName: 'Product',
      uom: 'Unit',
      orderedQty: partial ? 2 : 1,
      selectedQty: 1,
      lineId: 'LINE-1',
      rate: partial ? 100 : 150.75,
    ),
  ],
  extraItems: partial
      ? [
          const DeliveryFlowExtraItem(
            itemCode: 'EXTRA',
            itemName: 'Extra product',
            uom: 'Unit',
            selectedQty: 1,
            availableQty: 2,
            rateMinor: 5075,
          ),
        ]
      : [],
);

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('ar'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

DirectSaleCubit _posCubit(_PosRepo repo) => DirectSaleCubit(
  createCustomerUsecase: _UnusedCreateCustomer(),
  getCustomerOptionsUsecase: _UnusedCustomerOptions(),
  getVehicleStockUsecase: _StockUsecase(),
  submitPosUsecase: SubmitPosUsecase(repo),
  tripId: 1,
  initialState: const DirectSaleState(
    step: DirectSaleStep.payment,
    customer: DirectSaleCustomer(id: 'CUSTOMER', name: 'Customer'),
    products: [
      DirectSaleProduct(
        code: 'ITEM',
        name: 'Product',
        unit: 'Unit',
        availableQuantity: 2,
        unitPriceMinor: 15075,
      ),
    ],
    quantities: {'ITEM': 1},
    vehicleStockLoaded: true,
    inventoryAvailable: true,
  ),
);

void main() {
  void largeScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  for (final partial in [false, true]) {
    testWidgets(
      'delivery requires typing and submits the reviewed amount (partial=$partial)',
      (tester) async {
        largeScreen(tester);
        final repo = _ConfirmRepo()..pending = Completer<ApiResult<dynamic>>();
        final cubit = ConfirmDeliveryCubit(ConfirmDeliveryUsecase(repo));
        addTearDown(cubit.close);
        Object? successArgs;
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, state) => DeliveryPaymentForm(flow: _flow(partial)),
            ),
            GoRoute(
              path: '/success',
              name: RoutesNames.deliverySuccess,
              builder: (_, state) {
                successArgs = state.extra;
                return const Scaffold(body: Text('Success'));
              },
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          BlocProvider.value(
            value: cubit,
            child: MaterialApp.router(
              locale: const Locale('ar'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final field = find.byKey(const ValueKey('delivery-collection-amount'));
        final button = find.descendant(
          of: find.byType(DeliveryPaymentSubmitButton),
          matching: find.byType(ElevatedButton),
        );
        expect(tester.widget<TextField>(field).controller!.text, isEmpty);
        for (final value in [
          '',
          '-150.75',
          '0',
          '150.751',
          'abc',
          '149.75',
          '151.75',
        ]) {
          await tester.enterText(field, value);
          await tester.pump();
          expect(
            tester.widget<ElevatedButton>(button).onPressed,
            isNull,
            reason: value,
          );
        }
        await tester.enterText(field, '١٥٠٫٧٥');
        await tester.pump();
        expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
        await tester.enterText(field, '');
        await tester.pump();
        expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
        await tester.enterText(field, '١٥٠٫٧٥');
        await tester.pump();
        await tester.tap(button);
        await tester.pumpAndSettle();
        final review = tester.widget<DeliveryPaymentConfirmationSheet>(
          find.byType(DeliveryPaymentConfirmationSheet),
        );
        expect(review.enteredAmountText, review.expectedAmountText);
        expect(tester.widget<TextField>(field).enabled, isFalse);
        final confirm = find.descendant(
          of: find.byType(DeliveryPaymentConfirmationSheet),
          matching: find.byType(ElevatedButton),
        );
        await tester.tap(confirm);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(repo.requests, hasLength(1));
        expect(repo.requests.single.collectedAmount, 150.75);
        expect(repo.requests.single.items.single.lineId, 'LINE-1');
        expect(repo.requests.single.extraItems, hasLength(partial ? 1 : 0));
        expect(tester.widget<TextField>(field).enabled, isFalse);
        repo.pending!.complete(const ApiResult.success({'success': true}));
        await tester.pumpAndSettle();
        expect((successArgs as Map)['collected_amount'], 150.75);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'retry collection requires typing and blocks another send after uncertainty',
    (tester) async {
      largeScreen(tester);
      final repo = _OrderRepo()..pending = Completer<ApiResult<dynamic>>();
      final cubit = OrderDetailsCubit(
        GetOrderDetailsUsecase(repo),
        _OrdersUsecase(),
        _UnusedLocation(),
      );
      addTearDown(cubit.close);
      await cubit.getOrderDetails(tripId: 1, orderId: 2);
      await tester.pumpWidget(
        _app(
          BlocProvider.value(
            value: cubit,
            child: const OrderRetryCollectionSheet(
              tripId: 1,
              order: _order,
              salesOrder: 'SO-1',
              orderTotal: 150.75,
            ),
          ),
        ),
      );
      final field = find.byKey(const ValueKey('retry-collection-amount'));
      final submit = find.byType(ElevatedButton);
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
      for (final value in [
        '',
        '-150.75',
        '0',
        '150.751',
        'abc',
        '149.75',
        '151.75',
      ]) {
        await tester.enterText(field, value);
        await tester.pump();
        expect(
          tester.widget<ElevatedButton>(submit).onPressed,
          isNull,
          reason: value,
        );
      }
      await tester.enterText(field, '۱۵۰٫۷۵');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
      await tester.enterText(field, '');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);
      await tester.enterText(field, '۱۵۰٫۷۵');
      await tester.pump();
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.widget<TextField>(field).enabled, isFalse);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(repo.requests, hasLength(1));
      expect(repo.requests.single.collectedAmount, 150.75);
      expect(repo.requests.single.clientOperationId, 'original-operation');
      expect(tester.widget<TextField>(field).enabled, isFalse);
      await cubit.retryCollection(
        tripId: 1,
        orderId: 2,
        clientOperationId: 'original-operation',
        collectedAmount: 150.75,
      );
      expect(repo.requests, hasLength(1));
      repo.pending!.complete(_unconfirmed<dynamic>());
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field).enabled, isFalse);
      expect(find.text('إغلاق وتحديث حالة الطلب'), findsOneWidget);
      expect(repo.requests, hasLength(1));
    },
  );

  testWidgets(
    'direct sale keeps manual input, rejects negative text, and resets after success',
    (tester) async {
      final repo = _PosRepo();
      final cubit = _posCubit(repo);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        _app(
          BlocProvider.value(
            value: cubit,
            child: const DirectSaleAmountField(),
          ),
        ),
      );
      final field = find.byKey(const ValueKey('direct-sale-amount'));
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
      for (final value in [
        '',
        '-150.75',
        '0',
        '150.751',
        'abc',
        '149.75',
        '151.75',
      ]) {
        await tester.enterText(field, value);
        await tester.pump();
        expect(cubit.state.canSubmitPos, isFalse, reason: value);
        await cubit.submitSale();
        expect(repo.requests, isEmpty);
      }
      await tester.enterText(field, '١٥٠٫٧٥');
      await tester.pump();
      expect(cubit.state.canSubmitPos, isTrue);
      await tester.enterText(field, '');
      await tester.pump();
      expect(cubit.state.canSubmitPos, isFalse);
      await tester.enterText(field, '١٥٠٫٧٥');
      await tester.pump();
      await cubit.submitSale();
      expect(repo.requests.single.amountMinor, 15075);
      expect(cubit.state.receipt!.paidAmountMinor, 15075);
      cubit.newSale();
      await tester.pump();
      expect(cubit.amountController.text, isEmpty);
      expect(cubit.state.amountText, isEmpty);
      expect(cubit.state.canSubmitPos, isFalse);
    },
  );

  test('ambiguous delivery retry preserves the original typed amount and operation', () async {
    final repo = _ConfirmRepo()..fail = true;
    final cubit = ConfirmDeliveryCubit(ConfirmDeliveryUsecase(repo));
    addTearDown(cubit.close);
    final flow = _flow(true);
    Future<void> send() => cubit.confirmDelivery(
      tripId: 1,
      orderId: 2,
      items: flow.apiItems,
      extraItems: flow.apiExtraItems,
      collectedAmount: 150.75,
      expectedAmount: 150.75,
    );
    await send();
    expect(cubit.state, isA<ConfirmDeliveryFailure>());
    repo.fail = false;
    await send();
    expect(repo.requests, hasLength(2));
    expect(identical(repo.requests.first, repo.requests.last), isTrue);
    expect(repo.requests.last.collectedAmount, 150.75);
    expect(cubit.state, isA<ConfirmDeliverySuccess>());
  });

  test(
    'ambiguous POS retry preserves the original typed amount and operation',
    () async {
      final repo = _PosRepo()..fail = true;
      final cubit = _posCubit(repo);
      addTearDown(cubit.close);
      cubit.changeAmount('150.75');
      await cubit.submitSale();
      expect(cubit.state.posRetryOriginal, isTrue);
      cubit.changeAmount('200');
      expect(cubit.state.amountText, '150.75');
      repo.fail = false;
      await cubit.submitSale();
      expect(repo.requests, hasLength(2));
      expect(identical(repo.requests.first, repo.requests.last), isTrue);
      expect(repo.requests.last.amountMinor, 15075);
      expect(cubit.state.step, DirectSaleStep.success);
    },
  );
}
