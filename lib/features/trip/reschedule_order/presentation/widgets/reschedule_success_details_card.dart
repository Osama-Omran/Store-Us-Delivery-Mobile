import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class RescheduleSuccessDetailsCard extends StatelessWidget {
  const RescheduleSuccessDetailsCard({
    super.key,
    required this.salesOrder,
    required this.customerName,
    required this.rescheduledFor,
    required this.reason,
  });
  final String salesOrder;
  final String customerName;
  final DateTime rescheduledFor;
  final String reason;
  @override
  Widget build(BuildContext context) {
    final date = rescheduledFor.toLocal();

    final formattedDate = MaterialLocalizations.of(context)
        .formatMediumDate(date);

    final formattedTime = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(date));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        spacing: 18,
        children: [
          _ResultRow(
            title: context.strings.order_customer_data,
            value: customerName,
          ),

          _ResultRow(title: context.strings.order, value: salesOrder),

          _ResultRow(
            title: context.strings.reschedule_new_date_time,
            value: '$formattedDate\n$formattedTime',
            highlighted: true,
          ),

          _ResultRow(
            title: context.strings.reschedule_reason_label,
            value: reason,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.title,
    required this.value,
    this.highlighted = false,
  });

  final String title;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            title,
            style: Styles.base.copyWith(fontSize: 14, color: AppColors.grey4),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: Styles.base.copyWith(
              fontSize: highlighted ? 22 : 16,
              fontWeight: FontWeight.w800,
              color: highlighted ? AppColors.primary : AppColors.black1,
            ),
          ),
        ),
      ],
    );
  }
}
