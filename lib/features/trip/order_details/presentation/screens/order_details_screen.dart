import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_header.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_customer_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_delivery_status_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_items_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_financial_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_action_bar.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_collection_action_bar.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_collection_status_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_retry_collection_sheet.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/utils/order_collection_policy.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    super.key,
    required this.tripId,
    required this.orderId,
  });

  final int tripId;
  final int orderId;

  void _goBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.goNamed(RoutesNames.layout);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: GoRouter.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack(context);
      },
      child: MultiBlocProvider(
        key: ValueKey((tripId, orderId)),
        providers: [
          BlocProvider<OrderDetailsCubit>(
            create: (_) =>
                getIt<OrderDetailsCubit>()
                  ..getOrderDetails(tripId: tripId, orderId: orderId),
          ),
          BlocProvider<DeliveryOutcomeCubit>(
            create: (_) => getIt<DeliveryOutcomeCubit>(),
          ),
        ],
        child: _OrderDetailsBody(
          tripId: tripId,
          orderId: orderId,
          onBack: () => _goBack(context),
        ),
      ),
    );
  }
}

class _OrderDetailsBody extends StatelessWidget {
  const _OrderDetailsBody({
    required this.tripId,
    required this.orderId,
    required this.onBack,
  });

  final int tripId;
  final int orderId;
  final VoidCallback onBack;

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
      builder: (_) => OrderRetryCollectionSheet(
        cubit: cubit,
        tripId: tripId,
        order: order,
        salesOrder: state.order.salesOrder,
        orderTotal: order.orderTotal ?? state.order.originalTotal,
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
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
      builder: (context, state) {
        final success = state is OrderDetailsSuccessState ? state : null;

        final order = success?.order;

        final location = success == null
            ? null
            : OrderCustomerLocation.fromApi(
                details: success.order,
                tripOrder: success.tripOrder,
              );

        final deliveryStatus =
            (success?.tripOrder?.deliveryStatus ?? order?.deliveryStatus ?? '')
                .trim()
                .toUpperCase();

        final isPending = deliveryStatus == 'PENDING';
        final collection = success?.tripOrder;
        // Only payment_status decides if the collection button is visible.
        // Backend retry flags are checked on tap and again in the Cubit.
        final showCollectionAction =
            collection != null &&
            collection.canRetryCollection &&
            OrderCollectionPolicy.showCollectButton(collection.paymentStatus);

        final isDelivered = const {
          'DELIVERED',
          'COMPLETED',
          'FULLY_DELIVERED',
          'DELIVERED_FULLY',
        }.contains(deliveryStatus);

        return Scaffold(
          backgroundColor: AppColors.grey0,

          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ======= Header ======= //
                OrderDetailsHeader(subtitle: order?.salesOrder, onBack: onBack),

                Expanded(
                  child: switch (state) {
                    OrderDetailsInitial() || OrderDetailsLoadingState() =>
                      const Center(child: CircularProgressIndicator()),

                    OrderDetailsFailureState() => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 16,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 44,
                              color: AppColors.red1,
                            ),

                            Text(
                              state.errorMessage?.isNotEmpty == true
                                  ? context.localizedErrorMessage(
                                      state.errorMessage,
                                    )
                                  : context.strings.order_details_load_failed,
                              textAlign: TextAlign.center,
                            ),

                            OutlinedButton(
                              onPressed: () => _reload(context),
                              child: Text(context.strings.current_trip_retry),
                            ),
                          ],
                        ),
                      ),
                    ),

                    OrderDetailsSuccessState() => RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _reload(context),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        children: [
                          // ======= Customer Information ======= //

                          OrderCustomerCard(
                            tripId: tripId,
                            orderId: orderId,
                            location: location!,
                          ),

                          if (success?.locationUpdated ?? false) ...[
                            const SizedBox(height: 14),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 17,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green1,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: AppColors.green0,
                                    size: 25,
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      context
                                          .strings
                                          .order_location_updated_successfully,
                                      style: Styles.textStyle16.copyWith(
                                        color: AppColors.green0,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // ======= Original Order Value ======= //
                          OrderDetailsFinancialCard(order: order!),

                          if (collection != null) ...[
                            const SizedBox(height: 14),
                            OrderCollectionStatusCard(order: collection),
                          ],

                          const SizedBox(height: 20),

                          // ======= Ordered Items ======= //
                          OrderDetailsItemsCard(items: order.items),

                          // ======= Completed Orders ======= //
                          if (isDelivered) ...[
                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: AppColors.grey5,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.grey4,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      context
                                          .strings
                                          .order_details_confirmed_read_only,
                                      style: Styles.textStyle14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            OrderDeliveryStatusCard(order: order),
                          ],

                          const SizedBox(height: 15),
                        ],
                      ),
                    ),

                    _ => const SizedBox.shrink(),
                  },
                ),
              ],
            ),
          ),

          // ======= Order Actions ======= //
          bottomNavigationBar: success == null
              ? null
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
              : null,
        );
      },
    );
  }
}
