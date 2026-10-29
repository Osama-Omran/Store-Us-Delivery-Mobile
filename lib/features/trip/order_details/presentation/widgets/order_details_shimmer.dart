import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class OrderDetailsShimmer extends StatelessWidget {
  const OrderDetailsShimmer({super.key});
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.grey3,
    highlightColor: AppColors.white0,
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        ShimmerBox(height: 240),
        SizedBox(height: 20),
        ShimmerBox(height: 80),
        SizedBox(height: 20),
        ShimmerBox(height: 220),
      ],
    ),
  );
}
