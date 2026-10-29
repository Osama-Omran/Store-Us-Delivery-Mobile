import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class TopRankShimmer extends StatelessWidget {
  const TopRankShimmer({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.grey3,
    highlightColor: AppColors.white0,
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShimmerBox(height: 230, radius: 20),
        SizedBox(height: 25),
        ShimmerBox(width: 150, height: 24, radius: 6),
        SizedBox(height: 12),
        ShimmerBox(height: 250, radius: 20),
      ],
    ),
  );
}
