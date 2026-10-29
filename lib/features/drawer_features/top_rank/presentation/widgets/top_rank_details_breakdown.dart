import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/top_rank_entry.dart';
import '../cubit/top_rank_details_cubit.dart';
import 'top_rank_metrics.dart';

class TopRankDetailsBreakdown extends StatelessWidget {
  const TopRankDetailsBreakdown({super.key});
  @override
  Widget build(BuildContext context) {
    final entry = context.read<TopRankDetailsCubit>().state.entry;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [
        // ======= Breakdown ======= //
        Text(
          context.strings.top_rank_points_breakdown,
          style: Styles.textStyle20.copyWith(color: AppColors.black1),
        ),

        for (final metric in entry.metrics) _MetricProgress(metric: metric),

        Divider(color: AppColors.grey3),

        Row(
          children: [
            Expanded(
              child: Text(
                context.strings.top_rank_total,
                style: Styles.textStyle18.copyWith(color: AppColors.black1),
              ),
            ),
            Text(
              '${formatRankNumber(entry.score)} / 100',
              textDirection: TextDirection.ltr,
              style: Styles.textStyle18.copyWith(color: AppColors.black1),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricProgress extends StatelessWidget {
  const _MetricProgress({required this.metric});

  final TopRankMetric metric;

  @override
  Widget build(BuildContext context) {
    final available = metric.hasCalculatedPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                rankMetricLabel(context, metric),
                style: Styles.textStyle14.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              available
                  ? '${formatRankNumber(metric.points)} / ${formatRankNumber(metric.weight)}'
                  : context.strings.top_rank_unavailable,
              textDirection: TextDirection.ltr,
              style: Styles.textStyle14.copyWith(
                color: available ? AppColors.black1 : AppColors.grey4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: LinearProgressIndicator(
            value: available ? metric.progress : 0,
            minHeight: 10,
            backgroundColor: AppColors.grey5,
            valueColor: AlwaysStoppedAnimation(
              available ? AppColors.primary : AppColors.grey3,
            ),
          ),
        ),

        if (metric.value != null || metric.target != null)
          Text(
            context.strings.top_rank_metric_target(
              formatRankMetric(metric),
              metric.target == null
                  ? context.strings.top_rank_unavailable
                  : formatRankNumber(metric.target),
            ),
            style: Styles.textStyle12.copyWith(color: AppColors.grey4),
          ),
      ],
    );
  }
}
