import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class NotificationsShimmer extends StatelessWidget {
  const NotificationsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey3,
      highlightColor: AppColors.white0,
      child: ListView.separated(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 18, 16, 145),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => const ShimmerBox(height: 150, radius: 20),
      ),
    );
  }
}
