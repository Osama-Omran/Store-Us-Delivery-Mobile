import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';

import '../cubit/delivery_outcome_cubit.dart';
import '../cubit/delivery_outcome_state.dart';
import 'delivery_summary_bar.dart';

class DeliverOrderSummary extends StatelessWidget {
  const DeliverOrderSummary({
    super.key,
    required this.tripId,
    required this.orderId,
  });
  final int tripId;
  final int orderId;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DeliveryOutcomeCubit, DeliveryOutcomeState>(
        buildWhen: (previous, current) =>
            (previous is DeliveryOutcomeSuccess) !=
            (current is DeliveryOutcomeSuccess),
        builder: (context, outcome) {
          if (outcome is DeliveryOutcomeSuccess) return const SizedBox.shrink();
          return BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
            buildWhen: (previous, current) =>
                previous is! OrderDetailsSuccessState ||
                current is! OrderDetailsSuccessState ||
                previous.order != current.order ||
                previous.tripOrder != current.tripOrder,
            builder: (context, state) {
              if (state is! OrderDetailsSuccessState) {
                return const SizedBox.shrink();
              }
              final status =
                  (state.tripOrder?.deliveryStatus ??
                          state.order.deliveryStatus)
                      .trim()
                      .toUpperCase();
              return status == 'PENDING'
                  ? DeliverySummaryBar(tripId: tripId, orderId: orderId)
                  : const SizedBox.shrink();
            },
          );
        },
      );
}
