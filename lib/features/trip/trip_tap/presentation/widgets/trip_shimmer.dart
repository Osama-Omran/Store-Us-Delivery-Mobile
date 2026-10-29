import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class TripShimmer extends StatelessWidget {
  const TripShimmer({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.grey3,
    highlightColor: AppColors.white0,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerBox(height: 70),
        SizedBox(height: 18),
        ShimmerBox(height: 350),
        SizedBox(height: 26),
        ShimmerBox(width: 150, height: 24),
        SizedBox(height: 15),
        ShimmerBox(height: 42),
        SizedBox(height: 16),
        ShimmerBox(height: 210),
      ],
    ),
  );
}
