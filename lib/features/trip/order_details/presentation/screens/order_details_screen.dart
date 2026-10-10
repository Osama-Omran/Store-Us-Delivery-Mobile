import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
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

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    super.key,
    required this.tripId,
    required this.orderId,
  });

  final int tripId;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<OrderDetailsCubit>()
            ..getOrderDetails(tripId: tripId, orderId: orderId),
      child: _OrderDetailsBody(tripId: tripId, orderId: orderId),
    );
  }
}

class _OrderDetailsBody extends StatelessWidget {
  const _OrderDetailsBody({required this.tripId, required this.orderId});

  final int tripId;
  final int orderId;

  Future<void> _reload(BuildContext context) {
    return context.read<OrderDetailsCubit>().getOrderDetails(
      tripId: tripId,
      orderId: orderId,
    );
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
                OrderDetailsHeader(subtitle: order?.salesOrder),

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
                                  ? state.errorMessage!
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
          bottomNavigationBar: success != null && isPending
              ? OrderActionBar(
            tripId: tripId,
            orderId: orderId,
          )
              : null,
        );
      },
    );
  }
}
