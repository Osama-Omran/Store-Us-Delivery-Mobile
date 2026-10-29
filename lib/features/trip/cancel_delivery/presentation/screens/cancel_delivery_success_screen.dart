import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../widgets/cancel_delivery_success_body.dart';

class CancelDeliverySuccessScreen extends StatelessWidget {
  const CancelDeliverySuccessScreen({
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
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        child: CancelDeliverySuccessBody(
          tripId: tripId,
          orderId: orderId,
          salesOrder: salesOrder,
          customerName: customerName,
          reason: reason,
        ),
      ),
    ),
  );
}
