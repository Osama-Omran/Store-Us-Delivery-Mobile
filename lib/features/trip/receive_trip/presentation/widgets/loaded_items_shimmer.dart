import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/shimmer_box.dart';

class LoadedItemsShimmer extends StatelessWidget {
  const LoadedItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: [
      Text(context.strings.loaded_goods_details, style: Styles.textStyle18),
      Shimmer.fromColors(
        baseColor: AppColors.grey3,
        highlightColor: AppColors.white0,
        child: const Column(
          spacing: 16,
          children: [ShimmerBox(height: 110), ShimmerBox(height: 160)],
        ),
      ),
    ],
  );
}
