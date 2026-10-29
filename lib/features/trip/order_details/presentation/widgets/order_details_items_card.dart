import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/order_details_response.dart';
import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';

class OrderDetailsItemsCard extends StatelessWidget {
  const OrderDetailsItemsCard({super.key});

  String _formatQty(num? quantity) {
    if (quantity == null) return '—';

    return quantity.toString().replaceFirst(RegExp(r'\.0$'), '');
  }

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        OrderDetailsCubit,
        OrderDetailsState,
        List<OrderDetailsItem>?
      >(
        selector: (state) =>
            state is OrderDetailsSuccessState ? state.order.items : null,
        builder: (context, items) {
          if (items == null) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white0,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.grey3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.strings.order_products,
                  style: Styles.textStyle18.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 16),

                if (items.isEmpty)
                  Center(child: Text(context.strings.order_details_no_items)),

                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) Divider(color: AppColors.grey3, height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          items[i].itemName,
                          style: Styles.textStyle16.copyWith(
                            color: AppColors.black1,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Flexible(
                        child: Text(
                          '${_formatQty(items[i].orderedQty)} '
                          '${items[i].uom}',
                          textAlign: TextAlign.end,
                          style: Styles.textStyle16.copyWith(
                            color: AppColors.black1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      );
}
