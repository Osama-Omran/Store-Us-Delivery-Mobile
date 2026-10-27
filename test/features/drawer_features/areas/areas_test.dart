import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/models/areas_route_data.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/screens/areas_screen.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_stop_card.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/current_trip_usecase.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/screens/trip_map_screen.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/widgets/trip_map_stop_sheet.dart';
import 'package:storeus_delivery/features/trip/trip_map/services/driver_location_service.dart';
import 'package:storeus_delivery/features/trip/trip_map/services/route_navigation_launcher.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

const trip = CurrentTripData(
  id: 27,
  number: 'TRIP-0027',
  status: 'IN_PROGRESS',
  acceptance: TripAcceptance(status: 'ACCEPTED'),
  warehouse: TripWarehouse(
    name: 'مخزن القاهرة',
    latitude: '30.1',
    longitude: '31.2',
  ),
);

TripOrderModel order(
  int number, {
  TripOrderStatus status = TripOrderStatus.pending,
  double? lat = 30,
  double? lng = 31,
  String? address,
  int? apiId,
}) => TripOrderModel(
  id: 'SO-$number',
  apiId: apiId ?? number,
  stopNumber: number,
  customerName: 'عميل $number',
  address: address ?? 'عنوان $number',
  phoneNumber: '',
  orderAmount: 100,
  status: status,
  latitude: lat,
  longitude: lng,
);

class _UnusedCurrentTrip extends Fake implements CurrentTripUsecase {}

class _UnusedTripOrders extends Fake implements GetTripOrdersUsecase {}

class _TripCubit extends TripTabCubit {
  _TripCubit(TripTabState initial)
    : super(_UnusedCurrentTrip(), _UnusedTripOrders()) {
    emit(initial);
  }
  int refreshes = 0;
  @override
  Future<void> getCurrentTrip() async {
    refreshes++;
  }

  void show(TripTabState state) => emit(state);
}

class _Launcher extends RouteNavigationLauncher {
  final sections = <TripRouteSection>[];
  bool result = true;
  bool throws = false;
  @override
  Future<bool> openRouteSection(TripRouteSection section) async {
    if (throws) throw StateError('launch failed');
    sections.add(section);
    return result;
  }
}

class _NoLocation extends DriverLocationService {
  @override
  Future<LatLng> getCurrentLocation() async =>
      throw const LocationNotReadyException();
}

class _MapsPlatform extends GoogleMapsFlutterPlatform {
  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) => const SizedBox.expand();
}

