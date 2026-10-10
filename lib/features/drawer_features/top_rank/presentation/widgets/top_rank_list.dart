import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_avatar.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_metrics.dart';

class TopRankList extends StatelessWidget {
  const TopRankList({
    super.key,
    required this.entries,
    required this.onDetails,
  });

  final List<TopRankEntry> entries;
  final ValueChanged<TopRankEntry> onDetails;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: AppColors.grey3),
      ),
      child: Column(
        children: [
          for (var index = 0; index < entries.length; index++) ...[
            if (index > 0) Divider(height: 1, color: AppColors.grey3),
            _TopRankRow(
              key: ValueKey('top-rank-entry-${entries[index].id}'),
              entry: entries[index],
              onTap: () => onDetails(entries[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopRankRow extends StatelessWidget {
  const _TopRankRow({super.key, required this.entry, required this.onTap});

  final TopRankEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 400;
        final size = compact ? 36.0 : 44.0;

        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.rank == 1
                        ? AppColors.rankGoldLight
                        : AppColors.grey5,
                  ),
                  child: Text(
                    '${entry.rank ?? '—'}',
                    style: Styles.textStyle18.copyWith(
                      color: entry.rank == 1
                          ? AppColors.black1
                          : AppColors.grey4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (entry.isQualified) ...[
                  TopRankAvatar(entry: entry, size: size),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        entry.name,
                        style: Styles.textStyle18.copyWith(
                          color: AppColors.black1,
                        ),
                      ),
                      Text(
                        entry.isQualified
                            ? '${context.strings.top_rank_delivery} ${entry.deliveryPercentage ?? '—'}% · '
                                  '${context.strings.top_rank_collection} ${entry.collectionPercentage ?? '—'}%'
                            : context.strings.top_rank_unqualified,
                        style: Styles.textStyle12.copyWith(
                          fontSize: compact ? 10 : 12,
                          fontWeight: entry.isQualified
                              ? FontWeight.w400
                              : FontWeight.w700,
                          color: entry.isQualified
                              ? AppColors.grey4
                              : AppColors.orange0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.isQualified) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${entry.score}',
                    textDirection: TextDirection.ltr,
                    style: Styles.textStyle24.copyWith(
                      fontSize: compact ? 22 : 24,
                      color: AppColors.black1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TopRankMovement(movement: entry.movement),
                ],
                const SizedBox(width: 8),
                Icon(
                  context.isArabic
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: AppColors.grey4,
                  size: 20,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
