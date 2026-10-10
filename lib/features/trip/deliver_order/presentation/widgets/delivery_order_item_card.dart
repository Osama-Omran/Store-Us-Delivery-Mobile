
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_qty_format.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

class DeliveryOrderItemCard extends StatelessWidget {
  const DeliveryOrderItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  final OrderDetailsItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryDraftCubit, DeliveryDraftState>(
      builder: (context, state) {
        if (state is! DeliveryDraftReady) {
          return const SizedBox.shrink();
        }

        final selectedQty = state.qtyFor(index);
        final maxQty = state.maxFor(index);
        final shortfall = state.shortfallFor(index);
        final insufficientStock =
        state.hasStockShortage(index);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white0,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: insufficientStock
                  ? AppColors.orange0.withValues(alpha: .65)
                  : AppColors.grey3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              // ======= Product Details ======= //
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          item.itemName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black1,
                          ),
                        ),

                        Text(
                          '${context.strings.delivery_item_code}: '
                              '${item.itemCode} • '
                              '${context.strings.unit}: ${item.uom}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    item.rate == null
                        ? '—'
                        : formatTripAmount(
                      context,
                      item.rate!,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey4,
                    ),
                  ),
                ],
              ),

              // ======= Ordered & Available ======= //
              Row(
                children: [
                  Expanded(
                    child: _QuantityInfoTile(
                      label: context.strings
                          .delivery_ordered_quantity,
                      quantity: item.orderedQty,
                      background: AppColors.grey5,
                      color: AppColors.black1,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _QuantityInfoTile(
                      label: context.strings
                          .delivery_vehicle_available,
                      quantity: item.vehicleAvailableQty,
                      background: insufficientStock
                          ? AppColors.orange1
                          : AppColors.blue4,
                      color: insufficientStock
                          ? AppColors.orange0
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),

              // ======= Insufficient Stock ======= //
              if (insufficientStock)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange1,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 19,
                        color: AppColors.orange0,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          context.strings
                              .delivery_insufficient_stock,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.orange0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ======= Quantity Stepper ======= //
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey0,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.strings.delivery_selected_quantity,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black1,
                        ),
                      ),
                    ),


                    _StepperButton(
                      index: index,
                      icon: Icons.remove,
                      enabled: selectedQty > 0,
                      primary: false,
                    ),


                    SizedBox(
                      width: 48,
                      child: Text(
                        formatDeliveryQty(selectedQty),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black1,
                        ),
                      ),
                    ),


                    _StepperButton(
                      index: index,
                      icon: Icons.add,
                      enabled: selectedQty < maxQty,
                      primary: true,
                    ),

                  ],
                ),
              ),

              // ======= Delivery Difference ======= //
              if (shortfall > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange1,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      _DifferenceValue(
                        label: context.strings.delivery_ordered,
                        value: item.orderedQty,
                      ),
                      _DifferenceValue(
                        label: context.strings.delivery_selected,
                        value: selectedQty,
                      ),
                      _DifferenceValue(
                        label: context.strings.delivery_not_delivered,
                        value: shortfall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================
// Quantity Information Tile
// =====================================================

class _QuantityInfoTile extends StatelessWidget {
  const _QuantityInfoTile({
    required this.label,
    required this.quantity,
    required this.background,
    required this.color,
  });

  final String label;
  final num? quantity;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 3,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          Text(
            formatDeliveryQty(quantity),
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Stepper Button
// =====================================================


class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.primary,
    required this.index,
  });

  final IconData icon;
  final bool enabled;
  final bool primary;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary
          ? AppColors.primary
          : AppColors.white0,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: !enabled
            ? null
            : () {
          if (primary) {
            context
                .read<DeliveryDraftCubit>()
                .increment(index);
          } else {
            context
                .read<DeliveryDraftCubit>()
                .decrement(index);
          }
        },
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: primary
                ? null
                : Border.all(color: AppColors.grey3),
          ),
          child: Icon(
            icon,
            color: enabled
                ? primary
                ? AppColors.white0
                : AppColors.black1
                : AppColors.grey2,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// Difference Value
// =====================================================

class _DifferenceValue extends StatelessWidget {
  const _DifferenceValue({
    required this.label,
    required this.value,
  });

  final String label;
  final num? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.orange0,
          ),
        ),
        Text(
          formatDeliveryQty(value),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.orange0,
          ),
        ),
      ],
    );
  }
}
