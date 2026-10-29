import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../../data/models/delivery_flow_data.dart';
import '../widgets/delivery_success_body.dart';

class DeliverySuccessScreen extends StatelessWidget {
  const DeliverySuccessScreen({
    super.key,
    required this.flow,
    required this.collectedAmount,
    required this.paymentMethod,
  });
  final DeliveryFlowData flow;
  final num? collectedAmount;
  final String? paymentMethod;
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        child: DeliverySuccessBody(
          flow: flow,
          collectedAmount: collectedAmount,
          paymentMethod: paymentMethod,
        ),
      ),
    ),
  );
}
