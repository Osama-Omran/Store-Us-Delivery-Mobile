import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/screens/layout_screen.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';
import 'package:storeus_delivery/features/login/presentation/screens/login_screen.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/sample/sample_current_trip.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/screens/receive_trip_screen.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/screens/receive_trip_success_screen.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/screens/trip_map_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String? token;

class AppRouter {
  static final routes = GoRouter(
    initialLocation: RoutesNames.login,
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        name: RoutesNames.login,
        path: RoutesNames.login,
        pageBuilder: (_, state) {
          return _fadePageBuilder(
            BlocProvider(
              create: (_) => getIt<LoginCubit>(),
              child: const LoginScreen(),
            ),
            state,
          );
        },
      ),

      GoRoute(
        name: RoutesNames.layout,
        path: RoutesNames.layout,
        pageBuilder: (_, state) {
          return _fadePageBuilder(
            BlocProvider(
              create: (_) => getIt<LayoutCubit>(),
              child: const LayoutScreen(),
            ),
            state,
          );
        },
      ),

      GoRoute(
        name: RoutesNames.receiveTrip,
        path: RoutesNames.receiveTrip,
        pageBuilder: (_, state) {
          return _slidePageBuilder(const ReceiveTripScreen(), state);
        },
      ),

      GoRoute(
        name: RoutesNames.receiveTripSuccess,
        path: RoutesNames.receiveTripSuccess,
        pageBuilder: (_, state) {
          return _fadePageBuilder(
            ReceiveTripSuccessScreen(
              tripNumber: 'TRIP-0025',
              receivedAt: DateTime(2026, 10, 8, 21, 55),
            ),
            state,
          );
        },
      ),

      GoRoute(
        name: RoutesNames.tripMap,
        path: RoutesNames.tripMap,
        pageBuilder: (_, state) {
          return _slidePageBuilder(

            TripMapScreen(
              tripId: 'TRIP-0025',
              stops: [
                TripMapStop(
                  order: sampleTripOrders[0],
                  location: const LatLng(30.0100, 31.1743),
                ),
                TripMapStop(
                  order: sampleTripOrders[1],
                  location: const LatLng(29.9955, 31.1630),
                ),
                TripMapStop(
                  order: sampleTripOrders[2],
                  location: const LatLng(30.0086, 31.1781),
                ),
                TripMapStop(
                  order: sampleTripOrders[3],
                  location: const LatLng(30.0118, 31.2064),
                ),
                TripMapStop(
                  order: sampleTripOrders[4],
                  location: const LatLng(30.0187, 31.1602),
                ),
                TripMapStop(
                  order: sampleTripOrders[5],
                  location: const LatLng(30.0072, 31.1666),
                ),
                TripMapStop(
                  order: sampleTripOrders[6],
                  location: const LatLng(30.0137, 31.2071),
                ),
                TripMapStop(
                  order: sampleTripOrders[7],
                  location: const LatLng(30.0544, 31.2028),
                ),
                TripMapStop(
                  order: sampleTripOrders[8],
                  location: const LatLng(30.0470, 31.2016),
                ),
                TripMapStop(
                  order: sampleTripOrders[9],
                  location: const LatLng(30.0499, 31.1985),
                ),
                TripMapStop(
                  order: sampleTripOrders[10],
                  location: const LatLng(30.0382, 31.2177),
                ),
                TripMapStop(
                  order: sampleTripOrders[11],
                  location: const LatLng(30.0340, 31.2107),
                ),
              ],
              onShowOrder: (stop) {
                debugPrint('Order ID: ${stop.order.id}');
                // TODO: Navigate to order details
              },
            ),
            state,
          );
        },
      ),

      // GoRoute(
      //   name: RoutesNames.layout,
      //   path: RoutesNames.layout,
      //   pageBuilder: (_, state) {
      //     return _fadePageBuilder(
      //       const LayoutScreen(),
      //       state,
      //     );
      //   },
      // ),
    ],
  );

  //======= Navigation Animations Functions =======//
  static Page<dynamic> _fadePageBuilder(Widget child, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween(begin: 0.4, end: 1.0).animate(animation);
        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }

  static Page<dynamic> _slidePageBuilder(
    Widget child,
    GoRouterState state, {
    Duration? duration,
    Offset? offset,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration ?? const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: offset ?? const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(position: slideAnimation, child: child);
      },
    );
  }
}
