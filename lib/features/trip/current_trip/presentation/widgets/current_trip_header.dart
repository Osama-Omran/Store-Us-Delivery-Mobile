
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';

class CurrentTripHeader extends StatelessWidget {
  const CurrentTripHeader({
    super.key,
    required this.tripNumber,
  });

  final String tripNumber;

  // ======= Open Trip Map ======= //
  void _openTripMap(BuildContext context) {
    final state = context.read<TripTabCubit>().state;

    if (state is! TripTabSuccessState ||
        state.ordersStatus != TripOrdersStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.strings.trip_map_orders_unavailable,
          ),
        ),
      );
      return;
    }

    // ======= Build Real Map Stops ======= //
    final stops = state.orders
        .where((order) => order.hasCoordinates)
        .map(
          (order) => TripMapStop(
        order: order,
        location: LatLng(
          order.latitude!,
          order.longitude!,
        ),
      ),
    )
        .toList()
      ..sort(
            (a, b) => a.number.compareTo(b.number),
      );

    // ======= Navigate To Trip Map ======= //
    GoRouter.of(context).push(
      RoutesNames.tripMap,
      extra: {
        'trip_id': state.trip.id,
        'trip_number': state.trip.number,
        'stops': stops,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TripTabCubit>().state;

    final displayTripNumber = state is TripTabSuccessState
        ? state.trip.number
        : tripNumber;

    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.grey0,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey3,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.strings.my_current_trip,
                style: TextStyle(
                  color: AppColors.black1,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${context.strings.trip_label} '
                    '\u2066#$displayTripNumber\u2069',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey4,
                ),
              ),
            ],
          ),

          // ======= Open Map Button ======= //
          PositionedDirectional(
            end: 22,
            child: Material(
              color: AppColors.white0,
              shape: CircleBorder(
                side: BorderSide(
                  color: AppColors.grey3,
                ),
              ),
              child: InkWell(
                onTap: () => _openTripMap(context),
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 27,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
