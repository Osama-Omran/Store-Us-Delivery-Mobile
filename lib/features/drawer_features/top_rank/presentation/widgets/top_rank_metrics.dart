
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';

String formatRankNumber(num? number) {
  if (number == null) return '—';

  final value = number.toDouble();

  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }

  if (value.abs() < 1) {
    return value.toStringAsFixed(2);
  }

  return value.toStringAsFixed(1);
}

String formatRankMetric(TopRankMetric metric) {
  if (metric.value == null) return '—';

  final number = formatRankNumber(metric.value);
  final unit = metric.unit?.trim() ?? '';

  if (unit.isEmpty) return number;
  if (unit == '%') return '$number%';

  return '$number $unit';
}

class TopRankMetrics extends StatelessWidget {
  const TopRankMetrics({
    super.key,
    required this.entry,
    this.maxRows = 3,
  });

  final TopRankEntry entry;
  final int maxRows;

  @override
  Widget build(BuildContext context) {
    final metrics = entry.metrics.take(maxRows).toList();

    if (metrics.isEmpty) {
      return Text(
        'لا توجد مؤشرات أداء متاحة',
        style: Styles.textStyle14.copyWith(
          color: AppColors.grey4,
        ),
      );
    }

    return Column(
      spacing: 5,
      children: [
        for (final metric in metrics)
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.grey4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                formatRankMetric(metric),
                textDirection: TextDirection.ltr,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class TopRankMovement extends StatelessWidget {
  const TopRankMovement({
    super.key,
    required this.movement,
  });

  final int? movement;

  @override
  Widget build(BuildContext context) {
    if (movement == null) {
      return Text(
        'غير متاح',
        style: Styles.textStyle12.copyWith(
          color: AppColors.grey4,
        ),
      );
    }

    if (movement == 0) {
      return Text(
        'بدون تغيير',
        style: Styles.textStyle12.copyWith(
          color: AppColors.grey4,
        ),
      );
    }

    final improved = movement! > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          improved
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded,
          color: improved ? AppColors.green0 : AppColors.red1,
          size: 16,
        ),
        Text(
          '${movement!.abs()}',
          style: Styles.textStyle12.copyWith(
            color: improved ? AppColors.green0 : AppColors.red1,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
