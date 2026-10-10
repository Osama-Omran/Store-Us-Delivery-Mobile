
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

class OrderDetailsFinancialCard extends StatelessWidget {
  const OrderDetailsFinancialCard({
    super.key,
    required this.order,
  });

  final OrderDetailsData order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        spacing: 18,
        children: [
          _FinancialRow(
            label: context.strings.order_details_original_total,
            value: order.originalTotal == null
                ? '—'
                : formatTripAmount(
              context,
              order.originalTotal!,
            ),
          ),

          _FinancialRow(
            label: context.strings.order_details_collected,
            value: '—',
          ),

          _FinancialRow(
            label: context.strings.order_details_remaining,
            value: '—',
          ),

          _FinancialRow(
            label: context.strings.order_details_payment_method,
            value: '—',
          ),

          Text(
            context.strings.order_details_financial_unavailable,
            style: Styles.textStyle12.copyWith(
              color: AppColors.grey4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  const _FinancialRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Expanded(
          child: Text(
            label,
            style: Styles.textStyle16.copyWith(
              color: AppColors.grey4,
            ),
          ),
        ),
        Text(
          value,
          style: Styles.textStyle18.copyWith(
            color: AppColors.black1,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
