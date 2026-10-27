import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/screens/cancel_delivery_success_screen.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/screens/delivery_success_screen.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/get_order_details_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/update_delivery_location_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/screens/order_details_screen.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_header.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/screens/reschedule_success_screen.dart';

enum _CompletedFlow { reschedule, cancel, delivery }

class _UnusedDetails extends Fake implements GetOrderDetailsUsecase {}

class _UnusedLocation extends Fake
    implements UpdateOrderDeliveryLocationUsecase {}

class _TripOrders extends Fake implements GetTripOrdersUsecase {
  final requests = <int>[];

  @override
  Future<ApiResult<TripOrdersResponse>> call({required int tripId}) async {
    requests.add(tripId);
    return const ApiResult.success(
      TripOrdersResponse(
        success: true,
        data: [
          TripOrderData(
            id: 9,
            salesOrder: 'SO-9',
            stopOrder: 0,
            deliveryStatus: 'PENDING',
            paymentStatus: 'UNPAID',
          ),
          TripOrderData(
            id: 11,
            salesOrder: 'SO-11',
            stopOrder: 1,
            deliveryStatus: 'RESCHEDULED',
            paymentStatus: 'UNPAID',
          ),
          TripOrderData(
            id: 13,
            salesOrder: 'SO-13',
            stopOrder: 3,
            deliveryStatus: 'PENDING',
            paymentStatus: 'UNPAID',
          ),
          TripOrderData(
            id: 12,
            salesOrder: 'SO-12',
            stopOrder: 2,
            deliveryStatus: 'PENDING',
            paymentStatus: 'UNPAID',
          ),
        ],
      ),
    );
  }
}

class _DetailsCubit extends OrderDetailsCubit {
  _DetailsCubit(this.requests, {required this.loading})
    : super(_UnusedDetails(), _TripOrders(), _UnusedLocation());

  final List<({int tripId, int orderId})> requests;
  final bool loading;

  @override
  Future<void> getOrderDetails({
    required int tripId,
    required int orderId,
  }) async {
    requests.add((tripId: tripId, orderId: orderId));
    emit(loading ? OrderDetailsLoadingState() : OrderDetailsFailureState(null));
  }
}

class _NavigationFixture {
  _NavigationFixture({
    this.flow = _CompletedFlow.reschedule,
    bool loading = false,
  }) {
    getIt.registerSingleton<GetTripOrdersUsecase>(orders);
    getIt.registerFactory<OrderDetailsCubit>(
      () => _DetailsCubit(detailsRequests, loading: loading),
    );
    router = GoRouter(
      initialLocation: RoutesNames.layout,
      routes: [
        GoRoute(
          name: RoutesNames.layout,
          path: RoutesNames.layout,
          builder: (_, state) => const Scaffold(body: Text('trip-orders')),
        ),
        GoRoute(
          path: '/areas',
          builder: (_, state) => const Scaffold(body: Text('areas-list')),
        ),
        GoRoute(
          name: RoutesNames.orderDetails,
          path: RoutesNames.orderDetails,
          builder: (_, state) {
            final arguments = state.extra! as Map<String, dynamic>;
            return OrderDetailsScreen(
              tripId: arguments['trip_id'] as int,
              orderId: arguments['order_id'] as int,
            );
          },
        ),
        GoRoute(
          path: '/completed',
          builder: (_, state) => switch (flow) {
            _CompletedFlow.reschedule => RescheduleSuccessScreen(
              tripId: 7,
              orderId: 11,
              salesOrder: 'SO-11',
              customerName: 'عميل',
              rescheduledFor: DateTime(2030, 1, 1),
              reason: 'موعد جديد',
            ),
            _CompletedFlow.cancel => const CancelDeliverySuccessScreen(
              tripId: 7,
              orderId: 11,
              salesOrder: 'SO-11',
              customerName: 'عميل',
              reason: 'إلغاء',
            ),
            _CompletedFlow.delivery => const DeliverySuccessScreen(
              flow: DeliveryFlowData(
                tripId: 7,
                orderId: 11,
                salesOrder: 'SO-11',
                customerName: 'عميل',
                items: [],
              ),
              collectedAmount: 100,
              paymentMethod: 'cash',
            ),
          },
        ),
      ],
    );
  }

