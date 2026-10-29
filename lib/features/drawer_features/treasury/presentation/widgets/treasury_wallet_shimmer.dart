import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class TreasuryWalletShimmer extends StatelessWidget {
  const TreasuryWalletShimmer({super.key});
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.grey3,
    highlightColor: AppColors.white0,
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShimmerBox(width: 150, height: 24, radius: 6),
        SizedBox(height: 12),
        ShimmerBox(height: 180),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: ShimmerBox(height: 110)),
            SizedBox(width: 8),
            Expanded(child: ShimmerBox(height: 110)),
            SizedBox(width: 8),
            Expanded(child: ShimmerBox(height: 110)),
          ],
        ),
        SizedBox(height: 16),
        ShimmerBox(height: 64),
      ],
    ),
  );
}
