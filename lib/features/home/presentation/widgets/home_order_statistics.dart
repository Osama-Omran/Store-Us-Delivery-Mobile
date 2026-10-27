import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class HomeOrderStatistics extends StatelessWidget {
  const HomeOrderStatistics({
    super.key,
    required this.total,
    required this.delivered,
    required this.remaining,
  });

  final int? total;
  final int? delivered;
  final int? remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OrderStatCard(
            count: total,
            label: context.strings.order,
            backgroundColor: AppColors.white0,
            countColor: AppColors.primary,
            labelColor: AppColors.grey4,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _OrderStatCard(
            count: delivered,
            label: context.strings.delivered_orders,
            backgroundColor: AppColors.green1,
            countColor: AppColors.green0,
            labelColor: AppColors.green0,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _OrderStatCard(
            count: remaining,
            label: context.strings.remaining_orders,
            backgroundColor: AppColors.orange1,
            countColor: AppColors.orange0,
            labelColor: AppColors.orange0,
          ),
        ),
      ],
    );
  }
}

class _OrderStatCard extends StatelessWidget {
  const _OrderStatCard({
    required this.count,
    required this.label,
    required this.backgroundColor,
    required this.countColor,
    required this.labelColor,
  });

  final int? count;
  final String label;
  final Color backgroundColor;
  final Color countColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: textScaler.scale(27) * 1.2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                count?.toString() ?? '—',
                maxLines: 1,
                softWrap: false,
                style: Styles.textStyle27.copyWith(
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: countColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: textScaler.scale(12) * 1.3 * 2,
            child: Center(
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Styles.base.copyWith(
                  fontSize: 12,
                  height: 1.3,
                  color: labelColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
