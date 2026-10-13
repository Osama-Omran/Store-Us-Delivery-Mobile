import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'reports_card.dart';

class ReportsStatistics extends StatelessWidget {
  const ReportsStatistics({super.key, required this.summary});

  final ReportsSummary summary;

  @override
  Widget build(BuildContext context) => Column(
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: _StatisticCard(
                  key: const ValueKey('reports-total'),
                  value: summary.totalOrders,
                  label: context.strings.reports_total_orders,
                  color: AppColors.black1,
                ),
              ),
              Expanded(
                child: _StatisticCard(
                  key: const ValueKey('reports-delivered'),
                  value: summary.deliveredOrders,
                  label: context.strings.reports_delivered,
                  color: AppColors.green0,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: _StatisticCard(
                  key: const ValueKey('reports-partial'),
                  value: summary.partialOrders,
                  label: context.strings.reports_partial,
                  color: AppColors.orange0,
                ),
              ),
              Expanded(
                child: _StatisticCard(
                  key: const ValueKey('reports-undelivered'),
                  value: summary.undeliveredOrders,
                  label: context.strings.reports_undelivered,
                  color: AppColors.red1,
                ),
              ),
            ],
          ),
        ],
      );
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  final int? value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => ReportsCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value?.toString() ?? '—',
              style: Styles.textStyle24.copyWith(
                color: color,
                fontSize: 28,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Styles.textStyle12.copyWith(
                color: AppColors.grey4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
}
