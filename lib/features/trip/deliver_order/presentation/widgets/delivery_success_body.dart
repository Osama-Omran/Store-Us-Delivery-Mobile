import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/delivery_flow_data.dart';
import 'delivery_next_order_button.dart';
import 'delivery_success_details_card.dart';

class DeliverySuccessBody extends StatelessWidget {
  const DeliverySuccessBody({
    super.key,
    required this.flow,
    required this.collectedAmount,
    required this.paymentMethod,
  });
  final DeliveryFlowData flow;
  final num? collectedAmount;
  final String? paymentMethod;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      const SizedBox(height: 40),

      Center(
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.green1,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.green0,
            size: 82,
          ),
        ),
      ),

      const SizedBox(height: 26),

      Text(
        context.strings.delivery_success_title,
        textAlign: TextAlign.center,
        style: Styles.textStyle25.copyWith(
          color: AppColors.black1,
          fontWeight: FontWeight.w800,
        ),
      ),

      const SizedBox(height: 30),

      DeliverySuccessDetailsCard(
        flow: flow,
        collectedAmount: collectedAmount,
        paymentMethod: paymentMethod,
      ),

      const SizedBox(height: 32),

      DeliveryNextOrderButton(flow: flow),

      const SizedBox(height: 10),

      OutlinedButton(
        onPressed: () {
          context.goNamed(
            RoutesNames.orderDetails,
            extra: {'trip_id': flow.tripId, 'order_id': flow.orderId},
          );
        },
        child: Text(context.strings.view_delivery_details),
      ),
    ],
  );
}
