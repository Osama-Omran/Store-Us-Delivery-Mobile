import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/top_rank_cubit.dart';
import '../cubit/top_rank_state.dart';
import 'top_rank_filters.dart';
import 'top_rank_list.dart';
import 'top_rank_winner_card.dart';
import 'top_rank_shimmer.dart';

class TopRankResults extends StatelessWidget {
  const TopRankResults({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<TopRankCubit, TopRankState>(
    builder: (context, state) {
      final cubit = TopRankCubit.get(context);
      final category = state.category;
      final winner = state.winner;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isLoading)
            const TopRankShimmer()
          else if (state.error != null)
            _TopRankMessage(message: state.error!, onRetry: cubit.retry)
          else if (category == null)
            _TopRankMessage(message: context.strings.top_rank_empty)
          else ...[
            // ======= Winner ======= //
            if (winner != null) ...[
              Text(
                context.strings.top_rank_winner_label(category.winnerLabel),
                style: Styles.textStyle20.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              TopRankWinnerCard(),

              const SizedBox(height: 25),
            ],

            Row(
              children: [
                Icon(state.role.icon, color: AppColors.primary),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    state.role.label(context),
                    style: Styles.textStyle20.copyWith(color: AppColors.black1),
                  ),
                ),
                Text(
                  '${category.pagination.total}',
                  style: Styles.textStyle14.copyWith(color: AppColors.grey4),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (state.entries.isEmpty)
              _TopRankMessage(message: context.strings.top_rank_empty)
            else
              TopRankList(),

            // ======= Pagination Information ======= //
            if (category.pagination.lastPage > 1) ...[
              const SizedBox(height: 12),
              Text(
                context.strings.top_rank_page_summary(
                  category.pagination.page,
                  category.pagination.lastPage,
                ),
                textAlign: TextAlign.center,
                style: Styles.textStyle12.copyWith(color: AppColors.grey4),
              ),
            ],

            // ======= API Data Warnings ======= //
            if (state.warnings.isNotEmpty) ...[
              const SizedBox(height: 20),
              ExpansionTile(
                title: Text(
                  context.strings.top_rank_data_notes,
                  style: Styles.textStyle14.copyWith(color: AppColors.black1),
                ),
                children: [
                  for (final warning in state.warnings)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        warning,
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.grey4,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ],
      );
    },
  );
}

class _TopRankMessage extends StatelessWidget {
  const _TopRankMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        spacing: 14,
        children: [
          Icon(Icons.leaderboard_outlined, color: AppColors.primary, size: 43),
          Text(
            context.localizedErrorMessage(message),
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
          if (onRetry != null)
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.strings.trip_tab_retry),
            ),
        ],
      ),
    );
  }
}
