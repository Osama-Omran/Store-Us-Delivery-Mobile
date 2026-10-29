import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';

import '../cubit/delivery_outcome_cubit.dart';
import '../cubit/delivery_outcome_state.dart';

import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../cubit/delivery_draft_cubit.dart';
import 'delivery_order_header.dart';
import 'deliver_order_content.dart';
import 'deliver_order_summary.dart';

class DeliverOrderBody extends StatelessWidget {
  const DeliverOrderBody({
    super.key,
    required this.tripId,
    required this.orderId,
  });
  final int tripId;
  final int orderId;
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OrderDetailsCubit, OrderDetailsState>(
          listenWhen: (_, current) => current is OrderDetailsSuccessState,
          listener: (context, state) {
            if (state is OrderDetailsSuccessState) {
              context.read<DeliveryDraftCubit>().initialize(state.order);
            }
          },
        ),
        BlocListener<DeliveryOutcomeCubit, DeliveryOutcomeState>(
          listenWhen: (_, current) => current is DeliveryOutcomeSuccess,
          listener: (context, _) {
            // Re-fetch the backend status; don't mark a request complete locally
            // before the API confirms it.
            context.read<OrderDetailsCubit>().getOrderDetails(
              tripId: tripId,
              orderId: orderId,
            );
          },
        ),
      ],

      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.grey0,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                BlocSelector<OrderDetailsCubit, OrderDetailsState, String?>(
                  selector: (state) => state is OrderDetailsSuccessState
                      ? state.order.salesOrder
                      : null,
                  builder: (context, salesOrder) =>
                      DeliveryOrderHeader(salesOrder: salesOrder),
                ),
                Expanded(
                  child: DeliverOrderContent(tripId: tripId, orderId: orderId),
                ),
              ],
            ),
          ),
          bottomNavigationBar: DeliverOrderSummary(
            tripId: tripId,
            orderId: orderId,
          ),
        ),
      ),
    );
  }
}
