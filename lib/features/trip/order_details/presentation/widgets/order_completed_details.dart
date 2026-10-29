import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/order_details_response.dart';
import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';
import 'order_delivery_status_card.dart';

class OrderCompletedDetails extends StatelessWidget {
  const OrderCompletedDetails({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocSelector<OrderDetailsCubit, OrderDetailsState, OrderDetailsData?>(
        selector: (state) =>
            state is OrderDetailsSuccessState ? state.order : null,
        builder: (context, order) {
          if (order == null) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.grey5,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, color: AppColors.grey4),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.strings.order_details_confirmed_read_only,
                        style: Styles.textStyle14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              OrderDeliveryStatusCard(order: order),
            ],
          );
        },
      );
}
