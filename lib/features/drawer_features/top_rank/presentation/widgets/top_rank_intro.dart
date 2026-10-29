import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class TopRankIntro extends StatelessWidget {
  const TopRankIntro({super.key});

  @override
  Widget build(BuildContext context) => Container(
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
          style: Styles.textStyle24.copyWith(color: AppColors.white0),
        ),
        Text(
          context.strings.top_rank_intro,
          style: Styles.textStyle14.copyWith(color: AppColors.grey2),
        ),
      ],
    ),
  );
}
