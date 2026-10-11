import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_card.dart';

class ReportsDistributionCard extends StatelessWidget {
  const ReportsDistributionCard({super.key, required this.summary});

  final ReportsSummary summary;

  @override
  Widget build(BuildContext context) {
    return ReportsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            context.strings.reports_order_distribution,
            style: Styles.textStyle18.copyWith(color: AppColors.black1),
          ),
          Semantics(
            label: context.strings.reports_order_distribution,
            value:
                '${context.strings.reports_delivered}: ${summary.deliveredOrders}, ${context.strings.reports_partial}: ${summary.partialOrders}, ${context.strings.reports_undelivered}: ${summary.undeliveredOrders}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 20,
                child: summary.totalOrders == 0
                    ? ColoredBox(color: AppColors.grey5)
                    : Row(
                        children: [
                          if (summary.deliveredOrders > 0)
                            Expanded(
                              flex: summary.deliveredOrders,
                              child: ColoredBox(
                                key: const ValueKey(
                                  'reports-distribution-delivered',
                                ),
                                color: AppColors.green0,
                                child: const SizedBox.expand(),
                              ),
                            ),
                          if (summary.partialOrders > 0)
                            Expanded(
                              flex: summary.partialOrders,
                              child: ColoredBox(
                                key: const ValueKey(
                                  'reports-distribution-partial',
                                ),
                                color: AppColors.orange0,
                                child: const SizedBox.expand(),
                              ),
                            ),
                          if (summary.undeliveredOrders > 0)
                            Expanded(
                              flex: summary.undeliveredOrders,
                              child: ColoredBox(
                                key: const ValueKey(
                                  'reports-distribution-undelivered',
                                ),
                                color: AppColors.red1,
                                child: const SizedBox.expand(),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
