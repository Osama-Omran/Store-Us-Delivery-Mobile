
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_avatar.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_metrics.dart';

class TopRankWinnerCard extends StatelessWidget {
  const TopRankWinnerCard({
    super.key,
    required this.entry,
    required this.role,
    required this.winnerLabel,
    required this.onDetails,
  });

  final TopRankEntry entry;
  final TopRankRole role;
  final String winnerLabel;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.rankWinnerBackground,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: AppColors.blue3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TopRankAvatar(
                entry: entry,
                role: role,
                size: 72,
                isWinner: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      winnerLabel,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      entry.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.textStyle20.copyWith(
                        color: AppColors.black1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (entry.rank != null)
                Chip(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.rankGoldLight,
                  label: Text(
                    '#${entry.rank}',
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.black1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                '${formatRankNumber(entry.score)} / 100',
                textDirection: TextDirection.ltr,
                style: Styles.textStyle24.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              if (entry.provisional)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    context.strings.top_rank_provisional,
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.orange0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          TopRankMetrics(entry: entry),

          const SizedBox(height: 14),

          Row(
            children: [
              TextButton(
                onPressed: onDetails,
                child: Text(
                  context.strings.top_rank_view_details,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              TopRankMovement(movement: entry.movement),
            ],
          ),
        ],
      ),
    );
  }
}
