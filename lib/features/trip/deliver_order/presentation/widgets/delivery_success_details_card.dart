import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/delivery_flow_data.dart';

import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

class DeliverySuccessDetailsCard extends StatelessWidget {
  const DeliverySuccessDetailsCard({
    super.key,
    required this.flow,
    required this.collectedAmount,
    required this.paymentMethod,
  });
  final DeliveryFlowData flow;
  final num? collectedAmount;
  final String? paymentMethod;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.white0,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: AppColors.grey3),
    ),
    child: Column(
      spacing: 16,
      children: [
        _SuccessRow(label: context.strings.order, value: flow.salesOrder),
        _SuccessRow(
          label: context.strings.order_customer_data,
          value: flow.customerName,
        ),
        _SuccessRow(
          label: context.strings.delivery_selected_items_value,
          value: flow.estimatedTotal == null
              ? '—'
              : formatTripAmount(context, flow.estimatedTotal!),
        ),

        _SuccessRow(
          label: context.strings.delivery_collected_amount,
          value: collectedAmount == null
              ? context.strings.delivery_not_collected
              : formatTripAmount(context, collectedAmount!),
        ),
        _SuccessRow(
          label: context.strings.delivery_payment_method,
          value: paymentMethod == null
              ? context.strings.delivery_not_applicable
              : paymentMethod == 'cash'
              ? context.strings.delivery_cash
              : paymentMethod!,
        ),

        if (collectedAmount == null) ...[
          const SizedBox(height: 12),
          Text(
            context.strings.delivery_success_without_collection,
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(
              color: AppColors.orange0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    ),
  );
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Styles.base.copyWith(color: AppColors.grey4),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Styles.base.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
