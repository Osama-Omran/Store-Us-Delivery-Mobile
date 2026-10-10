
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_customer_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_financial_card.dart';

import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_order_header.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_order_items_section.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_extra_products_section.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_summary_bar.dart';

class DeliverOrderScreen extends StatelessWidget {
  const DeliverOrderScreen({
    super.key,
    required this.tripId,
    required this.orderId,
  });

  final int tripId;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ======= Real Order Data ======= //
        BlocProvider<OrderDetailsCubit>(
          create: (_) => getIt<OrderDetailsCubit>()
            ..getOrderDetails(
              tripId: tripId,
              orderId: orderId,
            ),
        ),

        // ======= Local Delivery Draft ======= //
        BlocProvider<DeliveryDraftCubit>(
          create: (_) => DeliveryDraftCubit(),
        ),
      ],
      child: _DeliverOrderBody(
        tripId: tripId,
        orderId: orderId,
      ),
    );
  }
}

class _DeliverOrderBody extends StatelessWidget {
  const _DeliverOrderBody({
    required this.tripId,
    required this.orderId,
  });

  final int tripId;
  final int orderId;

  Future<void> _refresh(BuildContext context) {
    return context.read<OrderDetailsCubit>().getOrderDetails(
      tripId: tripId,
      orderId: orderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderDetailsCubit, OrderDetailsState>(
      listenWhen: (_, current) =>
      current is OrderDetailsSuccessState,
      listener: (context, state) {
        if (state is OrderDetailsSuccessState) {
          context
              .read<DeliveryDraftCubit>()
              .initialize(state.order);
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          builder: (context, state) {
            final success =
            state is OrderDetailsSuccessState
                ? state
                : null;

            final order = success?.order;

            final deliveryStatus = (
                success?.tripOrder?.deliveryStatus ??
                    order?.deliveryStatus ??
                    ''
            ).trim().toUpperCase();

            final isPending = deliveryStatus == 'PENDING';

            return Scaffold(
              backgroundColor: AppColors.grey0,

              // ======= Fixed Header ======= //
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    DeliveryOrderHeader(
                      salesOrder: order?.salesOrder,
                    ),

                    Expanded(
                      child: switch (state) {
                        OrderDetailsInitial() ||
                        OrderDetailsLoadingState() =>
                        const Center(
                          child: CircularProgressIndicator(),
                        ),

                        OrderDetailsFailureState() =>
                            _DeliveryError(
                              message:
                              state.errorMessage?.isNotEmpty == true
                                  ? state.errorMessage!
                                  : context.strings
                                  .order_details_load_failed,
                              tripId: tripId,
                              orderId: orderId,
                            ),

                        OrderDetailsSuccessState() =>
                        !isPending
                            ? _DeliveryUnavailable(
                          status: deliveryStatus,
                        )
                            : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () => _refresh(context),
                          child: ListView(
                            physics:
                            const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              20,
                              20,
                              28,
                            ),
                            children: [
                              // ======= Customer Data ======= //
                              OrderCustomerCard(
                                tripId: tripId,
                                orderId: orderId,
                                location:
                                OrderCustomerLocation.fromApi(
                                  details: state.order,
                                  tripOrder: state.tripOrder,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ======= Original Total ======= //
                              OrderDetailsFinancialCard(
                                order: state.order,
                              ),

                              const SizedBox(height: 22),

                              // ======= Delivery Items ======= //
                              const DeliveryOrderItemsSection(),

                              const SizedBox(height: 28),

                              // ======= Additional Items ======= //
                              const DeliveryExtraProductsSection(),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ],
                ),
              ),

              // ======= Fixed Summary ======= //
              bottomNavigationBar:
              success != null && isPending
                  ? const DeliverySummaryBar()
                  : null,
            );
          },
        ),
      ),
    );
  }
}

// =====================================================
// Loading Failure
// =====================================================

class _DeliveryError extends StatelessWidget {
  const _DeliveryError({
    required this.message,
    required this.tripId,
    required this.orderId,
  });

  final String message;
  final int tripId;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Center(
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
              message,
              textAlign: TextAlign.center,
            ),

            OutlinedButton.icon(
              onPressed: () {
                context
                    .read<OrderDetailsCubit>()
                    .getOrderDetails(
                  tripId: tripId,
                  orderId: orderId,
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                context.strings.current_trip_retry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// Not Pending
// =====================================================

class _DeliveryUnavailable extends StatelessWidget {
  const _DeliveryUnavailable({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 18,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 44,
            ),

            Text(
              context.strings.delivery_order_not_pending,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.black1,
                fontWeight: FontWeight.w700,
              ),
            ),

            Text(
              status,
              style: TextStyle(
                color: AppColors.grey4,
              ),
            ),

            OutlinedButton(
              onPressed: () => context.pop(),
              child: Text(
                context.strings.delivery_back_to_edit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
