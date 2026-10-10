import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_svg.dart';
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
      create: (_) => getIt<TopRankCubit>(),
      child: _TopRankBody(onBack: onBack),
    );
  }
}

class _TopRankBody extends StatelessWidget {
  const _TopRankBody({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======= Header ======= //
            TopRankHeader(onBack: onBack),

            Expanded(
              child: BlocBuilder<TopRankCubit, TopRankState>(
                builder: (context, state) {
                  final cubit = TopRankCubit.get(context);
                  final winner = state.winner;

                  return ListView(
                    key: const ValueKey('top-rank-scroll'),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 125),
                    children: [
                      // ======= Introduction ======= //
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.rankNavy,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                CustomSVG(
                                  assetName: AppAssets.rankCrown,
                                  color: AppColors.rankGold,
                                  w: 26,
                                  h: 26,
                                ),
                                Expanded(
                                  child: Text(
                                    context.strings.top_rank,
                                    style: Styles.textStyle24.copyWith(
                                      color: AppColors.white0,
                                    ),
                                  ),
                                ),
                              ],
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
                      const SizedBox(height: 16),

                      // ======= Filters ======= //
                      TopRankFilters(
                        period: state.period,
                        role: state.role,
                        warehouse: state.warehouse,
                        onPeriodChanged: cubit.selectPeriod,
                        onRoleChanged: cubit.selectRole,
                        onWarehouseChanged: cubit.selectWarehouse,
                      ),
                      const SizedBox(height: 24),

                      // ======= Winner ======= //
                      if (winner != null) ...[
                        Text(
                          '${context.strings.top_rank_winner} — ${state.role.bestLabel(context)}',
                          style: Styles.textStyle20.copyWith(
                            color: AppColors.black1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TopRankWinnerCard(
                          entry: winner,
                          role: state.role,
                          onDetails: () => showTopRankDetails(context, winner),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ======= Rankings ======= //
                      Row(
                        spacing: 10,
                        children: [
                          Icon(
                            state.role.icon,
                            color: AppColors.rankTeal,
                            size: 24,
                          ),
                          Expanded(
                            child: Text(
                              state.role.bestLabel(context),
                              style: Styles.textStyle20.copyWith(
                                color: AppColors.black1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.entries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            context.strings.top_rank_empty,
                            textAlign: TextAlign.center,
                            style: Styles.textStyle16.copyWith(
                              color: AppColors.grey4,
                            ),
                          ),
                        )
                      else
                        TopRankList(
                          entries: state.entries,
                          onDetails: (entry) =>
                              showTopRankDetails(context, entry),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
