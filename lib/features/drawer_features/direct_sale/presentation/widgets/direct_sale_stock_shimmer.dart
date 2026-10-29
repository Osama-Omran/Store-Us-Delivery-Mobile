import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class DirectSaleStockShimmer extends StatelessWidget {
  const DirectSaleStockShimmer({super.key, this.customer = false});
  final bool customer;
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.grey3,
    highlightColor: AppColors.white0,
    child: customer
        ? const ShimmerBox(height: 60, radius: 18)
        : const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShimmerBox(height: 125, radius: 20),
              SizedBox(height: 12),
              ShimmerBox(height: 125, radius: 20),
              SizedBox(height: 12),
              ShimmerBox(height: 125, radius: 20),
            ],
          ),
  );
}
