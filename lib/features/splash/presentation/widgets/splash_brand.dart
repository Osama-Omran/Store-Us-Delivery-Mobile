import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/widgets/custom_image.dart';

class SplashBrand extends StatelessWidget {
  const SplashBrand({
    super.key,
    required this.logoSize,
    required this.isCompact,
  });

  final double logoSize;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ===== Logo Card =====
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.white0.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(39),
            border: Border.all(color: AppColors.white0.withValues(alpha: .26)),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white0,
              borderRadius: BorderRadius.circular(31),
              boxShadow: [
                BoxShadow(
                  color: AppColors.splashShadow.withValues(alpha: .28),
                  blurRadius: 38,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: CustomImage(
              imagePath: AppAssets.logo,
              w: logoSize,
              h: logoSize,
            ),
          ),
        ),

        const SizedBox(height: 26),

        // ===== Decorative Divider =====
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.white0.withValues(alpha: .80),
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          context.strings.splash_tagline,
          textAlign: TextAlign.center,
          style: Styles.base.copyWith(
            fontSize: isCompact ? 13 : 15,
            fontWeight: FontWeight.w600,
            color: AppColors.white0.withValues(alpha: .90),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
