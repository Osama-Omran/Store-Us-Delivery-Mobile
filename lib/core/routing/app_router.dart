import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/screens/account_screen.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/screens/layout_screen.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';
import 'package:storeus_delivery/features/login/presentation/screens/login_screen.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/screens/cancel_delivery_success_screen.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/screens/deliver_order_screen.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/screens/order_details_screen.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/cubit/receive_trip_cubit.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/screens/receive_trip_screen.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/screens/receive_trip_success_screen.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/screens/reschedule_success_screen.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/screens/trip_map_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String? token;

class AppRouter {
  static final routes = GoRouter(
    initialLocation: token?.trim().isNotEmpty == true
        ? RoutesNames.layout
        : RoutesNames.login,
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
          return _slidePageBuilder(
            BlocProvider(
              lazy: false,
              create: (_) => getIt<ReceiveTripCubit>()..getCurrentTrip(),
              child: const ReceiveTripScreen(),
            ),
            state,
          );
        },
      ),

      GoRoute(
        name: RoutesNames.receiveTripSuccess,
        path: RoutesNames.receiveTripSuccess,
        pageBuilder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;

          return _fadePageBuilder(
            ReceiveTripSuccessScreen(
              tripNumber: extra?['tripNumber'] as String? ?? '',
              receivedAt: extra?['receivedAt'] as DateTime? ?? DateTime.now(),
            ),
            state,
          );
        },
      ),


      GoRoute(
        name: RoutesNames.tripMap,
        path: RoutesNames.tripMap,
        pageBuilder: (_, state) {
          final Map<String, dynamic> args =
          state.extra as Map<String, dynamic>;

          final int tripID = args['trip_id'] as int;
          final String tripNumber =
          args['trip_number'] as String;

          final List<TripMapStop> stops =
          args['stops'] as List<TripMapStop>;

          return _slidePageBuilder(
            TripMapScreen(
              tripId: tripNumber,
              tripApiId: tripID,
              stops: stops,
            ),
            state,
          );
        },
      ),


      GoRoute(
        name: RoutesNames.orderDetails,
        path: RoutesNames.orderDetails,
        pageBuilder: (_, state) {
          final args = state.extra as Map<String, dynamic>;

          return _slidePageBuilder(
            OrderDetailsScreen(
              tripId: args['trip_id'] as int,
              orderId: args['order_id'] as int,
            ),
            state,
          );
        },
      ),

      GoRoute(
        name: RoutesNames.account,
        path: RoutesNames.account,
        pageBuilder: (_, state) {
          return _fadePageBuilder(
            BlocProvider<AccountCubit>(
              lazy: false,
              create: (_) => getIt<AccountCubit>()..getMe(),
              child: const AccountScreen(),
            ),
            state,
          );
        },
      ),


      GoRoute(
        name: RoutesNames.deliverOrder,
        path: RoutesNames.deliverOrder,
        pageBuilder: (_, state) {
          final Map<String, dynamic> args =
          state.extra as Map<String, dynamic>;

          final int tripID = args['trip_id'] as int;
          final int orderID = args['order_id'] as int;

          return _slidePageBuilder(
            DeliverOrderScreen(
              tripId: tripID,
              orderId: orderID,
            ),
            state,
          );
        },
      ),


      GoRoute(
        name: RoutesNames.rescheduleSuccess,
        path: RoutesNames.rescheduleSuccess,
        pageBuilder: (_, state) {
          final Map<String, dynamic> args =
          state.extra as Map<String, dynamic>;

          return _slidePageBuilder(
            RescheduleSuccessScreen(
              tripId: args['trip_id'] as int,
              orderId: args['order_id'] as int,
              salesOrder: args['sales_order'] as String,
              customerName: args['customer_name'] as String,
              rescheduledFor: DateTime.parse(
                args['rescheduled_for'] as String,
              ),
              reason: args['reason'] as String,
            ),
            state,
          );
        },
      ),


      GoRoute(
        name: RoutesNames.cancelDeliverySuccess,
        path: RoutesNames.cancelDeliverySuccess,
        pageBuilder: (_, state) {
          final Map<String, dynamic> args =
          state.extra as Map<String, dynamic>;

          return _slidePageBuilder(
            CancelDeliverySuccessScreen(
              tripId: args['trip_id'] as int,
              orderId: args['order_id'] as int,
              salesOrder: args['sales_order'] as String,
              customerName: args['customer_name'] as String,
              reason: args['reason'] as String,
            ),
            state,
          );
        },
      ),



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
