import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/screens/layout_screen.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';
import 'package:storeus_delivery/features/login/presentation/screens/login_screen.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/screens/receive_trip_screen.dart';

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
