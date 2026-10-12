import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

class DeliveryPaymentSummaryCard extends StatelessWidget {
  const DeliveryPaymentSummaryCard({
    super.key,
    required this.originalTotal,
    required this.expected,this.collectPayment = true,
  });
  final bool collectPayment;
  final num? originalTotal;
  final num? expected;

  @override
  Widget build(BuildContext context) {
    final expected = this.expected;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        spacing: 14,
        children: [
          DeliveryPaymentReviewRow(
            label: context.strings.order_details_original_total,
            value: originalTotal == null
                ? '—'
                : formatTripAmount(context, originalTotal!),
          ),
          DeliveryPaymentReviewRow(
            label: context.strings.delivery_selected_items_value,
            value: expected == null ? '—' : formatTripAmount(context, expected),
          ),
          Divider(color: AppColors.grey3),

          DeliveryPaymentReviewRow(
            label: collectPayment
                ? context.strings.delivery_required_amount
                : context.strings.delivery_collection_status,
            value: collectPayment
                ? expected == null
                ? '—'
                : formatTripAmount(context, expected)
                : context.strings.delivery_not_collected,
            highlighted: true,
          ),

        ],
      ),
    );
  }
}

class DeliveryPaymentReviewRow extends StatelessWidget {
  const DeliveryPaymentReviewRow({
    super.key,
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: highlighted ? AppColors.black1 : AppColors.grey4,
              fontWeight: highlighted ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: highlighted ? AppColors.primary : AppColors.black1,
              fontSize: highlighted ? 22 : 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
