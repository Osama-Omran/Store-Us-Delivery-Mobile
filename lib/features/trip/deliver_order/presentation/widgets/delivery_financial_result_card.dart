import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

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
              Text(
                original == null ? '—' : formatTripAmount(context, original!),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.delivery_estimated_total,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                estimated == null ? '—' : formatTripAmount(context, estimated!),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
