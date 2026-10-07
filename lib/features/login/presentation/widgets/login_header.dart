import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_svg.dart';
import 'package:storeus_delivery/core/widgets/custom_text.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .4),
                blurRadius: 3,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: CustomSVG(assetName: AppAssets.van, w: 70),
        ),
        CustomText(
          context.strings.store_us_delivery,
          style: Styles.textStyle16,
        ),
        CustomText(
          context.strings.delivery_agent_app,
          style: Styles.textStyle10,
        ),
      ],
    );
  }
}
