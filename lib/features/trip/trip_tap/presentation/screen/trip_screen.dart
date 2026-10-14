import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/screens/current_trip_screen.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/widgets/empty_trips.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/widgets/trip_status_placeholder.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  @override
  void initState() {
    super.initState();
    TripTabCubit.get(context).getCurrentTrip();
  }

  void _openOrderDetails(
    BuildContext context,
    int tripId,
    TripOrderModel order,
  ) {
    final orderId = order.apiId;

    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.trip_order_details_unavailable)),
      );
      return;
    }

    // LayoutCubit.get(context).openOrderDetails(
    //   tripId: tripId,
    //   orderId: orderId,
    // );
  }

  Future<void> _openReceiveTrip(BuildContext context) async {
    await context.pushNamed(RoutesNames.receiveTrip);

    if (!context.mounted) return;

    TripTabCubit.get(context).getCurrentTrip();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripTabCubit, TripTabState>(
      builder: (context, state) {
        if (state is TripTabInitial || state is TripTabLoadingState) {
          return const Center(
            child: CustomLoadingIndicator(size: 96, primaryColor: true),
          );
        }

        if (state is TripTabFailureState) {
          return TripStatusPlaceholder(
            title: state.errorMessage?.isNotEmpty == true
                ? state.errorMessage!
                : context.strings.trip_tab_load_failed,
            onRetry: () => TripTabCubit.get(context).getCurrentTrip(),
          );
        }

        if (state is TripTabEmptyState) {
          return TripStatusPlaceholder(
            title: context.strings.trip_tab_no_trip,
            onRetry: () => TripTabCubit.get(context).getCurrentTrip(),
          );
        }

        if (state is TripTabSuccessState) {
          final trip = state.trip;

          final acceptanceStatus = trip.acceptance?.status.trim().toUpperCase();

          // ======= Pending Receiving ======= //
          if (trip.acceptance?.requiresReceiving == true) {
            return EmptyTrips(
              tripNumber: trip.number,
              warehouseName: trip.warehouse?.name ?? trip.warehouse?.id ?? '—',
              onReviewAndReceive: () => _openReceiveTrip(context),
            );
          }

          // ======= Accepted By User Or Administration ======= //
          if (trip.acceptance?.isOperationallyAccepted == true) {
            final ordersLoaded = state.ordersStatus == TripOrdersStatus.success;

            return CurrentTripScreen.fromApi(
              trip: trip,
              orders: ordersLoaded ? state.orders : null,
              ordersLoading: state.ordersStatus == TripOrdersStatus.loading,
              ordersError: state.ordersStatus == TripOrdersStatus.failure
                  ? state.ordersError ?? context.strings.trip_orders_load_failed
                  : null,
              onRetryOrders: () => TripTabCubit.get(context).getTripOrders(),

              onOpenOrder: (order) {
                _openOrderDetails(context, trip.id, order);
              },

              onShowDeliveryDetails: (order) {
                _openOrderDetails(context, trip.id, order);
              },
            );
          }

          // ======= Other Status ======= //
          return TripStatusPlaceholder(
            title: context.strings.trip_tab_unsupported_status,
            status: acceptanceStatus ?? context.strings.trip_tab_unknown_status,
            onRetry: () => TripTabCubit.get(context).getCurrentTrip(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
