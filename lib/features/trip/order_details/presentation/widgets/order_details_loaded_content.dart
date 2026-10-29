import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';
import '../../data/models/order_customer_location.dart';
import 'order_customer_card.dart';
import 'order_details_financial_card.dart';
import 'order_details_items_card.dart';
import 'order_collection_status_card.dart';
import 'order_location_updated_notice.dart';
import 'order_completed_details.dart';

class OrderDetailsLoadedContent extends StatelessWidget {
  const OrderDetailsLoadedContent({
    super.key,
    required this.tripId,
    required this.orderId,
  });
  final int tripId;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    final cubit = OrderDetailsCubit.get(context);
    final state = cubit.state;
    if (state is! OrderDetailsSuccessState) return const SizedBox.shrink();
    final order = state.order;
    final collection = state.tripOrder;
    final location = OrderCustomerLocation.fromApi(
      details: order,
      tripOrder: collection,
    );
    final deliveryStatus = (collection?.deliveryStatus ?? order.deliveryStatus)
        .trim()
        .toUpperCase();
    final isDelivered = const {
      'DELIVERED',
      'COMPLETED',
      'FULLY_DELIVERED',
      'DELIVERED_FULLY',
    }.contains(deliveryStatus);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => cubit.getOrderDetails(tripId: tripId, orderId: orderId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          OrderCustomerCard(
            tripId: tripId,
            orderId: orderId,
            location: location,
          ),
          if (state.locationUpdated) ...[
            const SizedBox(height: 14),
            const OrderLocationUpdatedNotice(),
          ],
          const SizedBox(height: 20),
          const OrderDetailsFinancialCard(),
          if (collection != null) ...[
            const SizedBox(height: 14),
            OrderCollectionStatusCard(order: collection),
          ],
          const SizedBox(height: 20),
          const OrderDetailsItemsCard(),
          if (isDelivered) ...[
            const SizedBox(height: 20),
            const OrderCompletedDetails(),
          ],
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
