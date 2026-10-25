import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_button.dart';
import 'package:storeus_delivery/core/widgets/custom_svg.dart';

class EmptyTrips extends StatelessWidget {
  const EmptyTrips({
    super.key,
    required this.tripNumber,
    required this.warehouseName,
    required this.onReviewAndReceive,
  });

  final String tripNumber;
  final String warehouseName;
  final VoidCallback onReviewAndReceive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 124),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  color: AppColors.orange1.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: AppColors.orange0.withValues(alpha: 0.15),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.orange0,
                      size: 61,
                    ),
                    PositionedDirectional(
                      bottom: 20,
                      end: 18,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.white0,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.orange0,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(23),
            Text(
              context.strings.trip_orders_are_unavailable,
              textAlign: TextAlign.center,
              style: Styles.textStyle20.copyWith(
                color: AppColors.black1,
                fontWeight: FontWeight.w900,
                height: 1.35,
              ),
            ),
            const Gap(10),
            Text(
              context.strings.you_must_confirm_receiving_van_and_goods_first,
              textAlign: TextAlign.center,
              style: Styles.textStyle14.copyWith(
                color: AppColors.grey4,
                height: 1.55,
              ),
            ),
            const Gap(25),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white0,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.grey3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black1.withValues(alpha: 0.035),
                    blurRadius: 17,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.orange1,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.schedule_rounded,
                          color: AppColors.orange0,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          context
                              .strings
                              .you_have_a_new_trip_awaiting_for_receiving_confirmation,
                          style: Styles.textStyle16.copyWith(
                            color: AppColors.black1,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Divider(height: 1, color: AppColors.grey3),
                  const Gap(13),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.route_outlined, color: AppColors.grey4, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'رحلة $tripNumber • $warehouseName',
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.grey4,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(24),
            CustomButton(
              text: context.strings.review_and_receive_van,
              icon: const CustomSVG(assetName: AppAssets.van),
              icon1st: true,
              onPressed: onReviewAndReceive,
            ),
          ],
        ),
      ),
    );
  }
}
