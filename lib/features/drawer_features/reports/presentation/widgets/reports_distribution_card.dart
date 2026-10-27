import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';

import 'reports_card.dart';

class ReportsDistributionCard extends StatelessWidget {
  const ReportsDistributionCard({super.key, required this.distribution});

  // null means per-trip distribution is unavailable, not zero.
  final List<ReportOrderDistribution>? distribution;

  String _label(BuildContext context, String status) =>
      switch (status.trim().toUpperCase()) {
        'DELIVERED' ||
        'COMPLETED' ||
        'FULLY_DELIVERED' ||
        'DELIVERED_FULLY' => context.strings.reports_delivered,
        'PARTIAL' ||
        'PARTIALLY_DELIVERED' ||
        'PARTIAL_DELIVERED' ||
        'DELIVERED_PARTIALLY' => context.strings.reports_partial,
        'PENDING' => context.strings.reports_status_pending,
        'RESCHEDULED' => context.strings.reports_status_rescheduled,
        'CANCELLED' || 'CANCELED' => context.strings.reports_status_cancelled,
        _ => context.strings.trip_customers_unknown_status,
      };

  Color _color(String status) => switch (status) {
    'DELIVERED' => AppColors.green0,
    'PARTIAL' => AppColors.orange0,
    'CANCELLED' => AppColors.red1,
    _ => AppColors.grey4,
  };

  @override
  Widget build(BuildContext context) {
    final values = distribution;
    final total = values?.fold<int>(0, (sum, row) => sum + row.count) ?? 0;

    return ReportsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            context.strings.reports_order_distribution,
            style: Styles.textStyle18.copyWith(color: AppColors.black1),
          ),
          if (values == null)
            Text(
              context.strings.reports_distribution_unavailable,
              style: Styles.textStyle14.copyWith(color: AppColors.grey4),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 18,
                child: total == 0
                    ? ColoredBox(color: AppColors.grey5)
                    : Row(
                        children: [
                          for (final row in values)
                            if (row.count > 0)
                              Expanded(
                                flex: row.count,
                                child: ColoredBox(color: _color(row.status)),
                              ),
                        ],
                      ),
              ),
            ),
            for (final row in values)
              Row(
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: _color(row.status),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _label(context, row.status),
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.grey4,
                      ),
                    ),
                  ),
                  Text(
                    '${row.count}  (${row.percentage.toStringAsFixed(1)}%)',
                    textDirection: TextDirection.ltr,
                    style: Styles.textStyle14.copyWith(color: AppColors.black1),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
