import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class TripOrdersShimmer extends StatelessWidget {
  const TripOrdersShimmer({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.grey3,
    highlightColor: AppColors.white0,
    child: const Column(
      spacing: 13,
      children: [ShimmerBox(height: 210), ShimmerBox(height: 210)],
    ),
  );
}
