import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';

class DeliveryResultSummaryCard extends StatelessWidget {
  const DeliveryResultSummaryCard({super.key, required this.flow});

  final DeliveryFlowData flow;

  @override
  Widget build(BuildContext context) {
    final partial = flow.isPartial;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: partial ? AppColors.orange1 : AppColors.green1,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: partial ? AppColors.orange0 : AppColors.green0,
        ),
      ),
      child: Column(
        spacing: 13,
        children: [
          Row(
            children: [
              Icon(
                partial
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: partial ? AppColors.orange0 : AppColors.green0,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  partial
                      ? context.strings.delivery_partial_draft
                      : context.strings.delivery_full_draft,
                  style: TextStyle(
                    color: partial ? AppColors.orange0 : AppColors.green0,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _QtyBox(
                title: context.strings.delivery_ordered,
                qty: flow.orderedQty,
              ),
              const SizedBox(width: 8),
              _QtyBox(
                title: context.strings.delivery_selected,
                qty: flow.deliveredQty,
              ),
              const SizedBox(width: 8),
              _QtyBox(
                title: context.strings.delivery_not_delivered,
                qty: flow.remainingQty,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBox extends StatelessWidget {
  const _QtyBox({required this.title, required this.qty});

  final String title;
  final num qty;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white0,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          spacing: 4,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
            Text(
              '$qty',
              style: TextStyle(
                color: AppColors.black1,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
