import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

import '../cubit/direct_sale_cubit.dart';
import 'direct_sale_card.dart';

class DirectSaleCheckoutSummary extends StatelessWidget {
  const DirectSaleCheckoutSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DirectSaleCubit>().state;
    return DirectSaleCard(
      child: Column(
        spacing: 8,
        children: [
          for (final product in state.selectedProducts)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${product.name} × ${state.quantityFor(product)}',
                    style: Styles.textStyle14.copyWith(color: AppColors.black1),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatTripAmount(
                    context,
                    product.unitPriceMinor * state.quantityFor(product) / 100,
                  ),
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          Divider(height: 8, color: AppColors.grey3),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.direct_sale_total_required,
                  style: Styles.textStyle18.copyWith(color: AppColors.black1),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatTripAmount(context, state.totalMinor / 100),
                style: Styles.textStyle18.copyWith(color: AppColors.black1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
