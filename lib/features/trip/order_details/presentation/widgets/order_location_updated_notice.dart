import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class OrderLocationUpdatedNotice extends StatelessWidget {
  const OrderLocationUpdatedNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    decoration: BoxDecoration(
      color: AppColors.green1,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          color: AppColors.green0,
          size: 25,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            context.strings.order_location_updated_successfully,
            style: Styles.textStyle16.copyWith(
              color: AppColors.green0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}
