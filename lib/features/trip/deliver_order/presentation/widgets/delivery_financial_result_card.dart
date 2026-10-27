import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class DeliveryFinancialResultCard extends StatelessWidget {
  const DeliveryFinancialResultCard({
    super.key,
    required this.original,
    required this.estimated,
  });

  final num? original;
  final num? estimated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        spacing: 16,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(context.strings.order_details_original_total),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  original == null ? '—' : formatTripAmount(context, original!),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.delivery_estimated_total,
                  style: Styles.base.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  estimated == null
                      ? '—'
                      : formatTripAmount(context, estimated!),
                  textAlign: TextAlign.end,
                  style: Styles.textStyle23.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
