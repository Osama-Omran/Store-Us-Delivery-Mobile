import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class HomeCurrentTripShimmer extends StatelessWidget {
  const HomeCurrentTripShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey3,
      highlightColor: AppColors.white0,
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            ShimmerBox(height: 28),
            ShimmerBox(height: 146, radius: 20),
            Row(
              spacing: 8,
              children: [
                Expanded(child: ShimmerBox(height: 94, radius: 18)),
                Expanded(child: ShimmerBox(height: 94, radius: 18)),
                Expanded(child: ShimmerBox(height: 94, radius: 18)),
              ],
            ),
            ShimmerBox(height: 60, radius: 20),
            ShimmerBox(height: 60, radius: 20),
          ],
        ),
      ),
    );
  }
}

class HomeHistoryShimmer extends StatelessWidget {
  const HomeHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey3,
      highlightColor: AppColors.white0,
      child: const ShimmerBox(height: 105, radius: 20),
    );
  }
}
