import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:flutter/material.dart';

import 'top_rank_details_advice.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/domain/usecases/get_top_rank_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/cubit/top_rank_details_cubit.dart';

import 'top_rank_details_header.dart';
import 'top_rank_details_breakdown.dart';

Future<void> showTopRankDetails(
  BuildContext context,
  TopRankEntry entry, {
  required TopRankRole role,
  required TopRankPeriod period,
  TopRankEntry? leader,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.white0,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .9,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => TopRankDetailsCubit(getIt<GetTopRankUsecase>(), entry)
        ..load(
          range: period.apiValue,
          category: role.apiValue,
          entity: entry.id,
        ),
      child: _TopRankDetailsContent(role: role, leader: leader),
    ),
  );
}

class _TopRankDetailsContent extends StatelessWidget {
  const _TopRankDetailsContent({required this.role, required this.leader});

  final TopRankRole role;
  final TopRankEntry? leader;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopRankDetailsCubit, TopRankDetailsState>(
      builder: (context, state) {
        final entry = state.entry;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  TopRankDetailsHeader(role: role),
                  if (entry.provisional)
                    _InfoBanner(text: context.strings.top_rank_data_incomplete),

                  if (state.loading)
                    LinearProgressIndicator(color: AppColors.primary),

                  if (state.error != null)
                    _InfoBanner(
                      text: context.strings.top_rank_details_refresh_failed,
                    ),

                  TopRankDetailsBreakdown(),
                  TopRankDetailsAdvice(leader: leader),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orange1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Styles.textStyle12.copyWith(color: AppColors.orange0),
      ),
    );
  }
}
