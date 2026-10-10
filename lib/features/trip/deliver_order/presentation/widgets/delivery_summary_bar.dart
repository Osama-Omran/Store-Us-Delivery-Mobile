
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_review_sheet.dart';

class DeliverySummaryBar extends StatelessWidget {
  const DeliverySummaryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryDraftCubit, DeliveryDraftState>(
      builder: (context, state) {
        if (state is! DeliveryDraftReady) {
          return const SizedBox.shrink();
        }

        final estimatedValue = state.estimatedItemsValue;

        final statusText = !state.hasSelectedItems
            ? context.strings.delivery_no_items_selected
            : state.isPartial
            ? context.strings.delivery_partial_draft
            : context.strings.delivery_full_draft;

        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            14,
          ),
          decoration: BoxDecoration(
            color: AppColors.white0,
            border: Border(
              top: BorderSide(color: AppColors.grey3),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                _SummaryRow(
                  label: context.strings
                      .order_details_original_total,
                  amount: state.originalTotal,
                ),

                _SummaryRow(
                  label: context.strings
                      .delivery_selected_items_value,
                  amount: estimatedValue,
                ),

                _SummaryRow(
                  label: context.strings
                      .delivery_extra_products,
                  amount: 0,
                ),

                Divider(
                  color: AppColors.grey3,
                  height: 1,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.strings
                            .delivery_estimated_total,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black1,
                        ),
                      ),
                    ),
                    Text(
                      estimatedValue == null
                          ? '—'
                          : formatTripAmount(
                        context,
                        estimatedValue,
                      ),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                // ======= Calculated Delivery Status ======= //
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: state.isPartial
                        ? AppColors.orange1
                        : AppColors.green1,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.isPartial
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        color: state.isPartial
                            ? AppColors.orange0
                            : AppColors.green0,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: state.isPartial
                                ? AppColors.orange0
                                : AppColors.green0,
                          ),
                        ),
                      ),
                      Text(
                        context.strings.delivery_auto_calculated,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey4,
                        ),
                      ),
                    ],
                  ),
                ),

                // ======= Continue ======= //
                SizedBox(
                  height: 68,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !state.hasSelectedItems
                        ? null
                        : () {
                      final draftCubit =
                      context.read<DeliveryDraftCubit>();

                      showModalBottomSheet<void>(
                        context: context,
                        useSafeArea: true,
                        isScrollControlled: true,
                        backgroundColor: AppColors.white0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        builder: (_) => BlocProvider.value(
                          value: draftCubit,
                          child: const DeliveryReviewSheet(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white0,
                      disabledBackgroundColor: AppColors.grey3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      context.strings.delivery_continue,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
  });

  final String label;
  final num? amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey4,
            ),
          ),
        ),

        Text(
          amount == null
              ? '—'
              : formatTripAmount(context, amount!),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.black1,
          ),
        ),
      ],
    );
  }
}
