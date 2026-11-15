import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_current_trip_section.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/current_trip_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/repo/trip_orders_repo_interface.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_order_navigation.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/current_trip_summary_card.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/repo/receive_trip_repo_interface.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/current_trip_usecase.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

Map<String, dynamic> _tripJson() => {
  'id': 1,
  'number': 'TRIP-1',
  'status': 'IN_PROGRESS',
  'vehicle': {'id': 1, 'name': 'Vehicle'},
  'warehouse': {'id': 1, 'name': 'Warehouse'},
  'driver': {'id': 1, 'name': 'Driver'},
  'orders_summary': {'total': 0},
  'acceptance': {'status': 'ACCEPTED'},
};

class _TripRepo extends Fake implements ReceiveTripRepoInterface {
  num? totalCollected;
  int calls = 0;

  @override
  Future<ApiResult<CurrentTripResponse>> getCurrentTrip() async {
    calls++;
    return ApiResult.success(
      CurrentTripResponse.fromJson({
        'success': true,
        'data': {..._tripJson(), 'total_collected': totalCollected},
      }),
    );
  }
}

class _OrdersRepo extends Fake implements TripOrdersRepoInterface {
  int calls = 0;

  @override
  Future<ApiResult<TripOrdersResponse>> getTripOrders({
    required int tripId,
  }) async {
    calls++;
    return const ApiResult.success(TripOrdersResponse(success: true, data: []));
  }
}

void main() {
  for (final raw in [150.75, 0, '150.75', null, '', 'invalid']) {
    test('parses and maps total_collected=$raw', () {
      final response = CurrentTripResponse.fromJson({
        'success': true,
        'data': {..._tripJson(), 'total_collected': raw},
      });
      final expected = raw == 150.75 || raw == '150.75'
          ? 150.75
          : raw == 0
          ? 0
          : null;
      final trip = response.data!;
      expect(trip.totalCollected, expected);
      expect(CurrentTripModel.fromApi(trip).collectedAmount, expected);
      expect(response.toJson()['data']['total_collected'], expected);
    });
  }

  test('older responses without total_collected remain supported', () {
    final trip = CurrentTripData.fromJson(_tripJson());
    expect(trip.totalCollected, isNull);
    expect(CurrentTripModel.fromApi(trip).collectedAmount, isNull);
  });

  for (final amount in <num?>[150.75, 0, null]) {
    testWidgets('both collection cards show the API amount $amount', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = _TripRepo()..totalCollected = amount;
      final homeCubit = HomeCubit(
        CurrentTripUsecase(repo),
        GetTripOrdersUsecase(_OrdersRepo()),
      );
      addTearDown(homeCubit.close);
      await homeCubit.getCurrentTrip();
      final trip = CurrentTripData.fromJson({
        ..._tripJson(),
        'total_collected': amount,
      });

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: homeCubit,
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const HomeCurrentTripSection(),
                    CurrentTripSummaryCard(
                      trip: CurrentTripModel.fromApi(trip, orders: []),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('المحصل'), findsOneWidget);
      expect(find.text('المحصل حتى الآن'), findsOneWidget);
      if (amount != null) {
        final context = tester.element(find.byType(CurrentTripSummaryCard));
        expect(find.text(formatTripAmount(context, amount)), findsNWidgets(2));
      } else {
        expect(find.text('—'), findsNWidgets(2));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('returning from an order refetches the trip total and orders', (
    tester,
  ) async {
    final tripRepo = _TripRepo()..totalCollected = 150.75;
    final ordersRepo = _OrdersRepo();
    final tripCubit = TripTabCubit(
      CurrentTripUsecase(tripRepo),
      GetTripOrdersUsecase(ordersRepo),
    );
    addTearDown(tripCubit.close);
    await tripCubit.getCurrentTrip();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  openTripOrderDetails(context, tripID: 1, orderID: 2),
              child: const Text('Open order'),
            ),
          ),
        ),
        GoRoute(
          path: RoutesNames.orderDetails,
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(),
              child: const Text('Done'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider.value(
        value: tripCubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text('Open order'));
    await tester.pumpAndSettle();
    tripRepo.totalCollected = 250.5;
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(tripRepo.calls, 2);
    expect(ordersRepo.calls, 2);
    expect((tripCubit.state as TripTabSuccessState).trip.totalCollected, 250.5);
    expect(
      (tripCubit.state as TripTabSuccessState).ordersStatus,
      TripOrdersStatus.success,
    );
  });
}
