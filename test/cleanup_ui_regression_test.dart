import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_theme.dart';
import 'package:storeus_delivery/features/home/data/models/trip_history_response.dart';
import 'package:storeus_delivery/features/home/domain/usecases/get_trip_history_usecase.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/screens/home_screen.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/notifications/data/models/notifications_response.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/data/models/cancel_delivery_request_body.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/domain/usecases/cancel_delivery_usecase.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/cubit/cancel_delivery_cubit.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/widgets/cancel_delivery_sheet.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/trip_order_card.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/confirm_delivery_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/usecases/confirm_delivery_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/confirm_delivery_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/screens/delivery_payment_screen.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/screens/delivery_result_screen.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_address_edit_sheet.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_customer_card.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/current_trip_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/receiving_proof_photo.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/data/models/reschedule_order_request_body.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/domain/usecases/reschedule_order_usecase.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/cubit/reschedule_order_cubit.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/widgets/reschedule_order_sheet.dart';

const _captureKey = ValueKey('cleanup-capture');
const _flow = DeliveryFlowData(
  tripId: 12,
  orderId: 34,
  salesOrder: 'SO-0034',
  customerName: 'متجر الاختبار',
  originalTotal: 100,
  items: [
    DeliveryFlowItem(
      lineId: 'line-1',
      itemCode: 'ITEM-1',
      itemName: 'صنف الاختبار',
      uom: 'قطعة',
      orderedQty: 10,
      selectedQty: 5,
      rate: 10,
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  setUpAll(() async {
    await (FontLoader('cairo')..addFont(
          rootBundle.load(
            'assets/fonts/cairo/Cairo-VariableFont_slnt,wght.ttf',
          ),
        ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  tearDown(() => getIt.reset());

  testWidgets('home rebuilds preserve provider instances and request counts', (
    tester,
  ) async {
    final trip = _CurrentTripFixture();
    final orders = _OrdersFixture();
    final history = _HistoryFixture();
    getIt.registerFactory<HomeCubit>(() => HomeCubit(trip, orders));
    getIt.registerFactory<HomeHistoryCubit>(() => HomeHistoryCubit(history));
    final layout = LayoutCubit();
    final notifications = NotificationsCubit(
      _UnusedNotifications(),
      _UnusedMarkRead(),
    );
    addTearDown(layout.close);
    addTearDown(notifications.close);

    await _pump(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: layout),
          BlocProvider.value(value: notifications),
        ],
        child: const HomeScreen(),
      ),
    );
    final owner = tester.element(find.byType(HomeScreen)).read<LayoutCubit>();
    expect(owner, same(layout));
    expect([trip.calls, orders.calls, history.calls], [1, 1, 1]);
    await _capture(tester, 'home');
    tester.view.physicalSize = const Size(400, 844);
    await tester.pumpAndSettle();
    expect([trip.calls, orders.calls, history.calls], [1, 1, 1]);
    expect(tester.takeException(), isNull);
    await _unmount(tester);
  });

  for (final status in TripOrderStatus.values) {
    testWidgets('order card preserves ${status.name} presentation', (
      tester,
    ) async {
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: TripOrderCard(
              tripID: 12,
              order: TripOrderModel(
                id: 'SO-0034',
                apiId: 34,
                stopNumber: 2,
                customerName: 'متجر الاختبار',
                address: 'عنوان الاختبار',
                phoneNumber: '01000000000',
                orderAmount: 100,
                status: status,
                latitude: 30,
                longitude: 31,
              ),
            ),
          ),
        ),
      );
      expect(find.text('متجر الاختبار'), findsOneWidget);
      await _capture(tester, 'order-${status.name}');
      await _unmount(tester);
    });
  }

  testWidgets(
    'receiving photo placeholder does not approve or capture on rebuild',
    (tester) async {
      const channel = MethodChannel('google_mlkit_face_detector');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (_) async => null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      var approvals = 0;
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ReceivingProofPhoto(
              tripNumber: 'TRIP-12',
              onPhotoApprovalChanged: (_) => approvals++,
            ),
          ),
        ),
      );
      await _capture(tester, 'receiving-photo');
      tester.view.physicalSize = const Size(400, 844);
      await tester.pumpAndSettle();
      expect(approvals, 0);
      expect(tester.takeException(), isNull);
      await _unmount(tester);
    },
  );

  testWidgets(
    'address fields keep their controllers and user input after rebuild',
    (tester) async {
      await _pump(
        tester,
        const Scaffold(
          body: OrderAddressEditSheet(
            tripId: 12,
            orderId: 34,
            location: OrderCustomerLocation(
              name: 'متجر الاختبار',
              phone: '01000000000',
              address: 'عنوان الاختبار',
            ),
          ),
        ),
      );
      await _capture(tester, 'address-editor');
      final field = find.byType(TextField).first;
      await tester.ensureVisible(field);
      await tester.enterText(field, 'عنوان تم تعديله');
      final controller = tester.widget<TextField>(field).controller;
      tester.view.physicalSize = const Size(400, 844);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field).controller, same(controller));
      expect(controller?.text, 'عنوان تم تعديله');
      await _unmount(tester);
    },
  );

  testWidgets(
    'payment accepts Arabic amounts and cancelling review sends no request',
    (tester) async {
      final usecase = _ConfirmFixture();
      final cubit = ConfirmDeliveryCubit(usecase);
      addTearDown(cubit.close);
      await _pump(
        tester,
        BlocProvider.value(
          value: cubit,
          child: const DeliveryPaymentScreen(flow: _flow),
        ),
      );
      final strings = _strings(tester, DeliveryPaymentScreen);
      await _capture(tester, 'payment');
      final field = find.byType(TextField);
      await tester.ensureVisible(field);
      await tester.enterText(field, '٤٩');
      await tester.pumpAndSettle();
      expect(
        _confirmationButton(tester, strings.delivery_confirm_button).onPressed,
        isNull,
      );
      await tester.enterText(field, '٥٠٫٠٠');
      await tester.pumpAndSettle();
      final controller = tester.widget<TextField>(field).controller;
      tester.view.physicalSize = const Size(400, 844);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field).controller, same(controller));
      expect(
        _confirmationButton(tester, strings.delivery_confirm_button).onPressed,
        isNotNull,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, strings.delivery_confirm_button),
      );
      await tester.tap(
        find.widgetWithText(ElevatedButton, strings.delivery_confirm_button),
      );
      await tester.pumpAndSettle();
      expect(find.text(strings.delivery_confirmation_summary), findsOneWidget);
      await _capture(tester, 'payment-review');
      await tester.tap(find.widgetWithText(OutlinedButton, strings.back));
      await tester.pumpAndSettle();
      expect(usecase.calls, 0);
      expect(controller?.text, '٥٠٫٠٠');
      await _unmount(tester);
    },
  );

  testWidgets(
    'payment confirmation preserves the request and retry identifier',
    (tester) async {
      final usecase = _ConfirmFixture();
      final cubit = ConfirmDeliveryCubit(usecase);
      addTearDown(cubit.close);
      await _pump(
        tester,
        BlocProvider.value(
          value: cubit,
          child: const DeliveryPaymentScreen(flow: _flow),
        ),
      );
      final strings = _strings(tester, DeliveryPaymentScreen);
      final field = find.byType(TextField);
      await tester.ensureVisible(field);
      for (final invalid in ['-50', '50.001', 'abc', '49']) {
        await tester.enterText(field, invalid);
        await tester.pumpAndSettle();
        expect(
          _confirmationButton(
            tester,
            strings.delivery_confirm_button,
          ).onPressed,
          isNull,
        );
      }
      await tester.enterText(field, '۵۰٫۰۰');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(
          find.widgetWithText(ElevatedButton, strings.delivery_confirm_button),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find
              .widgetWithText(ElevatedButton, strings.delivery_confirm_button)
              .last,
        );
        await tester.pumpAndSettle();
        expect(usecase.calls, attempt + 1);
      }
      expect(usecase.lastTripId, 12);
      expect(usecase.lastOrderId, 34);
      final bodies = usecase.bodies;
      expect(bodies.last.toJson(), {
        'client_operation_id': bodies.first.clientOperationId,
        'items': [
          {'line_id': 'line-1', 'item_code': 'ITEM-1', 'qty': 5},
        ],
        'extra_items': [],
        'collected_amount': 50,
        'payment_method': 'cash',
      });
      expect(bodies.first.clientOperationId, isNotEmpty);
      expect(tester.widget<TextField>(field).controller?.text, '۵۰٫۰۰');
      expect(find.text('fixture-error'), findsOneWidget);
      await _unmount(tester);
    },
  );

  for (final variant in ['missing', 'address', 'coordinates', 'complete']) {
    testWidgets('customer card preserves $variant location presentation', (
      tester,
    ) async {
      final hasAddress = variant == 'address' || variant == 'complete';
      final hasCoordinates = variant == 'coordinates' || variant == 'complete';
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: OrderCustomerCard(
                tripId: 12,
                orderId: 34,
                location: OrderCustomerLocation(
                  name: 'متجر الاختبار',
                  phone: '01000000000',
                  address: hasAddress ? 'عنوان الاختبار' : '',
                  latitude: hasCoordinates ? 30.1 : null,
                  longitude: hasCoordinates ? 31.2 : null,
                ),
              ),
            ),
          ),
        ),
      );
      final strings = _strings(tester, OrderCustomerCard);
      final status = hasAddress && hasCoordinates
          ? strings.order_address_defined
          : hasAddress
          ? strings.order_address_only
          : hasCoordinates
          ? strings.order_gps_only
          : strings.order_address_undefined;
      expect(find.text(status), findsOneWidget);
      expect(find.text('متجر الاختبار'), findsOneWidget);
      expect(
        find.text(strings.order_set_location),
        hasAddress && hasCoordinates ? findsNothing : findsOneWidget,
      );
      await _capture(tester, 'customer-$variant');
      await _unmount(tester);
    });
  }

  testWidgets(
    'partial delivery result keeps quantities and financial presentation',
    (tester) async {
      await _pump(tester, const DeliveryResultScreen(flow: _flow));
      final strings = _strings(tester, DeliveryResultScreen);
      expect(find.text(strings.delivery_partial_draft), findsOneWidget);
      expect(find.text(strings.delivery_ordered), findsOneWidget);
      expect(find.text(strings.delivery_selected), findsOneWidget);
      expect(find.text(strings.delivery_not_delivered), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('5'), findsNWidgets(2));
      expect(find.text(strings.order_details_original_total), findsOneWidget);
      expect(find.text(strings.delivery_estimated_total), findsOneWidget);
      expect(find.text('100 ${strings.egp_currency}'), findsOneWidget);
      expect(find.text('50 ${strings.egp_currency}'), findsOneWidget);
      expect(
        find.text(strings.delivery_partial_reason_required),
        findsOneWidget,
      );
      await _capture(tester, 'delivery-result');
      await _unmount(tester);
    },
  );

  testWidgets(
    'reschedule reason and notes survive a rebuild without a request',
    (tester) async {
      final usecase = _RescheduleFixture();
      final cubit = RescheduleOrderCubit(usecase);
      addTearDown(cubit.close);
      await _pump(
        tester,
        BlocProvider.value(
          value: cubit,
          child: const Scaffold(
            body: RescheduleOrderSheet(
              tripId: 12,
              orderId: 34,
              salesOrder: 'SO-0034',
              customerName: 'متجر الاختبار',
              address: 'عنوان الاختبار',
            ),
          ),
        ),
      );
      await _capture(tester, 'reschedule');
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'سبب آخر'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'سبب آخر'));
      await tester.pumpAndSettle();
      final field = find.byType(TextField).first;
      await tester.ensureVisible(field);
      await tester.enterText(field, 'سبب الاختبار');
      final controller = tester.widget<TextField>(field).controller;
      tester.view.physicalSize = const Size(400, 844);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field).controller, same(controller));
      expect(controller?.text, 'سبب الاختبار');
      expect(usecase.calls, 0);
      await _unmount(tester);
    },
  );

  testWidgets('cancellation reason survives cancelling the confirmation', (
    tester,
  ) async {
    final usecase = _CancelFixture();
    final cubit = CancelDeliveryCubit(usecase);
    addTearDown(cubit.close);
    await _pump(
      tester,
      BlocProvider.value(
        value: cubit,
        child: const Scaffold(
          body: CancelDeliverySheet(
            tripId: 12,
            orderId: 34,
            salesOrder: 'SO-0034',
            customerName: 'متجر الاختبار',
          ),
        ),
      ),
    );
    final strings = _strings(tester, CancelDeliverySheet);
    await _capture(tester, 'cancellation');
    final reason = find.widgetWithText(ChoiceChip, strings.cancel_reason_other);
    await tester.ensureVisible(reason);
    await tester.tap(reason);
    await tester.pumpAndSettle();
    final field = find.byType(TextField).first;
    await tester.ensureVisible(field);
    await tester.enterText(field, 'سبب الاختبار');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final button = find.byType(ElevatedButton).last;
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text(strings.cancel_delivery_confirm_title), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, strings.back));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'سبب الاختبار',
    );
    expect(usecase.calls, 0);
    await _unmount(tester);
  });

  testWidgets('confirmed cancellation preserves its reason-only request', (
    tester,
  ) async {
    final usecase = _CancelFixture();
    final cubit = CancelDeliveryCubit(usecase);
    addTearDown(cubit.close);
    await _pump(
      tester,
      BlocProvider.value(
        value: cubit,
        child: const Scaffold(
          body: CancelDeliverySheet(
            tripId: 12,
            orderId: 34,
            salesOrder: 'SO-0034',
            customerName: 'متجر الاختبار',
          ),
        ),
      ),
    );
    final strings = _strings(tester, CancelDeliverySheet);
    final reason = find.widgetWithText(ChoiceChip, strings.cancel_reason_other);
    await tester.ensureVisible(reason);
    await tester.tap(reason);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, '  سبب الاختبار  ');
    await tester.ensureVisible(find.byType(TextField).last);
    await tester.enterText(find.byType(TextField).last, 'ملاحظات محلية فقط');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(ElevatedButton).last);
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
    expect(usecase.calls, 1);
    expect(usecase.lastTripId, 12);
    expect(usecase.lastOrderId, 34);
    expect(usecase.lastBody?.toJson(), {
      'outcome': 'CANCELLED',
      'reason': 'سبب الاختبار',
    });
    expect(find.text('fixture-error'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      '  سبب الاختبار  ',
    );
    await _unmount(tester);
  });
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

