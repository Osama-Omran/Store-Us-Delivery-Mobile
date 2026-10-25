import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/cubit/top_rank_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/cubit/top_rank_state.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_details_sheet.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_filters.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_header.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_list.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_winner_card.dart';

class TopRankScreen extends StatelessWidget {
  const TopRankScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TopRankCubit>()..load(fetchAllCategories: true),
      child: _TopRankBody(onBack: onBack),
    );
  }
}

class _TopRankBody extends StatelessWidget {
  const _TopRankBody({required this.onBack});

  final VoidCallback onBack;

  void _openDetails(
    BuildContext context,
    TopRankState state,
    TopRankEntry entry,
  ) {
    showTopRankDetails(
      context,
      entry,
      role: state.role,
      period: state.period,
      leader: state.winner,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              TopRankHeader(onBack: onBack),

              Expanded(
                child: BlocBuilder<TopRankCubit, TopRankState>(
                  builder: (context, state) {
                    final cubit = TopRankCubit.get(context);
                    final category = state.category;
                    final winner = state.winner;

                    return RefreshIndicator(
                      onRefresh: () => cubit.load(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 145),
                        children: [
                          // ======= Intro ======= //
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.rankNavy,
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                Text(
                                  context.strings.top_rank,
                                  style: Styles.textStyle24.copyWith(
                                    color: AppColors.white0,
                                  ),
                                ),
                                Text(
                                  context.strings.top_rank_intro,
                                  style: Styles.textStyle14.copyWith(
                                    color: AppColors.grey2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ======= Filters ======= //
                          TopRankFilters(
                            period: state.period,
                            role: state.role,
                            onPeriodChanged: cubit.selectPeriod,
                            onRoleChanged: cubit.selectRole,
                          ),

                          const SizedBox(height: 22),

                          if (state.isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (state.error != null)
                            _TopRankMessage(
                              message: state.error!,
                              onRetry: cubit.retry,
                            )
                          else if (category == null)
                            _TopRankMessage(
                              message: context.strings.top_rank_empty,
                            )
                          else ...[
                            // ======= Winner ======= //
                            if (winner != null) ...[
                              Text(
                                'الفائز — ${category.winnerLabel}',
                                style: Styles.textStyle20.copyWith(
                                  color: AppColors.black1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),

                              TopRankWinnerCard(
                                entry: winner,
                                role: state.role,
                                winnerLabel: category.winnerLabel,
                                onDetails: () =>
                                    _openDetails(context, state, winner),
                              ),

                              const SizedBox(height: 25),
                            ],

                            Row(
                              children: [
                                Icon(state.role.icon, color: AppColors.primary),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    category.label,
                                    style: Styles.textStyle20.copyWith(
                                      color: AppColors.black1,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${category.pagination.total}',
                                  style: Styles.textStyle14.copyWith(
                                    color: AppColors.grey4,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            if (state.entries.isEmpty)
                              _TopRankMessage(
                                message: context.strings.top_rank_empty,
                              )
                            else
                              TopRankList(
                                entries: state.entries,
                                role: state.role,
                                onDetails: (entry) =>
                                    _openDetails(context, state, entry),
                              ),

                            // ======= Pagination Information ======= //
                            if (category.pagination.lastPage > 1) ...[
                              const SizedBox(height: 12),
                              Text(
                                'تم عرض الصفحة '
                                '${category.pagination.page} من '
                                '${category.pagination.lastPage}',
                                textAlign: TextAlign.center,
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.grey4,
                                ),
                              ),
                            ],

                            // ======= API Data Warnings ======= //
                            if (state.warnings.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              ExpansionTile(
                                title: Text(
                                  context.strings.top_rank_data_notes,
                                  style: Styles.textStyle14.copyWith(
                                    color: AppColors.black1,
                                  ),
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            message,
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
