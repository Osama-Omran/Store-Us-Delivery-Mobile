import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class CancelDeliverySuccessDetailsCard extends StatelessWidget {
  const CancelDeliverySuccessDetailsCard({
    super.key,
    required this.salesOrder,
    required this.customerName,
    required this.reason,
  });
  final String salesOrder;
  final String customerName;
  final String reason;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        spacing: 19,
        children: [
          _SuccessInfoRow(
            title: context.strings.order_customer_data,
            value: customerName,
          ),

          _SuccessInfoRow(title: context.strings.order, value: salesOrder),

          _SuccessInfoRow(
            title: context.strings.cancel_delivery_reason_label,
            value: reason,
          ),
        ],
      ),
    );
  }
}

class _SuccessInfoRow extends StatelessWidget {
  const _SuccessInfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            title,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
        ),

        Expanded(
          child: Text(
            value.trim().isEmpty ? '—' : value,
            style: Styles.textStyle16.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
