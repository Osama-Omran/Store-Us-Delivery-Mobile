import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';

class OrderCustomerLocationPanel extends StatelessWidget {
  const OrderCustomerLocationPanel({super.key, required this.location});

  final OrderCustomerLocation location;

  @override
  Widget build(BuildContext context) {
    final hasAddress = location.hasAddress;
    final hasGPS = location.hasCoordinates;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey5,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.grey4),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasAddress
                      ? location.address
                      : context.strings.order_no_address,
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              Icon(
                Icons.my_location_outlined,
                size: 20,
                color: hasGPS ? AppColors.grey4 : AppColors.red1,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasGPS
                      ? '${location.latitude!.toStringAsFixed(7)}, '
                            '${location.longitude!.toStringAsFixed(7)}'
                      : context.strings.order_customer_gps_missing,
                  style: Styles.textStyle12.copyWith(
                    color: hasGPS ? AppColors.grey4 : AppColors.red1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
