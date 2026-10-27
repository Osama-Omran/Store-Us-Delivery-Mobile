import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
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

/// Keep genuine backend labels, but never expose a missing label's machine key.
String rankMetricLabel(BuildContext context, TopRankMetric metric) {
  final label = metric.label.trim();
  return label.isEmpty || label == metric.key
      ? context.strings.top_rank_metric_unknown
      : metric.label;
}

class TopRankMetrics extends StatelessWidget {
  const TopRankMetrics({super.key, required this.entry, this.maxRows = 3});

  final TopRankEntry entry;
  final int maxRows;

  @override
  Widget build(BuildContext context) {
    final metrics = entry.metrics.take(maxRows).toList();

    if (metrics.isEmpty) {
      return Text(
        context.strings.top_rank_no_metrics,
        style: Styles.textStyle14.copyWith(color: AppColors.grey4),
      );
    }

    return Column(
      spacing: 5,
      children: [
        for (final metric in metrics)
          LayoutBuilder(
            builder: (context, constraints) {
              final label = Text(
                rankMetricLabel(context, metric),
                style: Styles.textStyle12.copyWith(color: AppColors.grey4),
              );
              final value = Text(
                formatRankMetric(metric),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.end,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w800,
                ),
              );
              if (constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(16) > 20) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 4,
                  children: [label, value],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Expanded(child: label),
                  Flexible(child: value),
                ],
              );
            },
          ),
      ],
    );
  }
}

class TopRankMovement extends StatelessWidget {
  const TopRankMovement({super.key, required this.movement});

  final int? movement;

  @override
  Widget build(BuildContext context) {
    if (movement == null) {
      return Text(
        context.strings.top_rank_unavailable,
        style: Styles.textStyle12.copyWith(color: AppColors.grey4),
      );
    }

    if (movement == 0) {
      return Text(
        context.strings.top_rank_no_movement,
        style: Styles.textStyle12.copyWith(color: AppColors.grey4),
      );
    }

    final improved = movement! > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          improved ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
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
