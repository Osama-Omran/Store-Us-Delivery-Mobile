import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_avatar.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_metrics.dart';

Future<void> showTopRankDetails(BuildContext context, TopRankEntry entry) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.white0,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          key: const ValueKey('top-rank-details-sheet'),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TopRankAvatar(entry: entry, size: 60),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.name,
                      style: Styles.textStyle20.copyWith(
                        color: AppColors.black1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (entry.isQualified) ...[
                Text(
                  '${context.strings.top_rank_position} #${entry.rank}',
                  style: Styles.textStyle16.copyWith(color: AppColors.black1),
                ),
                const SizedBox(height: 8),
                Text(
                  '${context.strings.top_rank_score}: ${entry.score} / 100',
                  style: Styles.textStyle24.copyWith(color: AppColors.black1),
                ),
              ] else
                Text(
                  context.strings.top_rank_unqualified,
                  style: Styles.textStyle16.copyWith(color: AppColors.orange0),
                ),
              const SizedBox(height: 20),
              TopRankMetrics(entry: entry),
              if (entry.isQualified) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.strings.top_rank_movement,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.grey4,
                        ),
                      ),
                    ),
                    TopRankMovement(movement: entry.movement),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
