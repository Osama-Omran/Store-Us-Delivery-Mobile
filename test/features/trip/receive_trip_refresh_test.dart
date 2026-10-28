import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/repo/account_repo_interface.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/get_me_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/logout_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/domain/repo/stock_transfer_repo_interface.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/domain/usecases/get_stock_transfers_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/screens/layout_screen.dart';
import 'package:storeus_delivery/features/notifications/domain/repo/notifications_repo_interface.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/repo/trip_orders_repo_interface.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/screens/current_trip_screen.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/repo/receive_trip_repo_interface.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/accept_trip_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/current_trip_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/loaded_items_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/cubit/receive_trip_cubit.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/cubit/receive_trip_state.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/screens/receive_trip_screen.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/screens/receive_trip_success_screen.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/screen/trip_screen.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/widgets/empty_trips.dart';

const _pendingTrip = CurrentTripData(
  id: 7,
  number: 'TRIP-7',
  status: 'SHIPPED',
  acceptance: TripAcceptance(status: 'PENDING'),
);
const _acceptedTrip = CurrentTripData(
  id: 7,
  number: 'TRIP-7',
  status: 'ACTIVE',
  acceptance: TripAcceptance(status: 'ACCEPTED'),
);
const _ordersResponse = TripOrdersResponse(
  success: true,
  data: [
    TripOrderData(
      id: 42,
      salesOrder: 'SO-42',
      stopOrder: 1,
      deliveryStatus: 'PENDING',
      paymentStatus: 'UNPAID',
    ),
  ],
);

