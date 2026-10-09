
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/cubit/receive_trip_cubit.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/cubit/receive_trip_state.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/custom_trip_container.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/loaded_goods_details.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/van_products.dart';

class LoadedItemsSection extends StatelessWidget {
  const LoadedItemsSection({
    super.key,
    required this.state,
  });

  final ReceiveTripSuccessState state;

  @override
  Widget build(BuildContext context) {
    switch (state.loadedItemsStatus) {
      case LoadedItemsStatus.initial:
      case LoadedItemsStatus.loading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              context.strings.loaded_goods_details,
              style: Styles.textStyle18,
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        );

      case LoadedItemsStatus.failure:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              context.strings.loaded_goods_details,
              style: Styles.textStyle18,
            ),
            CustomTripContainer(
              child: Column(
                spacing: 12,
                children: [
                  Text(
                    state.loadedItemsError?.isNotEmpty == true
                        ? state.loadedItemsError!
                        : context.strings.loaded_items_load_failed,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.grey4,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        ReceiveTripCubit.get(context)
                            .getLoadedItems(),
                    child: Text(context.strings.current_trip_retry),
                  ),
                ],
              ),
            ),
          ],
        );

      case LoadedItemsStatus.empty:
      case LoadedItemsStatus.success:
        final data = state.loadedItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoadedGoodsDetails(totals: data?.totals),
            const Gap(16),
            if (data == null || data.items.isEmpty)
              CustomTripContainer(
                child: Center(
                  child: Text(
                    context.strings.loaded_items_empty,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.grey4,
                    ),
                  ),
                ),
              )
            else
              VanProducts(items: data.items),
          ],
        );
    }
  }
}
