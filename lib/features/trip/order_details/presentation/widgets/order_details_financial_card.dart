
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

class OrderDetailsFinancialCard extends StatelessWidget {
  const OrderDetailsFinancialCard({
    super.key,
    required this.order,
  });

  final OrderDetailsData order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.strings.order_details_original_total,
              style: Styles.textStyle16.copyWith(
                color: AppColors.grey4,
              ),
            ),
          ),

          Text(
            order.originalTotal == null
                ? '—'
                : formatTripAmount(
              context,
              order.originalTotal!,
            ),
            style: Styles.textStyle24.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