Future<void> _pumpAreas(
  WidgetTester tester,
  _TripCubit cubit, {
  _Launcher? launcher,
  VoidCallback? onBack,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<TripTabCubit>.value(
        value: cubit,
        child: Scaffold(
          body: AreasScreen(
            onBack: onBack ?? () {},
            navigationLauncher: launcher ?? _Launcher(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  test(
    'presentation follows distribution order and existing handled rules',
    () {
      final route = AreasRouteData(
        trip: trip,
        orders: [
          order(7, status: TripOrderStatus.unknown),
          order(3, status: TripOrderStatus.rescheduled),
          order(2, status: TripOrderStatus.partiallyDelivered),
          order(4, status: TripOrderStatus.cancelled),
          order(1, status: TripOrderStatus.delivered),
          order(6),
          order(5, lat: null),
        ],
      );
      expect(route.orders.map((o) => o.stopNumber), [1, 2, 3, 4, 5, 6, 7]);
      expect(route.finished, 4);
      expect(route.remaining, 3);
      expect(route.nextStop?.stopNumber, 5);
      expect(route.missingCoordinates, 1);
      expect(route.mapStops.length, 6);
      expect(route.total, 7);
      expect(route.warehouseLocation, const LatLng(30.1, 31.2));
      expect(route.mapStops.any((stop) => stop.id == '5'), false);
    },
  );

  test('invalid GPS is excluded from map, never from orders or counters', () {
    final route = AreasRouteData(
      trip: trip,
      orders: [
        order(1, lat: double.nan),
        order(2, lng: 181),
        order(3),
      ],
    );
    expect(route.mapStops.length, 1);
    expect(route.total, 3);
    expect(route.remaining, 3);
    expect(route.missingCoordinates, 2);
  });

  test('warehouse coordinates must be finite and in range', () {
    for (final lat in ['invalid', 'NaN', 'Infinity', '91']) {
      final route = AreasRouteData(
        trip: CurrentTripData(
          id: 1,
          number: '',
          status: '',
          warehouse: TripWarehouse(latitude: lat, longitude: '30'),
        ),
        orders: [],
      );
      expect(route.warehouseLocation, isNull);
    }
  });

  test('empty and completed trips have no next stop', () {
    expect(AreasRouteData(trip: trip, orders: []).nextStop, isNull);
    expect(
      AreasRouteData(
        trip: trip,
        orders: [order(1, status: TripOrderStatus.delivered)],
      ).nextStop,
      isNull,
    );
  });

  test('Google route sections preserve all stops and shared boundaries', () {
    final sections = RouteNavigationLauncher.buildRouteSections(
      orders: List.generate(12, (i) => order(12 - i, lat: (12 - i).toDouble())),
      warehouse: const LatLng(30.1, 31.2),
    );
    expect(sections.length, 3);
    expect(sections.map((s) => s.firstStop), [1, 5, 9]);
    expect(sections.map((s) => s.lastStop), [4, 8, 12]);
    expect(sections.first.uri.queryParameters['origin'], '30.1,31.2');
    for (var index = 0; index < sections.length; index++) {
      final parameters = sections[index].uri.queryParameters;
      expect(parameters['api'], '1');
      expect(parameters['travelmode'], 'driving');
      expect(parameters['waypoints']!.split('|').length, 3);
      expect(parameters.containsKey('dir_action'), false);
      if (index > 0) {
        expect(
          parameters['origin'],
          sections[index - 1].uri.queryParameters['destination'],
        );
      }
    }
  });

  test('Google route encodes supplied addresses when GPS is unavailable', () {
    final sections = RouteNavigationLauncher.buildRouteSections(
      orders: [order(1, lat: null, address: 'القاهرة، شارع & ١')],
    );
    expect(
      sections.single.uri.queryParameters['destination'],
      'القاهرة، شارع & ١',
    );
    expect(sections.single.uri.queryParameters.containsKey('origin'), false);
    expect(sections.single.uri.queryParameters.containsKey('waypoints'), false);
  });

  test('export rejects any missing location rather than dropping a stop', () {
    expect(
      () => RouteNavigationLauncher.buildRouteSections(
        orders: [
          order(1),
          order(2, lat: null, address: ' '),
        ],
      ),
      throwsA(isA<RouteLocationUnavailableException>()),
    );
    expect(RouteNavigationLauncher.buildRouteSections(orders: []), isEmpty);
  });

  test('long URLs split sooner and cannot exceed the Google URL limit', () {
    final sections = RouteNavigationLauncher.buildRouteSections(
      orders: List.generate(
        5,
        (i) => order(i + 1, lat: null, address: '${'أ' * 110}$i'),
      ),
    );
    expect(sections.length, greaterThan(1));
    expect(sections.every((s) => s.uri.toString().length <= 2048), true);
    expect(sections.last.lastStop, 5);
    expect(
      () => RouteNavigationLauncher.buildRouteSections(
        orders: [order(1, lat: null, address: 'أ' * 1000)],
      ),
      throwsA(isA<RouteLocationUnavailableException>()),
    );
  });

  test(
    'drawer feature restores the previously selected navigation tab',
    () async {
      final layout = LayoutCubit();
      layout.selectTap(0);
      layout.openAreas();
      expect(layout.isAreas, true);
      expect(layout.selectedTap, 3);
      expect(layout.currentScreen, isA<AreasScreen>());
      layout.closeDrawerFeature();
      expect(layout.selectedTap, 0);
      expect(layout.isDrawerFeatureOpen, false);
      layout.selectTap(2);
      layout.openAreas();
      layout.openReports();
      layout.closeDrawerFeature();
      expect(layout.selectedTap, 2);
      await layout.close();
    },
  );

  testWidgets('entry refreshes and displays actual warehouse and next stop', (
    tester,
  ) async {
    final cubit = _TripCubit(
      TripTabSuccessState(
        trip,
        ordersStatus: TripOrdersStatus.success,
        orders: [
          order(2),
          order(1, status: TripOrderStatus.delivered),
        ],
      ),
    );
    addTearDown(cubit.close);
    await _pumpAreas(tester, cubit);
    expect(cubit.refreshes, 1);
    expect(find.text('مخزن القاهرة'), findsOneWidget);
    final cards = tester
        .widgetList<AreasStopCard>(find.byType(AreasStopCard))
        .toList();
    expect(cards.first.order.stopNumber, 1);
    expect(cards.first.isNext, false);
    expect(cards.last.isNext, true);
    await tester.tap(find.byTooltip('تحديث المسار'));
    await tester.pump();
    expect(cubit.refreshes, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading, no trip, failure and acceptance-required states', (
    tester,
  ) async {
    final cubit = _TripCubit(TripTabLoadingState());
    addTearDown(cubit.close);
    await _pumpAreas(tester, cubit);
    expect(find.byType(CustomLoadingIndicator), findsOneWidget);
    cubit.show(TripTabEmptyState());
    await tester.pumpAndSettle();
    expect(find.text('لا توجد رحلة حالية مرتبطة بحسابك.'), findsOneWidget);
    cubit.show(TripTabFailureState(null));
    await tester.pumpAndSettle();
    expect(find.text('تعذر تحميل مسار الرحلة. حاول مرة أخرى.'), findsOneWidget);
    cubit.show(
      TripTabSuccessState(
        const CurrentTripData(
          id: 27,
          number: 'TRIP-0027',
          status: 'PENDING',
          acceptance: TripAcceptance(status: 'PENDING'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('يجب تأكيد استلام الشاحنة و البضاعة أولاً'),
      findsOneWidget,
    );
    expect(find.byType(AreasStopCard), findsNothing);
  });

  testWidgets(
    'orders failure does not become an empty route or zero counters',
    (tester) async {
      final cubit = _TripCubit(
        TripTabSuccessState(trip, ordersStatus: TripOrdersStatus.failure),
      );
      addTearDown(cubit.close);
      await _pumpAreas(tester, cubit);
      expect(
        find.text('تعذر تحميل مسار الرحلة. حاول مرة أخرى.'),
        findsOneWidget,
      );
      expect(find.text('لا توجد محطات في الرحلة الحالية'), findsNothing);
      cubit.show(
        TripTabSuccessState(trip, ordersStatus: TripOrdersStatus.success),
      );
      await tester.pumpAndSettle();
      expect(find.text('لا توجد محطات في الرحلة الحالية'), findsOneWidget);
    },
  );

  testWidgets('missing GPS remains visible and empty map can return to list', (
    tester,
  ) async {
    final cubit = _TripCubit(
      TripTabSuccessState(
        trip,
        ordersStatus: TripOrdersStatus.success,
        orders: [order(1, lat: null)],
      ),
    );
    addTearDown(cubit.close);
    await _pumpAreas(tester, cubit);
    expect(find.text('عميل 1'), findsOneWidget);
    await tester.tap(find.text('عميل 1'));
    await tester.pump();
    expect(find.text('موقع المحطة غير متاح على الخريطة'), findsWidgets);
    await tester.tap(find.text('خريطة'));
    await tester.pump();
    expect(
      find.text('لا توجد محطات بإحداثيات لعرضها على الخريطة'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('رجوع'));
    await tester.pump();
    expect(find.text('عميل 1'), findsOneWidget);
  });

  testWidgets('route export reports launch failures', (tester) async {
    final cubit = _TripCubit(
      TripTabSuccessState(
        trip,
        ordersStatus: TripOrdersStatus.success,
        orders: [order(1)],
      ),
    );
    final launcher = _Launcher()..result = false;
    addTearDown(cubit.close);
    await _pumpAreas(tester, cubit, launcher: launcher);
    await tester.scrollUntilVisible(
      find.text('فتح المسار في Google Maps'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('فتح المسار في Google Maps'));
    await tester.pump();
    expect(launcher.sections, hasLength(1));
    expect(find.text('تعذر فتح خرائط Google. حاول مرة أخرى.'), findsOneWidget);
  });

  testWidgets(
    'long route allows selecting a section without launching others',
    (tester) async {
      final cubit = _TripCubit(
        TripTabSuccessState(
          trip,
          ordersStatus: TripOrdersStatus.success,
          orders: List.generate(12, (i) => order(i + 1)),
        ),
      );
      final launcher = _Launcher();
      addTearDown(cubit.close);
      await _pumpAreas(tester, cubit, launcher: launcher);
      await tester.scrollUntilVisible(
        find.text('فتح المسار في Google Maps'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('فتح المسار في Google Maps'));
      await tester.pumpAndSettle();
      expect(launcher.sections, isEmpty);
      await tester.tap(find.text('الجزء 2 من 3'));
      await tester.pumpAndSettle();
      expect(launcher.sections.single.firstStop, 5);
      expect(launcher.sections.single.lastStop, 8);
    },
  );

  testWidgets('order details receive numeric IDs and refresh on return', (
    tester,
  ) async {
    final cubit = _TripCubit(
      TripTabSuccessState(
        trip,
        ordersStatus: TripOrdersStatus.success,
        orders: [order(1, apiId: 91)],
      ),
    );
    Map<String, dynamic>? arguments;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, state) => BlocProvider<TripTabCubit>.value(
            value: cubit,
            child: Scaffold(body: AreasScreen(onBack: () {})),
          ),
        ),
        GoRoute(
          path: RoutesNames.orderDetails,
          builder: (context, state) {
            arguments = state.extra as Map<String, dynamic>;
            return Scaffold(
              body: TextButton(
                onPressed: () => context.pop(),
                child: const Text('return'),
              ),
            );
          },
        ),
      ],
    );
    addTearDown(cubit.close);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('عرض الطلب'));
    await tester.pumpAndSettle();
    expect(arguments, {'trip_id': 27, 'order_id': 91});
    await tester.tap(find.text('return'));
    await tester.pumpAndSettle();
    expect(cubit.refreshes, 2);
  });

  testWidgets('map reconciles selected order and uses full trip count', (
    tester,
  ) async {
    // Keep the Flutter markers, callbacks and sheet; replace native rendering.
    final originalPlatform = GoogleMapsFlutterPlatform.instance;
    GoogleMapsFlutterPlatform.instance = _MapsPlatform();
    addTearDown(() => GoogleMapsFlutterPlatform.instance = originalPlatform);
    final first = order(1, status: TripOrderStatus.delivered);
    final next = order(2);
    TripOrderModel? selected;
    Widget map(List<TripOrderModel> orders, {String? initial = '2'}) =>
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TripMapView(
              tripId: trip.number,
              tripApiId: trip.id,
              stops: orders
                  .map(
                    (o) => TripMapStop(
                      order: o,
                      location: LatLng(o.latitude!, o.longitude!),
                    ),
                  )
                  .toList(),
              totalStops: 3,
              nextStopId: '2',
              initialStopId: initial,
              onBack: () {},
              onStopSelected: (order) => selected = order,
              locationService: _NoLocation(),
            ),
          ),
        );
    await tester.pumpWidget(map([first, next]));
    await tester.pump();
    var sheet = tester.widget<TripMapStopSheet>(find.byType(TripMapStopSheet));
    expect(sheet.stop.order, same(next));
    expect(sheet.totalStops, 3);
    expect(sheet.isNextStop, true);
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump();
      if (tester.widget<GoogleMap>(find.byType(GoogleMap)).markers.length ==
          2) {
        break;
      }
    }
    final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(googleMap.markers, hasLength(2));
    googleMap.markers
        .singleWhere((marker) => marker.markerId.value == '1')
        .onTap!();
    await tester.pump();
    expect(selected, same(first));
    expect(
      tester.widget<TripMapStopSheet>(find.byType(TripMapStopSheet)).stop.order,
      same(first),
    );
    // Removing the selected order chooses a remaining stop rather than keeping stale data.
    await tester.pumpWidget(map([next]));
    await tester.pump();
    expect(
      tester.widget<TripMapStopSheet>(find.byType(TripMapStopSheet)).stop.order,
      same(next),
    );
    await tester.pumpWidget(map([first]));
    await tester.pump();
    sheet = tester.widget<TripMapStopSheet>(find.byType(TripMapStopSheet));
    expect(sheet.stop.order, same(first));
    expect(sheet.isNextStop, false);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('list supports a narrow display and larger Arabic text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cubit = _TripCubit(
      TripTabSuccessState(
        trip,
        ordersStatus: TripOrdersStatus.success,
        orders: [order(1)],
      ),
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: BlocProvider<TripTabCubit>.value(
          value: cubit,
          child: Scaffold(body: AreasScreen(onBack: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byType(AreasStopCard),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
