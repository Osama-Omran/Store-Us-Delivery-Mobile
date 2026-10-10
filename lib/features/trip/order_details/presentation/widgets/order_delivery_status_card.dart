
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

class OrderDeliveryStatusCard extends StatelessWidget {
  const OrderDeliveryStatusCard({
    super.key,
    required this.order,
  });

  final OrderDetailsData order;

  @override
  Widget build(BuildContext context) {
    final status = order.deliveryStatus.trim().toUpperCase();

    final String statusLabel;
    final Color statusColor;
    final Color statusBackground;

    switch (status) {
      case 'DELIVERED':
      case 'COMPLETED':
      case 'FULLY_DELIVERED':
        statusLabel = context.strings.delivered_fully;
        statusColor = AppColors.green0;
        statusBackground = AppColors.green1;

      case 'PARTIAL':
      case 'PARTIALLY_DELIVERED':
      case 'DELIVERED_PARTIALLY':
        statusLabel = context.strings.delivered_partially;
        statusColor = AppColors.orange0;
        statusBackground = AppColors.orange1;

      case 'PENDING':
        statusLabel = context.strings.awaiting_delivery;
        statusColor = AppColors.black1;
        statusBackground = AppColors.grey5;

      case 'RESCHEDULED':
        statusLabel = context.strings.delivery_rescheduled;
        statusColor = AppColors.primary;
        statusBackground = AppColors.blue4;

      case 'CANCELLED':
      case 'CANCELED':
        statusLabel = context.strings.delivery_cancelled;
        statusColor = AppColors.red1;
        statusBackground =
            AppColors.red1.withValues(alpha: 0.10);

      default:
        statusLabel = status.isEmpty
            ? context.strings.trip_tab_unknown_status
            : order.deliveryStatus;
        statusColor = AppColors.grey4;
        statusBackground = AppColors.grey5;
    }

    return _DetailsCard(
      child: Column(
        spacing: 16,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.order_delivery_status,
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.grey4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: Styles.textStyle14.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.order_delivery_time,
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.grey4,
                  ),
                ),
              ),
              Text(
                '—',
                style: Styles.textStyle18.copyWith(
                  color: AppColors.black1,
                ),
              ),
            ],
          ),

          if (order.deliveryReason?.trim().isNotEmpty == true)
            _ExtraRow(
              label: context.strings.order_delivery_reason,
              value: order.deliveryReason!,
            ),

          if (order.rescheduledFor != null)
            _ExtraRow(
              label: context.strings.order_rescheduled_for,
              value: MaterialLocalizations.of(context)
                  .formatMediumDate(
                order.rescheduledFor!.toLocal(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExtraRow extends StatelessWidget {
  const _ExtraRow({
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
            style: Styles.textStyle14.copyWith(
              color: AppColors.grey4,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Styles.textStyle14.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.child});

  final Widget child;

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
            color: AppColors.black1.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
