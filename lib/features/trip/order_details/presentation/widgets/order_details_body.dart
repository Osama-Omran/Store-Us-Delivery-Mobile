import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          BlocSelector<OrderDetailsCubit, OrderDetailsState, String?>(
            selector: (state) => state is OrderDetailsSuccessState
                ? state.order.salesOrder
                : null,
            builder: (context, subtitle) =>
                OrderDetailsHeader(subtitle: subtitle, onBack: onBack),
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
