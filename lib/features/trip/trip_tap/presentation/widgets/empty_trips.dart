import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_button.dart';
import 'package:storeus_delivery/core/widgets/custom_svg.dart';

class EmptyTrips extends StatelessWidget {
  const EmptyTrips({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 160),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.orange1,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(20),
            child: Icon(
              Icons.lock_outline_rounded,
              color: AppColors.orange0,
              size: 80,
            ),
          ),
          const Gap(30),
          Text(
            context.strings.trip_orders_are_unavailable,
            style: Styles.textStyle20,
          ),
          const Gap(12),
          Text(context.strings.you_must_confirm_receiving_van_and_goods_first),
          const Gap(30),
          Container(
            decoration: BoxDecoration(
              color: AppColors.orange1,
              border: Border.all(color: AppColors.orange0),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Row(
                  spacing: 6,
                  children: [
                    Icon(Icons.timelapse, color: AppColors.orange0),
                    Text(
                      context
                          .strings
                          .you_have_a_new_trip_awaiting_for_receiving_confirmation,
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.orange0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Text(
                  'رحلة #TRIP-0025 • مخزن الجيزة الرئيسي',
                  style: Styles.textStyle12,
                ),
              ],
            ),
          ),
          const Gap(30),
          CustomButton(
            text: context.strings.review_and_receive_van,
            icon: CustomSVG(assetName: AppAssets.van),
            icon1st: true,
            onPressed: () => GoRouter.of(context).push(RoutesNames.receiveTrip),
          ),
        ],
      ),
    );
  }
}
