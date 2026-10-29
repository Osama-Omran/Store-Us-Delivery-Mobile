import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_order_item_card.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class DeliveryOrderItemsSection extends StatelessWidget {
  const DeliveryOrderItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryDraftCubit, DeliveryDraftState>(
      buildWhen: (previous, current) =>
          previous is! DeliveryDraftReady ||
          current is! DeliveryDraftReady ||
          previous.items != current.items,
      builder: (context, state) {
        if (state is! DeliveryDraftReady) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            Text(
              context.strings.order_products,
              style: Styles.textStyle19.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.black1,
              ),
            ),

            if (state.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(context.strings.order_details_no_items),
              ),

            for (var index = 0; index < state.items.length; index++)
              DeliveryOrderItemCard(
                key: ValueKey('${state.items[index].itemCode}_$index'),
                item: state.items[index],
                index: index,
              ),
          ],
        );
      },
    );
  }
}