AppLocalizations _strings(WidgetTester tester, Type type) =>
    AppLocalizations.of(tester.element(find.byType(type)))!;

ElevatedButton _confirmationButton(WidgetTester tester, String label) =>
    tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, label));

Future<void> _capture(WidgetTester tester, String name) async {
  const phase = String.fromEnvironment('CLEANUP_CAPTURE_PHASE');
  if (phase.isEmpty) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final bytes = data!.buffer.asUint8List();
    const base = 'build/cleanup_audit_20261011_140606/visuals';
    final output = File('$base/$phase/$name.png');
    await output.parent.create(recursive: true);
    await output.writeAsBytes(bytes);
    if (phase == 'after') {
      expect(
        bytes,
        orderedEquals(await File('$base/before/$name.png').readAsBytes()),
        reason: '$name changed visually',
      );
    }
  });
}

class _CurrentTripFixture implements CurrentTripUsecase {
  int calls = 0;
  @override
  Future<ApiResult<CurrentTripResponse>> call() async {
    calls++;
    return const ApiResult.success(
      CurrentTripResponse(
        success: true,
        data: CurrentTripData(
          id: 12,
          number: 'TRIP-12',
          status: 'ACTIVE',
          acceptance: TripAcceptance(status: 'ACCEPTED'),
          ordersSummary: TripOrdersSummary(total: 0),
        ),
      ),
    );
  }
}

