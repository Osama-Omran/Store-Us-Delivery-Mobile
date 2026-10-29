import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/top_rank_entry.dart';
import '../cubit/top_rank_details_cubit.dart';
import 'top_rank_metrics.dart';
import 'top_rank_avatar.dart';

class TopRankDetailsHeader extends StatelessWidget {
  const TopRankDetailsHeader({super.key, required this.role});
  final TopRankRole role;
  @override
  Widget build(BuildContext context) {
    final entry = context.read<TopRankDetailsCubit>().state.entry;
    return Column(
      spacing: 20,
      children: [
        // ======= Header ======= //
        Row(
          children: [
            TopRankAvatar(entry: entry, role: role, size: 68),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.name,
                style: Styles.textStyle22.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: context.strings.top_rank_current_rank,
                value: entry.rank == null ? '—' : '#${entry.rank}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                label: context.strings.top_rank_score,
                value: '${formatRankNumber(entry.score)} / 100',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey5,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        spacing: 8,
        children: [
          Text(
            label,
            style: Styles.textStyle12.copyWith(color: AppColors.grey4),
          ),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: Styles.textStyle20.copyWith(color: AppColors.black1),
          ),
        ],
      ),
    );
  }
}
