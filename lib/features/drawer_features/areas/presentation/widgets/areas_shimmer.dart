import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class AreasShimmer extends StatelessWidget {
  const AreasShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey3,
      highlightColor: AppColors.white0,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Row(
            children: const [
              Expanded(child: ShimmerBox(radius: 18, height: 94)),
              SizedBox(width: 10),
              Expanded(child: ShimmerBox(radius: 18, height: 94)),
              SizedBox(width: 10),
              Expanded(child: ShimmerBox(radius: 18, height: 94)),
            ],
          ),
          const SizedBox(height: 20),
          const ShimmerBox(radius: 18, height: 48),
          const SizedBox(height: 20),
          const ShimmerBox(radius: 18, height: 78),
          const SizedBox(height: 20),
          for (var i = 0; i < 4; i++) ...[
            const ShimmerBox(radius: 18, height: 104),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
