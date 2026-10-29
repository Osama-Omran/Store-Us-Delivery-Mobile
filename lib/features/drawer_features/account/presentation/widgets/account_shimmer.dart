import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_surface_card.dart';

class AccountShimmer extends StatelessWidget {
  const AccountShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey3,
      highlightColor: AppColors.white0,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          AccountSurfaceCard(
            child: Row(
              children: [
                ShimmerBox(radius: 12, width: 72, height: 72),
                Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(radius: 12, width: 148, height: 20),
                      Gap(12),
                      ShimmerBox(radius: 12, width: 110, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Gap(16),
          AccountSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(radius: 12, width: 140, height: 20),
                Gap(24),
                ShimmerBox(radius: 12, height: 16),
                Gap(20),
                ShimmerBox(radius: 12, height: 16),
                Gap(20),
                ShimmerBox(radius: 12, height: 16),
                Gap(20),
                ShimmerBox(radius: 12, height: 16),
                Gap(24),
                ShimmerBox(radius: 12, height: 48),
              ],
            ),
          ),
          Gap(16),
          AccountSurfaceCard(child: ShimmerBox(radius: 12, height: 48)),
          Gap(16),
          ShimmerBox(radius: 12, height: 100),
        ],
      ),
    );
  }
}
