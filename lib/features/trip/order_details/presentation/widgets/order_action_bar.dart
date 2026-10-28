import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/routing/routes_names.dart';

import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';

import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/widgets/cancel_delivery_sheet.dart';
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/widgets/reschedule_order_sheet.dart';

class OrderActionBar extends StatelessWidget {
  const OrderActionBar({
    super.key,
    required this.tripId,
    required this.orderId,
  });

  final int tripId;
  final int orderId;

  Future<void> _refreshAfterOutcome(OrderDetailsCubit cubit) async {
    try {
      await cubit.getOrderDetails(tripId: tripId, orderId: orderId);
    } catch (_) {
      // A refresh failure must not interrupt navigation after an accepted outcome.
    }
  }

  // ======= Open Cancel Delivery Sheet ======= //
  Future<void> _openCancelDeliverySheet(BuildContext context) async {
    final detailsCubit = context.read<OrderDetailsCubit>();
    final state = detailsCubit.state;

    if (state is! OrderDetailsSuccessState) return;

    // ======= Validate Order Status ======= //
    final deliveryStatus =
        (state.tripOrder?.deliveryStatus ?? state.order.deliveryStatus)
            .trim()
            .toUpperCase();

    if (deliveryStatus != 'PENDING') return;

    final outcomeCubit = context.read<DeliveryOutcomeCubit>()..resetFailure();

    // ======= Customer Details ======= //
    final location = OrderCustomerLocation.fromApi(
      details: state.order,
      tripOrder: state.tripOrder,
    );

    // ======= Open Cancellation Form ======= //
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white0,
      barrierColor: AppColors.black1.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: outcomeCubit,
          child: CancelDeliverySheet(
            tripId: tripId,
            orderId: orderId,
            salesOrder: state.order.salesOrder,
            customerName: location.name,
          ),
        );
      },
    );

    // ======= Only Navigate After Successful API ======= //
    if (!context.mounted || result == null) return;

    final router = GoRouter.of(context);
    unawaited(_refreshAfterOutcome(detailsCubit));
    router.pushReplacementNamed(
      RoutesNames.cancelDeliverySuccess,
      extra: result,
    );
  }

  // ======= Open Reschedule Bottom Sheet ======= //
  Future<void> _openRescheduleSheet(BuildContext context) async {
    final detailsCubit = context.read<OrderDetailsCubit>();
    final state = detailsCubit.state;

    if (state is! OrderDetailsSuccessState) {
      return;
    }

    final deliveryStatus =
        (state.tripOrder?.deliveryStatus ?? state.order.deliveryStatus)
            .trim()
            .toUpperCase();

    if (deliveryStatus != 'PENDING') {
      return;
    }

    final outcomeCubit = context.read<DeliveryOutcomeCubit>()..resetFailure();

    // ======= Real Customer Data ======= //
    final location = OrderCustomerLocation.fromApi(
      details: state.order,
      tripOrder: state.tripOrder,
    );

    // ======= Open Bottom Sheet ======= //
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white0,
      barrierColor: AppColors.black1.withValues(alpha: 0.40),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: outcomeCubit,
          child: RescheduleOrderSheet(
            tripId: tripId,
            orderId: orderId,
            salesOrder: state.order.salesOrder,
            customerName: location.name,
            address: location.address,
          ),
        );
      },
    );

    // User cancelled the sheet.
    if (!context.mounted || result == null) return;

    // API success: navigate to confirmation screen.
    final router = GoRouter.of(context);
    unawaited(_refreshAfterOutcome(detailsCubit));
    await router.pushNamed(RoutesNames.rescheduleSuccess, extra: result);

    // Refresh if user returns to the original order details.
    if (!context.mounted || detailsCubit.isClosed) return;

    await detailsCubit.getOrderDetails(tripId: tripId, orderId: orderId);
  }

  Future<void> _openDeliveryScreen(BuildContext context) async {
    final detailsCubit = context.read<OrderDetailsCubit>();

    await GoRouter.of(context).push(
      RoutesNames.deliverOrder,
      extra: {'trip_id': tripId, 'order_id': orderId},
    );

    if (!context.mounted || detailsCubit.isClosed) return;

    await detailsCubit.getOrderDetails(tripId: tripId, orderId: orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.white0,
        border: Border(top: BorderSide(color: AppColors.grey3)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.strings.order_visit_action_question,
              style: Styles.textStyle14.copyWith(
                color: AppColors.grey4,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 56,
                minWidth: double.infinity,
              ),
              child: ElevatedButton.icon(
                onPressed: () => _openDeliveryScreen(context),

                icon: const Icon(Icons.inventory_2_outlined, size: 24),
                label: Text(
                  context.strings.deliver_order,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle18.copyWith(
                    color: AppColors.white0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green0,
                  foregroundColor: AppColors.white0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: OutlinedButton.icon(
                      onPressed: () => _openRescheduleSheet(context),
                      icon: const Icon(Icons.event_repeat),
                      label: Text(
                        context.strings.reschedule_delivery,
                        textAlign: TextAlign.center,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        backgroundColor: AppColors.blue4,
                        side: BorderSide(color: AppColors.blue3, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: OutlinedButton.icon(
                      onPressed: () => _openCancelDeliverySheet(context),
                      icon: const Icon(Icons.block_outlined),
                      label: Text(
                        context.strings.cancel_delivery,
                        textAlign: TextAlign.center,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red1,
                        backgroundColor: AppColors.red1.withValues(alpha: .10),
                        side: BorderSide(
                          color: AppColors.red1.withValues(alpha: .40),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