class _OrdersFixture implements GetTripOrdersUsecase {
  int calls = 0;
  @override
  Future<ApiResult<TripOrdersResponse>> call({required int tripId}) async {
    calls++;
    return const ApiResult.success(TripOrdersResponse(success: true, data: []));
  }
}

class _HistoryFixture implements GetTripHistoryUsecase {
  int calls = 0;
  @override
  Future<ApiResult<TripHistoryResponse>> call() async {
    calls++;
    return const ApiResult.success(
      TripHistoryResponse(success: true, data: []),
    );
  }
}

class _UnusedNotifications implements GetNotificationsUsecase {
  @override
  Future<ApiResult<NotificationsResponse>> call() =>
      throw StateError('Unexpected notification request');
}

class _UnusedMarkRead implements MarkNotificationAsReadUsecase {
  @override
  Future<ApiResult<dynamic>> call({required int notificationId}) =>
      throw StateError('Unexpected mark-as-read request');
}

class _ConfirmFixture implements ConfirmDeliveryUsecase {
  int calls = 0;
  int? lastTripId;
  int? lastOrderId;
  final bodies = <ConfirmDeliveryRequestBody>[];
  @override
  Future<ApiResult<dynamic>> call({
    required int tripId,
    required int orderId,
    required ConfirmDeliveryRequestBody body,
  }) async {
    calls++;
    lastTripId = tripId;
    lastOrderId = orderId;
    bodies.add(body);
    return const ApiResult.success({
      'success': false,
      'message': 'fixture-error',
    });
  }
}

class _RescheduleFixture implements RescheduleOrderUsecase {
  int calls = 0;
  @override
  Future<ApiResult<dynamic>> call({
    required int tripId,
    required int orderId,
    required RescheduleOrderRequestBody body,
  }) async {
    calls++;
    return const ApiResult.success({
      'success': false,
      'message': 'fixture-error',
    });
  }
}

class _CancelFixture implements CancelDeliveryUsecase {
  int calls = 0;
  int? lastTripId;
  int? lastOrderId;
  CancelDeliveryRequestBody? lastBody;
  @override
  Future<ApiResult<dynamic>> call({
    required int tripId,
    required int orderId,
    required CancelDeliveryRequestBody body,
  }) async {
    calls++;
    lastTripId = tripId;
    lastOrderId = orderId;
    lastBody = body;
    return const ApiResult.success({
      'success': false,
      'message': 'fixture-error',
    });
  }
}
