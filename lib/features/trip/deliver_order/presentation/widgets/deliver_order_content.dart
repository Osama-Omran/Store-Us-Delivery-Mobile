import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';

import '../cubit/delivery_outcome_cubit.dart';
import '../cubit/delivery_outcome_state.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_shimmer.dart';

import 'delivery_status_messages.dart';
import 'deliver_order_loaded_content.dart';

class DeliverOrderContent extends StatelessWidget {
  const DeliverOrderContent({
    super.key,
    required this.tripId,
    required this.orderId,
  });
  final int tripId;
  final int orderId;
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<DeliveryOutcomeCubit, DeliveryOutcomeState>(
    buildWhen: (previous, current) =>
        (previous is DeliveryOutcomeSuccess) !=
        (current is DeliveryOutcomeSuccess),
    builder: (context, outcome) {
      if (outcome is DeliveryOutcomeSuccess) {
        return DeliveryOutcomeCompleted(outcome: outcome.outcome);
      }
      return BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        buildWhen: (previous, current) =>
            previous is! OrderDetailsSuccessState ||
            current is! OrderDetailsSuccessState ||
            previous.order != current.order ||
            previous.tripOrder != current.tripOrder,
        builder: (context, state) {
          if (state is OrderDetailsInitial ||
              state is OrderDetailsLoadingState) {
            return const OrderDetailsShimmer();
          }
          if (state is OrderDetailsFailureState) {
            return DeliveryError(
              message: state.errorMessage?.isNotEmpty == true
                  ? state.errorMessage!
                  : context.strings.order_details_load_failed,
              tripId: tripId,
              orderId: orderId,
            );
          }
          if (state is OrderDetailsSuccessState) {
            final status =
                (state.tripOrder?.deliveryStatus ?? state.order.deliveryStatus)
                    .trim()
                    .toUpperCase();
            if (status != 'PENDING') return DeliveryUnavailable(status: status);
            return DeliverOrderLoadedContent(tripId: tripId, orderId: orderId);
          }
          return const SizedBox.shrink();
        },
      );
    },
  );
}
