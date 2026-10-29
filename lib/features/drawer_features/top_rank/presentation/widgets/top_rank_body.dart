import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../cubit/top_rank_cubit.dart';
import 'top_rank_header.dart';
import 'top_rank_intro.dart';
import 'top_rank_filters.dart';
import 'top_rank_results.dart';

class TopRankBody extends StatelessWidget {
  const TopRankBody({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopRankHeader(onBack: onBack),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => TopRankCubit.get(context).load(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 145),
                  children: const [
                    TopRankIntro(),
                    SizedBox(height: 18),
                    TopRankFilters(),
                    SizedBox(height: 22),
                    TopRankResults(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
