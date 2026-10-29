import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class TripCustomersShimmer extends StatelessWidget {
  const TripCustomersShimmer({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.grey3,
    highlightColor: AppColors.white0,
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShimmerBox(height: 180, radius: 20),
        SizedBox(height: 13),
        ShimmerBox(height: 180, radius: 20),
        SizedBox(height: 13),
        ShimmerBox(height: 180, radius: 20),
      ],
    ),
  );
}