void main() {
  test(
    'forced refresh supersedes a pending request and loads accepted orders',
    () async {
      final oldResponse = Completer<ApiResult<CurrentTripResponse>>();
      final repo = _TripRepo()..onCurrentTrip = () => oldResponse.future;
      final cubit = _tripCubit(repo);
      addTearDown(cubit.close);

      final oldRequest = cubit.getCurrentTrip();
      await cubit.getCurrentTrip();
      expect(repo.currentTripCalls, 1);

      repo.onCurrentTrip = () async => const ApiResult.success(
        CurrentTripResponse(success: true, data: _acceptedTrip),
      );
      await cubit.getCurrentTrip(forceRefresh: true);
      expect(repo.currentTripCalls, 2);
      expect(repo.requestedTripIds, [7]);

      oldResponse.complete(
        const ApiResult.success(
          CurrentTripResponse(success: true, data: _pendingTrip),
        ),
      );
      await oldRequest;

      final state = cubit.state as TripTabSuccessState;
      expect(state.trip.acceptance!.status, 'ACCEPTED');
      expect(state.ordersStatus, TripOrdersStatus.success);
      expect(state.orders.single.apiId, 42);
    },
  );

  test('refresh ignores orders from an older trip request', () async {
    final oldOrders = Completer<ApiResult<TripOrdersResponse>>();
    final repo = _TripRepo()
      ..trip = _acceptedTrip
      ..onOrders = () => oldOrders.future;
    final cubit = _tripCubit(repo);
    addTearDown(cubit.close);
    final oldRequest = cubit.getCurrentTrip();
    // Wait until the first request reaches the orders repository.
    await Future<void>.delayed(Duration.zero);
    expect(repo.requestedTripIds, [7]);

    repo.onOrders = () async => const ApiResult.success(_ordersResponse);
    await cubit.getCurrentTrip(forceRefresh: true);
    oldOrders.complete(
      const ApiResult.success(TripOrdersResponse(success: true, data: [])),
    );
    await oldRequest;

    expect((cubit.state as TripTabSuccessState).orders.single.apiId, 42);
  });

  test('trip and orders refresh failures can be retried', () async {
    final repo = _TripRepo()
      ..onCurrentTrip = () async => const ApiResult.success(
        CurrentTripResponse(success: false, message: 'Trip unavailable'),
      );
    final cubit = _tripCubit(repo);
    addTearDown(cubit.close);

    await cubit.getCurrentTrip(forceRefresh: true);
    expect(
      (cubit.state as TripTabFailureState).errorMessage,
      'Trip unavailable',
    );

    repo
      ..onCurrentTrip = null
      ..trip = _acceptedTrip
      ..onOrders = () async => const ApiResult.success(
        TripOrdersResponse(
          success: false,
          data: [],
          message: 'Orders unavailable',
        ),
      );
    await cubit.getCurrentTrip();
    final failure = cubit.state as TripTabSuccessState;
    expect(failure.ordersStatus, TripOrdersStatus.failure);
    expect(failure.ordersError, 'Orders unavailable');

    repo.onOrders = null;
    await cubit.getTripOrders();
    expect((cubit.state as TripTabSuccessState).orders.single.apiId, 42);
  });

  for (final fromDrawer in [false, true]) {
    for (final exit in ['button', 'back', 'cancel']) {
      testWidgets(
        '${fromDrawer ? 'drawer' : 'trip tab'}: $exit refreshes the owning cubit',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 1920);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final repo = _TripRepo();
          final cubit = _tripCubit(repo);
          final unrelatedRepo = _TripRepo();
          final rootCubit = _tripCubit(unrelatedRepo);
          final receiveCubit = _ReceiveCubit(repo);
          final layout = LayoutCubit();
          if (fromDrawer) {
            layout.screens[0] = const Center(child: Text('Home'));
            layout.selectTap(0);
            await getIt.reset();
            getIt.registerFactory<TripTabCubit>(() => cubit);
            getIt.registerFactory<AccountCubit>(_IdleAccountCubit.new);
            getIt.registerFactory<NotificationsCubit>(
              _IdleNotificationsCubit.new,
            );
            getIt.registerFactory<StockTransferCubit>(
              _IdleStockTransferCubit.new,
            );
          }

          final router = GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => fromDrawer
                    ? const LayoutScreen()
                    : const Scaffold(body: TripScreen()),
              ),
              GoRoute(
                path: RoutesNames.receiveTrip,
                name: RoutesNames.receiveTrip,
                builder: (_, _) => BlocProvider<ReceiveTripCubit>.value(
                  value: receiveCubit,
                  child: const ReceiveTripScreen(),
                ),
              ),
              GoRoute(
                path: RoutesNames.receiveTripSuccess,
                name: RoutesNames.receiveTripSuccess,
                builder: (_, state) {
                  final extra = state.extra! as Map<String, dynamic>;
                  return ReceiveTripSuccessScreen(
                    tripNumber: extra['tripNumber'] as String,
                    receivedAt: extra['receivedAt'] as DateTime,
                  );
                },
              ),
            ],
          );
          addTearDown(() async {
            await tester.pumpWidget(const SizedBox.shrink());
            router.dispose();
            if (!cubit.isClosed) await cubit.close();
            await rootCubit.close();
            await receiveCubit.close();
            await layout.close();
            if (fromDrawer) await getIt.reset();
          });

          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<LayoutCubit>.value(value: layout),
                BlocProvider<TripTabCubit>.value(
                  value: fromDrawer ? rootCubit : cubit,
                ),
              ],
              child: MaterialApp.router(
                locale: const Locale('ar'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: router,
              ),
            ),
          );
          await tester.pumpAndSettle();

          if (fromDrawer) {
            tester
                .state<ScaffoldState>(find.byType(Scaffold).first)
                .openDrawer();
            await tester.pumpAndSettle();
            final strings = AppLocalizations.of(
              tester.element(find.byType(LayoutScreen)),
            )!;
            await tester.ensureVisible(find.text(strings.receive_vehicle));
            await tester.tap(find.text(strings.receive_vehicle));
          } else {
            tester
                .widget<EmptyTrips>(find.byType(EmptyTrips))
                .onReviewAndReceive();
          }
          await tester.pumpAndSettle();
          expect(find.byType(ReceiveTripScreen), findsOneWidget);
          final beforeReturn = repo.currentTripCalls;

          if (exit == 'cancel') {
            router.pop();
          } else {
            repo.trip = _acceptedTrip;
            receiveCubit.completeAcceptance();
            await tester.pumpAndSettle();
            expect(find.byType(ReceiveTripSuccessScreen), findsOneWidget);
            // Refresh must wait until the success page has been dismissed.
            expect(repo.currentTripCalls, beforeReturn);
            if (exit == 'button') {
              await tester.ensureVisible(find.byType(ElevatedButton));
              await tester.tap(find.byType(ElevatedButton));
            } else {
              await tester.binding.handlePopRoute();
            }
          }
          await tester.pumpAndSettle();

          expect(router.routeInformationProvider.value.uri.path, '/');
          expect(find.byType(ReceiveTripScreen), findsNothing);
          expect(find.byType(ReceiveTripSuccessScreen), findsNothing);
          // Mounting the trip tab can also run its normal initial refresh.
          expect(repo.currentTripCalls, greaterThan(beforeReturn));
          expect(unrelatedRepo.currentTripCalls, 0);
          if (exit == 'cancel') {
            expect((cubit.state as TripTabSuccessState).trip, _pendingTrip);
            expect(repo.requestedTripIds, isEmpty);
            if (fromDrawer) expect(layout.selectedTap, 0);
          } else {
            expect(find.byType(CurrentTripScreen), findsOneWidget);
            expect(find.byType(EmptyTrips), findsNothing);
            expect(
              (cubit.state as TripTabSuccessState).orders.single.apiId,
              42,
            );
            expect(repo.requestedTripIds, isNotEmpty);
            expect(repo.requestedTripIds, everyElement(7));
            if (fromDrawer) expect(layout.selectedTap, 1);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

TripTabCubit _tripCubit(_TripRepo repo) =>
    TripTabCubit(CurrentTripUsecase(repo), GetTripOrdersUsecase(repo));

class _TripRepo implements ReceiveTripRepoInterface, TripOrdersRepoInterface {
  CurrentTripData trip = _pendingTrip;
  int currentTripCalls = 0;
  final requestedTripIds = <int>[];
  Future<ApiResult<CurrentTripResponse>> Function()? onCurrentTrip;
  Future<ApiResult<TripOrdersResponse>> Function()? onOrders;

  @override
  Future<ApiResult<CurrentTripResponse>> getCurrentTrip() async {
    currentTripCalls++;
    return onCurrentTrip?.call() ??
        ApiResult.success(CurrentTripResponse(success: true, data: trip));
  }

  @override
  Future<ApiResult<TripOrdersResponse>> getTripOrders({
    required int tripId,
  }) async {
    requestedTripIds.add(tripId);
    return onOrders?.call() ?? const ApiResult.success(_ordersResponse);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Drive the accepted state without invoking camera, GPS or the acceptance API.
class _ReceiveCubit extends ReceiveTripCubit {
  _ReceiveCubit(_TripRepo repo)
    : super(
        CurrentTripUsecase(repo),
        LoadedItemsUsecase(repo),
        AcceptTripUsecase(repo),
      ) {
    emit(ReceiveTripEmptyState());
  }

  void completeAcceptance() => emit(
    ReceiveTripAcceptedState(
      tripNumber: _acceptedTrip.number,
      acceptedAt: DateTime(2026, 10, 28, 12),
    ),
  );
}

class _UnusedRepos
    implements
        AccountRepoInterface,
        NotificationsRepoInterface,
        StockTransferRepoInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _IdleAccountCubit extends AccountCubit {
  _IdleAccountCubit()
    : super(GetMeUsecase(_UnusedRepos()), LogoutUsecase(_UnusedRepos()));

  @override
  Future<void> getMe() async {}
}

class _IdleNotificationsCubit extends NotificationsCubit {
  _IdleNotificationsCubit()
    : super(
        GetNotificationsUsecase(_UnusedRepos()),
        MarkNotificationAsReadUsecase(_UnusedRepos()),
      );

  @override
  Future<void> getNotifications() async {}
}

class _IdleStockTransferCubit extends StockTransferCubit {
  _IdleStockTransferCubit() : super(GetStockTransfersUsecase(_UnusedRepos()));

  @override
  Future<void> load() async {}

  @override
  Future<void> refreshIfStale({
    Duration maxAge = const Duration(minutes: 1),
  }) async {}
}
