import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/printing/storeus_receipt_builder.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';
import 'order_details_header.dart';
import 'order_details_content.dart';
import 'order_details_actions.dart';

class OrderDetailsBody extends StatelessWidget {
  const OrderDetailsBody({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.onBack,
  });
  final int tripId;
  final int orderId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.grey0,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          BlocSelector<
            OrderDetailsCubit,
            OrderDetailsState,
            ({OrderDetailsData? order, String? deliveryStatus})
          >(
            selector: (state) {
              if (state is! OrderDetailsSuccessState) {
                return (order: null, deliveryStatus: null);
              }
              final tripStatus = state.tripOrder?.deliveryStatus.trim();
              return (
                order: state.order,
                deliveryStatus: tripStatus != null && tripStatus.isNotEmpty
                    ? tripStatus
                    : state.order.deliveryStatus,
              );
            },
            builder: (context, data) {
              final order = data.order;
              final canPrint = order != null &&
                  TripOrderModel.isHandledDeliveryStatus(data.deliveryStatus);
              return OrderDetailsHeader(
                subtitle: order?.salesOrder,
                onBack: onBack,
                receiptBuilder: canPrint
                    ? () async => StoreusReceiptBuilder.order(order)
                    : null,
              );
            },
          ),
          Expanded(
            child: OrderDetailsContent(tripId: tripId, orderId: orderId),
          ),
        ],
      ),
    ),
    bottomNavigationBar: OrderDetailsActions(tripId: tripId, orderId: orderId),
  );
}
