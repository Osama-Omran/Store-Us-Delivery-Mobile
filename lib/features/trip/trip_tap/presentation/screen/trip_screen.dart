
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/screens/current_trip_screen.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/widgets/empty_trips.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/widgets/trip_status_placeholder.dart';

import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      getIt<TripTabCubit>()..getCurrentTrip(),
      child: const _TripScreenBody(),
    );
  }
}

class _TripScreenBody extends StatelessWidget {
  const _TripScreenBody();


  void _openOrderDetails(
      BuildContext context,
      int tripId,
      TripOrderModel order,
      ) {
    final orderId = order.apiId;

    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.strings.trip_order_details_unavailable,
          ),
        ),
      );
      return;
    }

    // LayoutCubit.get(context).openOrderDetails(
    //   tripId: tripId,
    //   orderId: orderId,
    // );
  }

  Future<void> _openReceiveTrip(
      BuildContext context,
      ) async {
    await context.pushNamed(RoutesNames.receiveTrip);

    if (!context.mounted) return;

    TripTabCubit.get(context).getCurrentTrip();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripTabCubit, TripTabState>(
      builder: (context, state) {
        if (state is TripTabInitial ||
            state is TripTabLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is TripTabFailureState) {
          return TripStatusPlaceholder(
            title: state.errorMessage?.isNotEmpty == true
                ? state.errorMessage!
                : context.strings.trip_tab_load_failed,
            onRetry: () =>
                TripTabCubit.get(context).getCurrentTrip(),
          );
        }

        if (state is TripTabEmptyState) {
          return TripStatusPlaceholder(
            title: context.strings.trip_tab_no_trip,
            onRetry: () =>
                TripTabCubit.get(context).getCurrentTrip(),
          );
        }

        if (state is TripTabSuccessState) {
          final trip = state.trip;

          final acceptanceStatus =
          trip.acceptance?.status.trim().toUpperCase();

          // ======= Pending ======= //
          if (acceptanceStatus == 'PENDING') {
            return EmptyTrips(
              tripNumber: trip.number,
              warehouseName:
              trip.warehouse?.name ??
                  trip.warehouse?.id ??
                  '—',
              onReviewAndReceive: () =>
                  _openReceiveTrip(context),
            );
          }

          // ======= Accepted ======= //
          if (acceptanceStatus == 'ACCEPTED') {
            final ordersLoaded =
                state.ordersStatus ==
                    TripOrdersStatus.success;


            if (acceptanceStatus == 'ACCEPTED') {
              final ordersLoaded =
                  state.ordersStatus == TripOrdersStatus.success;

              return CurrentTripScreen.fromApi(
                trip: trip,
                orders: ordersLoaded ? state.orders : null,
                ordersLoading:
                state.ordersStatus == TripOrdersStatus.loading,
                ordersError: state.ordersStatus == TripOrdersStatus.failure
                    ? state.ordersError ??
                    context.strings.trip_orders_load_failed
                    : null,
                onRetryOrders: () =>
                    TripTabCubit.get(context).getTripOrders(),

                // ======= Open Order ======= //
                onOpenOrder: (order) {
                  _openOrderDetails(context, trip.id, order);
                },

                // ======= View Delivery Details ======= //
                onShowDeliveryDetails: (order) {
                  _openOrderDetails(context, trip.id, order);
                },
              );
            }

          }

          // ======= Other Status ======= //
          return TripStatusPlaceholder(
            title: context.strings
                .trip_tab_unsupported_status,
            status: acceptanceStatus ??
                context.strings.trip_tab_unknown_status,
            onRetry: () =>
                TripTabCubit.get(context).getCurrentTrip(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