  final _CompletedFlow flow;
  final orders = _TripOrders();
  final detailsRequests = <({int tripId, int orderId})>[];
  late final GoRouter router;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
    await tester.pumpAndSettle();
  }

  void openDetails({bool push = false}) {
    const arguments = {'trip_id': 7, 'order_id': 11};
    if (push) {
      router.pushNamed(RoutesNames.orderDetails, extra: arguments);
    } else {
      router.goNamed(RoutesNames.orderDetails, extra: arguments);
    }
  }
}

Finder get _backButton => find.descendant(
  of: find.byType(OrderDetailsHeader),
  matching: find.byType(InkWell),
);

void main() {
  setUp(() => getIt.pushNewScope());
  tearDown(() async => getIt.popScope());

  for (final flow in _CompletedFlow.values) {
    testWidgets('back after ${flow.name} then next order returns to the trip', (
      tester,
    ) async {
      final fixture = _NavigationFixture(flow: flow);
      addTearDown(fixture.router.dispose);
      await fixture.pump(tester);
      fixture.openDetails(push: true);
      await tester.pumpAndSettle();
      fixture.router.push('/completed');
      await tester.pumpAndSettle();
      final next = find.widgetWithText(ElevatedButton, 'الطلب التالي');
      await tester.scrollUntilVisible(
        next,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(fixture.orders.requests, [7]);
      expect(fixture.detailsRequests.last, (tripId: 7, orderId: 12));
      expect(fixture.router.canPop(), false);
      await tester.tap(_backButton);
      await tester.pumpAndSettle();
      expect(find.text('trip-orders'), findsOneWidget);
      expect(fixture.router.canPop(), false);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'system back after rescheduling then next order returns to the trip',
    (tester) async {
      final fixture = _NavigationFixture();
      addTearDown(fixture.router.dispose);
      await fixture.pump(tester);
      fixture.openDetails(push: true);
      await tester.pumpAndSettle();
      fixture.router.push('/completed');
      await tester.pumpAndSettle();
      final next = find.widgetWithText(ElevatedButton, 'الطلب التالي');
      await tester.scrollUntilVisible(
        next,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(fixture.router.canPop(), false);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('trip-orders'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final origin in [RoutesNames.layout, '/areas']) {
    testWidgets('header back preserves the previous $origin screen', (
      tester,
    ) async {
      final fixture = _NavigationFixture();
      addTearDown(fixture.router.dispose);
      await fixture.pump(tester);
      fixture.router.go(origin);
      await tester.pumpAndSettle();
      fixture.openDetails(push: true);
      await tester.pumpAndSettle();
      expect(fixture.router.canPop(), true);
      await tester.tap(_backButton);
      await tester.pumpAndSettle();
      expect(fixture.router.routeInformationProvider.value.uri.path, origin);
      expect(
        find.text(origin == '/areas' ? 'areas-list' : 'trip-orders'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('system back preserves a normally pushed details origin', (
    tester,
  ) async {
    final fixture = _NavigationFixture();
    addTearDown(fixture.router.dispose);
    await fixture.pump(tester);
    fixture.router.go('/areas');
    await tester.pumpAndSettle();
    fixture.openDetails(push: true);
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('areas-list'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final systemBack in [false, true]) {
    testWidgets(
      'direct details entry has a safe ${systemBack ? 'system' : 'header'} back',
      (tester) async {
        final fixture = _NavigationFixture();
        addTearDown(fixture.router.dispose);
        await fixture.pump(tester);
        fixture.openDetails();
        await tester.pumpAndSettle();
        expect(fixture.router.canPop(), false);
        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(_backButton);
        }
        await tester.pumpAndSettle();
        expect(find.text('trip-orders'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('back remains available while order details are loading', (
    tester,
  ) async {
    final fixture = _NavigationFixture(loading: true);
    addTearDown(fixture.router.dispose);
    await fixture.pump(tester);
    fixture.openDetails();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(_backButton);
    await tester.pumpAndSettle();
    expect(find.text('trip-orders'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a modal that blocks system back keeps its protection', (
    tester,
  ) async {
    final fixture = _NavigationFixture();
    addTearDown(fixture.router.dispose);
    await fixture.pump(tester);
    fixture.openDetails();
    await tester.pumpAndSettle();
    showDialog<void>(
      context: tester.element(find.byType(OrderDetailsHeader)),
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(content: Text('protected-operation')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('protected-operation'), findsOneWidget);
    expect(
      fixture.router.routeInformationProvider.value.uri.path,
      RoutesNames.orderDetails,
    );
    expect(tester.takeException(), isNull);
  });
}
