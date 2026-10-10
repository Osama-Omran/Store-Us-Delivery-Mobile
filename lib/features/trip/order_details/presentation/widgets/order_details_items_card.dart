
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

class OrderDetailsItemsCard extends StatelessWidget {
  const OrderDetailsItemsCard({
    super.key,
    required this.items,
  });

  final List<OrderDetailsItem> items;

  String _formatQty(num? value) {
    if (value == null) return '—';
    return value.toString().replaceFirst(RegExp(r'\.0$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            context.strings.order_details_items_title,
            style: Styles.textStyle18.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w800,
            ),
          ),

          Text(
            context.strings.order_details_quantities_hint,
            style: Styles.textStyle12.copyWith(
              color: AppColors.grey4,
            ),
          ),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Center(
                child: Text(
                  context.strings.order_details_no_items,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.grey4,
                  ),
                ),
              ),
            )
          else
            for (int i = 0; i < items.length; i++) ...[
              _OrderDetailsItemRow(
                item: items[i],
                formatQty: _formatQty,
              ),

              if (i < items.length - 1)
                Divider(
                  height: 1,
                  color: AppColors.grey3,
                ),
            ],
        ],
      ),
    );
  }
}

class _OrderDetailsItemRow extends StatelessWidget {
  const _OrderDetailsItemRow({
    required this.item,
    required this.formatQty,
  });

  final OrderDetailsItem item;
  final String Function(num?) formatQty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  item.itemName,
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.black1,
                  ),
                ),

                if (item.uom.isNotEmpty)
                  Text(
                    item.uom,
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.grey4,
                    ),
                  ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 5,
            children: [
              Text(
                '${formatQty(item.orderedQty)} / '
                    '${formatQty(item.maxDeliverableQty)}',
                textDirection: TextDirection.ltr,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),

              Text(
                '${context.strings.order_details_vehicle_available}: '
                    '${formatQty(item.vehicleAvailableQty)}',
                style: Styles.textStyle12.copyWith(
                  color: AppColors.grey4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
