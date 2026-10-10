import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class TreasuryHeader extends StatelessWidget {
  const TreasuryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.grey0,
        border: Border(bottom: BorderSide(color: AppColors.grey3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          Text(
            context.strings.treasury,
            style: Styles.textStyle24.copyWith(color: AppColors.black1),
          ),
          Text(
            context.strings.treasury_subtitle,
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
        ],
      ),
    );
  }
}
