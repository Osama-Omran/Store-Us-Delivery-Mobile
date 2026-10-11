
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_avatar.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_metrics.dart';

class TopRankList extends StatelessWidget {
  const TopRankList({
    super.key,
    required this.entries,
    required this.role,
    required this.onDetails,
  });

  final List<TopRankEntry> entries;
  final TopRankRole role;
  final ValueChanged<TopRankEntry> onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.grey3),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int index = 0; index < entries.length; index++) ...[
            if (index > 0)
              Divider(height: 1, color: AppColors.grey3),
            _TopRankRow(
              entry: entries[index],
              role: role,
              onTap: () => onDetails(entries[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopRankRow extends StatelessWidget {
  const _TopRankRow({
    required this.entry,
    required this.role,
    required this.onTap,
  });

  final TopRankEntry entry;
  final TopRankRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: entry.rank == 1
                    ? AppColors.rankGoldLight
                    : AppColors.grey5,
                shape: BoxShape.circle,
              ),
              child: Text(
                entry.rank == null ? '—' : '${entry.rank}',
                style: Styles.textStyle16.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),

            TopRankAvatar(
              entry: entry,
              role: role,
              size: 42,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    entry.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.black1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    entry.provisional
                        ? 'تقييم مبدئي'
                        : 'التقييم المعتمد',
                    style: Styles.textStyle12.copyWith(
                      color: entry.provisional
                          ? AppColors.orange0
                          : AppColors.grey4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              children: [
                Text(
                  formatRankNumber(entry.score),
                  style: Styles.textStyle20.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TopRankMovement(movement: entry.movement),
              ],
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.grey4,
            ),
          ],
        ),
      ),
    );
  }
}
