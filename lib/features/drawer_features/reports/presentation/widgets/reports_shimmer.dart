import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class ReportsShimmer extends StatelessWidget {
  const ReportsShimmer({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.grey3,
    highlightColor: AppColors.white0,
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShimmerBox(height: 170),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: ShimmerBox(height: 100)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 100)),
          ],
        ),
        SizedBox(height: 16),
        ShimmerBox(height: 180),
      ],
    ),
  );
}
