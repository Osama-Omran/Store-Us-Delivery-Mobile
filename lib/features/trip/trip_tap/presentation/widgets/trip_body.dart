import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/screens/current_trip_screen.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/widgets/empty_trips.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/widgets/trip_status_placeholder.dart';

import 'trip_shimmer.dart';

class TripBody extends StatelessWidget {
  const TripBody({super.key});

  Future<void> _openReceiveTrip(BuildContext context) async {
    final tripCubit = TripTabCubit.get(context);
    final accepted = await context.pushNamed<bool>(RoutesNames.receiveTrip);

    if (!context.mounted || tripCubit.isClosed) return;

    await tripCubit.getCurrentTrip(forceRefresh: accepted == true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripTabCubit, TripTabState>(
      buildWhen: (previous, current) =>
          previous is! TripTabSuccessState ||
          current is! TripTabSuccessState ||
          previous.trip != current.trip,
      builder: (context, state) {
        if (state is TripTabInitial || state is TripTabLoadingState) {
          return const TripShimmer();
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
            return const CurrentTripScreen();
          }

          // ======= Other Status ======= //
          return TripStatusPlaceholder(
            title: context.strings.trip_tab_unsupported_status,
            status: context.localizedTripAcceptanceStatus(acceptanceStatus),
            onRetry: () => TripTabCubit.get(context).getCurrentTrip(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
