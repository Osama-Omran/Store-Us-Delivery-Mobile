import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_state.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class DeliverySummaryBar extends StatelessWidget {
  const DeliverySummaryBar({
    super.key,
    required this.tripId,
    required this.orderId,
  });

  final int tripId;
  final int orderId;

  void _openDeliveryResult(BuildContext context, DeliveryDraftReady draft) {
    final detailsState = context.read<OrderDetailsCubit>().state;

    if (detailsState is! OrderDetailsSuccessState) return;

    final customer = OrderCustomerLocation.fromApi(
      details: detailsState.order,
      tripOrder: detailsState.tripOrder,
    );

    final flow = DeliveryFlowData(
      tripId: tripId,
      orderId: orderId,
      salesOrder: detailsState.order.salesOrder,
      customerName: customer.name,
      originalTotal: detailsState.order.originalTotal,
      items: [
        for (int i = 0; i < draft.items.length; i++)
          DeliveryFlowItem(
            lineId: draft.items[i].lineId,
            itemCode: draft.items[i].itemCode,
            itemName: draft.items[i].itemName,
            uom: draft.items[i].uom,
            orderedQty: draft.items[i].orderedQty ?? 0,
            selectedQty: draft.qtyFor(i),
            rate: draft.items[i].rate,
          ),
      ],
    );

    context.pushNamed(RoutesNames.deliveryResult, extra: flow);
  }

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

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .55,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
              color: AppColors.white0,
              border: Border(top: BorderSide(color: AppColors.grey3)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          _SummaryRow(
                            label: context.strings.order_details_original_total,
                            amount: state.originalTotal,
                          ),

                          _SummaryRow(
                            label:
                                context.strings.delivery_selected_items_value,
                            amount: estimatedValue,
                          ),

                          _SummaryRow(
                            label: context.strings.delivery_extra_products,
                            amount: 0,
                          ),

                          Divider(color: AppColors.grey3, height: 1),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.strings.delivery_estimated_total,
                                  style: Styles.textStyle15.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  estimatedValue == null
                                      ? '—'
                                      : formatTripAmount(
                                          context,
                                          estimatedValue,
                                        ),
                                  textAlign: TextAlign.end,
                                  style: Styles.textStyle26.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // ======= Calculated Delivery Status ======= //
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 10,
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
                                    style: Styles.textStyle15.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: state.isPartial
                                          ? AppColors.orange0
                                          : AppColors.green0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    context.strings.delivery_auto_calculated,
                                    textAlign: TextAlign.end,
                                    style: Styles.textStyle11.copyWith(
                                      color: AppColors.grey4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ======= Continue ======= //
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 56,
                      minWidth: double.infinity,
                    ),
                    child: ElevatedButton(
                      onPressed: !state.hasSelectedItems
                          ? null
                          : () => _openDeliveryResult(context, state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white0,
                        disabledBackgroundColor: AppColors.grey3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        context.strings.delivery_continue,
                        textAlign: TextAlign.center,
                        style: Styles.textStyle18.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.amount});

  final String label;
  final num? amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Styles.base.copyWith(fontSize: 14, color: AppColors.grey4),
          ),
        ),

        const SizedBox(width: 12),
        Flexible(
          child: Text(
            amount == null ? '—' : formatTripAmount(context, amount!),
            textAlign: TextAlign.end,
            style: Styles.textStyle17.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
            ),
          ),
        ),
      ],
    );
  }
}
