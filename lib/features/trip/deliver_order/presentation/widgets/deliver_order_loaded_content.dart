import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_customer_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_financial_card.dart';

import 'delivery_outcome_actions.dart';
import 'delivery_order_items_section.dart';
import 'delivery_extra_products_section.dart';

class DeliverOrderLoadedContent extends StatelessWidget {
  const DeliverOrderLoadedContent({
    super.key,
    required this.tripId,
    required this.orderId,
  });
  final int tripId;
  final int orderId;
  Future<void> _refresh(BuildContext context) =>
      OrderDetailsCubit.get(context)
          .getOrderDetails(tripId: tripId, orderId: orderId);
  @override
  Widget build(BuildContext context) {
    final state = OrderDetailsCubit.get(context).state;
    if (state is! OrderDetailsSuccessState) return const SizedBox.shrink();
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          // ======= Customer Data ======= //
          OrderCustomerCard(
            tripId: tripId,
            orderId: orderId,
            location: OrderCustomerLocation.fromApi(
              details: state.order,
              tripOrder: state.tripOrder,
            ),
          ),

          const SizedBox(height: 20),

          // ======= Original Total ======= //
          const OrderDetailsFinancialCard(),

          const SizedBox(height: 22),

          // ======= Cancel / Reschedule ======= //
          DeliveryOutcomeActions(tripId: tripId, orderId: orderId),

          const SizedBox(height: 22),

          // ======= Delivery Items ======= //
          const DeliveryOrderItemsSection(),

          const SizedBox(height: 28),

          // ======= Additional Items ======= //
          const DeliveryExtraProductsSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
