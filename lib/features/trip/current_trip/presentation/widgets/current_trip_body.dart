import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/current_trip_model.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

import 'current_trip_header.dart';
import 'current_trip_orders_section.dart';
import 'current_trip_summary_card.dart';

class CurrentTripBody extends StatelessWidget {
  const CurrentTripBody({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Column(
      children: [
        const CurrentTripHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 122),
            children: [
              BlocBuilder<TripTabCubit, TripTabState>(
                builder: (context, state) {
                  if (state is! TripTabSuccessState) {
                    return const SizedBox.shrink();
                  }
                  return CurrentTripSummaryCard(
                    trip: CurrentTripModel.fromApi(
                      state.trip,
                      orders: state.ordersStatus == TripOrdersStatus.success
                          ? state.orders
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 26),
              const CurrentTripOrdersSection(),
            ],
          ),
        ),
      ],
    ),
  );
}
