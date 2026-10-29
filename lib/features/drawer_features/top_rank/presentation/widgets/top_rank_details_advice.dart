import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/top_rank_entry.dart';
import '../cubit/top_rank_details_cubit.dart';
import 'top_rank_metrics.dart';

class TopRankDetailsAdvice extends StatelessWidget {
  const TopRankDetailsAdvice({super.key, this.leader});
  final TopRankEntry? leader;

  @override
  Widget build(BuildContext context) {
    final entry = context.read<TopRankDetailsCubit>().state.entry;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [
        // ======= Strengths ======= //
        if (entry.advice.strengths.isNotEmpty) ...[
          Text(
            context.strings.top_rank_strengths_title,
            style: Styles.textStyle18.copyWith(color: AppColors.black1),
          ),
          for (final strength in entry.advice.strengths)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.green0,
                  size: 21,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    strength,
                    style: Styles.textStyle16.copyWith(color: AppColors.black1),
                  ),
                ),
              ],
            ),
        ],

        // ======= Improvement Advice ======= //
        if (entry.advice.actions.isNotEmpty) ...[
          Text(
            context.strings.top_rank_improve_title,
            style: Styles.textStyle18.copyWith(color: AppColors.black1),
          ),
          for (final action in entry.advice.actions)
            _AdviceCard(action: action),
        ],

        // ======= Compare With Leader ======= //
        if (leader != null &&
            leader!.id != entry.id &&
            leader!.score != null &&
            entry.score != null &&
            entry.gap != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue4,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Text(
                  context.strings.top_rank_compare_leader,
                  style: Styles.textStyle18.copyWith(color: AppColors.black1),
                ),
                _CompareRow(
                  label: context.strings.top_rank_your_score,
                  value: formatRankNumber(entry.score),
                ),
                _CompareRow(
                  label: context.strings.top_rank_leader_score,
                  value: formatRankNumber(leader!.score),
                ),
                _CompareRow(
                  label: context.strings.top_rank_difference,
                  value: formatRankNumber(entry.gap),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.action});

  final TopRankAdviceAction action;

  @override
  Widget build(BuildContext context) {
    final isDataIssue = action.priority == 'data';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 9,
        children: [
          Row(
            children: [
              Icon(
                isDataIssue
                    ? Icons.info_outline_rounded
                    : Icons.trending_up_rounded,
                color: isDataIssue ? AppColors.orange0 : AppColors.green0,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isDataIssue
                      ? context.strings.top_rank_data_insufficient
                      : context.strings.top_rank_improvement_opportunity,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (action.impact != null)
                Text(
                  context.strings.top_rank_impact_points(
                    formatRankNumber(action.impact),
                  ),
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.green0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          Text(
            action.message,
            style: Styles.textStyle14.copyWith(color: AppColors.black1),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: Styles.textStyle16.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}
