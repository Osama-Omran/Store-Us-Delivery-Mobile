import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class ReceiveTripShimmer extends StatelessWidget {
  const ReceiveTripShimmer({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.grey3,
    highlightColor: AppColors.white0,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerBox(height: 300),
        SizedBox(height: 24),
        ShimmerBox(width: 160, height: 22),
        SizedBox(height: 16),
        ShimmerBox(height: 120),
        SizedBox(height: 16),
        ShimmerBox(height: 180),
      ],
    ),
  );
}
