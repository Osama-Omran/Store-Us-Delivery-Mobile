import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_avatar.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_filters.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_metrics.dart';

class TopRankWinnerCard extends StatelessWidget {
  const TopRankWinnerCard({
    super.key,
    required this.entry,
    required this.role,
    required this.onDetails,
  });

  final TopRankEntry entry;
  final TopRankRole role;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.rankWinnerBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.rankTeal.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TopRankAvatar(entry: entry, size: 72, isWinner: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.winnerLabel(context),
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.rankTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      entry.name,
                      style: Styles.textStyle20.copyWith(
                        color: AppColors.black1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.rankGoldLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.ltr,
                  spacing: 3,
                  children: [
                    Text(
                      '#${entry.rank}',
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.black1,
                      ),
                    ),
                    Icon(
                      Icons.workspace_premium_outlined,
                      size: 16,
                      color: AppColors.rankGold,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${entry.score}',
                    style: Styles.textStyle24.copyWith(
                      fontSize: 30,
                      height: 1.2,
                      color: AppColors.black1,
                    ),
                  ),
                  TextSpan(
                    text: ' / 100',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.grey4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              textDirection: TextDirection.ltr,
            ),
          ),
          const SizedBox(height: 6),
          TopRankMetrics(entry: entry),
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton(
                key: const ValueKey('top-rank-winner-details'),
                onPressed: onDetails,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  alignment: AlignmentDirectional.centerStart,
                ),
                child: Text(
                  context.strings.top_rank_view_details,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
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
