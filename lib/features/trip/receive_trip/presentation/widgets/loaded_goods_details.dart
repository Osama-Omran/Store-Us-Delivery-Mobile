
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/loaded_items_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/custom_trip_container.dart';

class LoadedGoodsDetails extends StatelessWidget {
  const LoadedGoodsDetails({
    super.key,
    required this.totals,
  });

  final LoadedItemsTotals? totals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          context.strings.loaded_goods_details,
          style: Styles.textStyle18,
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: CustomTripContainer(
                child: Column(
                  spacing: 6,
                  children: [
                    Text(
                      totals?.items.toString() ?? '—',
                      style: Styles.textStyle24,
                    ),
                    Text(context.strings.total_items),
                  ],
                ),
              ),
            ),
            Expanded(
              child: CustomTripContainer(
                child: Column(
                  spacing: 6,
                  children: [
                    Text(
                      totals?.qty.toString() ?? '—',
                      style: Styles.textStyle24.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(context.strings.total_quantities),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
