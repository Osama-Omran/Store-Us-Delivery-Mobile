import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

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
  Widget build(BuildContext context) => Row(
    spacing: 10,
    children: [
      Expanded(
        child: _OrderStatCard(
          count: total,
          label: context.strings.order,
          backgroundColor: AppColors.white0,
          countColor: AppColors.black1,
          labelColor: AppColors.grey4,
        ),
      ),

      Expanded(
        child: _OrderStatCard(
          count: delivered,
          label: context.strings.delivered_orders,
          backgroundColor: AppColors.green1,
          countColor: AppColors.green0,
          labelColor: AppColors.green0,
        ),
      ),

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
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          Text(
            count?.toString() ?? '—',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: countColor,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
        ],
      ),
    );
  }
}
