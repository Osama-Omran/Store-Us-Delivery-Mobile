
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_qty_format.dart';

class DeliveryReviewSheet extends StatelessWidget {
  const DeliveryReviewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryDraftCubit, DeliveryDraftState>(
      builder: (context, state) {
        if (state is! DeliveryDraftReady) {
          return const SizedBox.shrink();
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: FractionallySizedBox(
              heightFactor: 0.72,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    // ======= Header ======= //
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.strings.delivery_review_title,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black1,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    Text(
                      state.salesOrder,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.grey4,
                      ),
                    ),

                    // ======= Selected Items ======= //
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.grey0,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0;
                          i < state.items.length;
                          i++)
                            if (state.qtyFor(i) > 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.items[i].itemName,
                                      ),
                                    ),
                                    Text(
                                      '${formatDeliveryQty(state.qtyFor(i))} '
                                          '${state.items[i].uom}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.black1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),

                    // ======= Summary ======= //
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.strings
                                .delivery_estimated_total,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          state.estimatedItemsValue == null
                              ? '—'
                              : formatTripAmount(
                            context,
                            state.estimatedItemsValue!,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 21,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.orange1,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.orange0,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              context.strings
                                  .delivery_submission_not_available,
                              style: TextStyle(
                                color: AppColors.orange0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 60,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(),
                        child: Text(
                          context.strings.delivery_back_to_edit,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
