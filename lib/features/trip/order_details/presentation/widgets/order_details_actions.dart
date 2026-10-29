import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';
import '../utils/order_collection_policy.dart';
import 'order_action_bar.dart';
import 'order_collection_action_bar.dart';
import 'order_retry_collection_sheet.dart';

class OrderDetailsActions extends StatelessWidget {
  const OrderDetailsActions({
    super.key,
    required this.tripId,
    required this.orderId,
  });
  final int tripId;
  final int orderId;

  Future<void> _reload(BuildContext context) {
    return context.read<OrderDetailsCubit>().getOrderDetails(
      tripId: tripId,
      orderId: orderId,
    );
  }

  Future<void> _openRetryCollection(
    BuildContext context,
    OrderDetailsSuccessState state,
  ) async {
    final order = state.tripOrder;
    if (order == null ||
        !OrderCollectionPolicy.showCollectButton(order.paymentStatus)) {
      return;
    }

    // Displaying the CTA is a UI rule. Submitting a financial transaction
    // requires explicit backend permission and the ORIGINAL operation ID.
    if (!order.canRetryCollection ||
        !order.pendingCollections.any(
          (p) => p.clientOperationId.trim().isNotEmpty,
        )) {
      final message = !order.canRetryCollection
          ? context.strings.order_collection_not_ready
          : context.strings.order_collection_missing_operation;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.localizedErrorMessage(message)),
            action: SnackBarAction(
              label: context.strings.order_collection_refresh,
              onPressed: () {
                if (context.mounted) _reload(context);
              },
            ),
          ),
        );
      return;
    }

    final cubit = context.read<OrderDetailsCubit>();
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: AppColors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: OrderRetryCollectionSheet(
          tripId: tripId,
          order: order,
          salesOrder: state.order.salesOrder,
          orderTotal: order.orderTotal ?? state.order.originalTotal,
        ),
      ),
    );
    if (!context.mounted || sent == null) return;
    if (sent) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.strings.order_collection_sent)),
        );
    }
    await _reload(context);
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        buildWhen: (previous, current) =>
            previous is! OrderDetailsSuccessState ||
            current is! OrderDetailsSuccessState ||
            previous.order != current.order ||
            previous.tripOrder != current.tripOrder,
        builder: (context, state) {
          final success = state is OrderDetailsSuccessState ? state : null;
          final deliveryStatus =
              (success?.tripOrder?.deliveryStatus ??
                      success?.order.deliveryStatus ??
                      '')
                  .trim()
                  .toUpperCase();
          final isPending = deliveryStatus == 'PENDING';
          final collection = success?.tripOrder;
          final showCollectionAction =
              collection != null &&
              collection.canRetryCollection &&
              OrderCollectionPolicy.showCollectButton(collection.paymentStatus);
          return success == null
              ? const SizedBox.shrink()
              : isPending && showCollectionAction
              // Keep all original delivery actions and show collection too.
              // Remove inner bottom padding to avoid duplicated safe areas.
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      child: OrderActionBar(tripId: tripId, orderId: orderId),
                    ),
                    OrderCollectionActionBar(
                      onPressed: () => _openRetryCollection(context, success),
                    ),
                  ],
                )
              : isPending
              ? OrderActionBar(tripId: tripId, orderId: orderId)
              : showCollectionAction
              ? OrderCollectionActionBar(
                  onPressed: () => _openRetryCollection(context, success),
                )
              : const SizedBox.shrink();
        },
      );
}
