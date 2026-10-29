import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'reschedule_success_details_card.dart';
import 'reschedule_next_order_button.dart';

class RescheduleSuccessBody extends StatelessWidget {
  const RescheduleSuccessBody({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.salesOrder,
    required this.customerName,
    required this.rescheduledFor,
    required this.reason,
  });
  final int tripId;
  final int orderId;
  final String salesOrder;
  final String customerName;
  final DateTime rescheduledFor;
  final String reason;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(28, 70, 28, 36),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        // ======= Success Icon ======= //
        Center(
          child: Container(
            width: 145,
            height: 145,
            decoration: BoxDecoration(
              color: AppColors.blue4,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_repeat_rounded,
              size: 82,
              color: AppColors.primary,
            ),
          ),
        ),

        // ======= Title ======= //
        Text(
          context.strings.reschedule_success_title,
          textAlign: TextAlign.center,
          style: Styles.textStyle27.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.black1,
          ),
        ),

        // ======= Details Card ======= //
        RescheduleSuccessDetailsCard(
          salesOrder: salesOrder,
          customerName: customerName,
          rescheduledFor: rescheduledFor,
          reason: reason,
        ),

        Text(
          context.strings.reschedule_no_delivery_recorded,
          textAlign: TextAlign.center,
          style: Styles.base.copyWith(fontSize: 14, color: AppColors.grey4),
        ),

        const SizedBox(height: 4),

        // ======= Next Order ======= //
        RescheduleNextOrderButton(tripId: tripId, orderId: orderId),
      ],
    ),
  );
}
