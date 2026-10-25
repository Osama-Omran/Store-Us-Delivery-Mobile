import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class ReceivingSuccessDetails extends StatelessWidget {
  const ReceivingSuccessDetails({
    super.key,
    required this.tripNumber,
    required this.receivedAt,
  });

  final String tripNumber;
  final DateTime receivedAt;

  @override
  Widget build(BuildContext context) {
    final receivingTime = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(receivedAt.toLocal()),
      alwaysUse24HourFormat: false,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        spacing: 14,
        children: [
          _DetailRow(title: context.strings.trip_number, value: tripNumber),
          _DetailRow(
            title: context.strings.receiving_time,
            value: receivingTime,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 12,
      children: [
        Text(title, style: TextStyle(fontSize: 15, color: AppColors.grey4)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
            ),
          ),
        ),
      ],
    );
  }
}
