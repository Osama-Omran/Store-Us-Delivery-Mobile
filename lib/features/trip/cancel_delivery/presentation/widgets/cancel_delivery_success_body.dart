import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'cancel_delivery_success_details_card.dart';
import 'cancel_delivery_next_order_button.dart';

class CancelDeliverySuccessBody extends StatelessWidget {
  const CancelDeliverySuccessBody({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.salesOrder,
    required this.customerName,
    required this.reason,
  });
  final int tripId;
  final int orderId;
  final String salesOrder;
  final String customerName;
  final String reason;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(28, 75, 28, 36),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        // ======= Success Icon ======= //
        Center(
          child: Container(
            height: 145,
            width: 145,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.red1.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.block_rounded, size: 84, color: AppColors.red1),
          ),
        ),

        // ======= Success Title ======= //
        Text(
          context.strings.cancel_delivery_success_title,
          textAlign: TextAlign.center,
          style: Styles.textStyle24.copyWith(
            color: AppColors.black1,
            fontWeight: FontWeight.w800,
          ),
        ),

        // ======= Details Card ======= //
        CancelDeliverySuccessDetailsCard(
          salesOrder: salesOrder,
          customerName: customerName,
          reason: reason,
        ),

        Text(
          context.strings.cancel_delivery_success_description,
          textAlign: TextAlign.center,
          style: Styles.textStyle14.copyWith(color: AppColors.grey4),
        ),

        const SizedBox(height: 5),

        // ======= Next Order Button ======= //
        CancelNextOrderButton(tripId: tripId, orderId: orderId),
      ],
    ),
  );
}
