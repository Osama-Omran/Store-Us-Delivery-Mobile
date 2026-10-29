import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../widgets/reschedule_success_body.dart';

class RescheduleSuccessScreen extends StatelessWidget {
  const RescheduleSuccessScreen({
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
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        child: RescheduleSuccessBody(
          tripId: tripId,
          orderId: orderId,
          salesOrder: salesOrder,
          customerName: customerName,
          rescheduledFor: rescheduledFor,
          reason: reason,
        ),
      ),
    ),
  );
}
