import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class ReceivingSuccessHeader extends StatelessWidget {
  const ReceivingSuccessHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.green1,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.green0,
                width: 5,
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 42,
              color: AppColors.green0,
            ),
          ),
        ),
        const Gap(24),
        Text(
          context.strings.trip_receiving_success_title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.black1,
          ),
        ),
        const Gap(8),
        Text(
          context.strings.trip_receiving_success_description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.grey4,
          ),
        ),
      ],
    );
  }
}
