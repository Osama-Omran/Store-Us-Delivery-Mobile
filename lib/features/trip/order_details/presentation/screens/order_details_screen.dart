
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_header.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_delivery_status_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_items_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_financial_card.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.onBack,
  });

  final int tripId;
  final int orderId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderDetailsCubit>()
        ..getOrderDetails(
          tripId: tripId,
          orderId: orderId,
        ),
      child: _OrderDetailsBody(
        tripId: tripId,
        orderId: orderId,
        onBack: onBack,
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
    return OrderDetailsCubit.get(context).getOrderDetails(
      tripId: tripId,
      orderId: orderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
            builder: (context, state) {
              final order = state is OrderDetailsSuccessState
                  ? state.order
                  : null;

              return Column(
                children: [
                  OrderDetailsHeader(
                    onBack: onBack,
                    subtitle: order == null
                        ? null
                        : '${order.customer?.name?.trim().isNotEmpty == true ? order.customer!.name! : '—'}'
                        ' • ${order.salesOrder}',
                  ),

                  Expanded(
                    child: switch (state) {
                      OrderDetailsInitial() ||
                      OrderDetailsLoadingState() =>
                      const Center(
                        child: CircularProgressIndicator(),
                      ),

                      OrderDetailsFailureState() =>
                          _OrderDetailsError(
                            message:
                            state.errorMessage?.isNotEmpty == true
                                ? state.errorMessage!
                                : context.strings
                                .order_details_load_failed,
                            onRetry: () => _reload(context),
                          ),


                      OrderDetailsSuccessState() => _OrderDetailsContent(
                        order: state.order,
                        onRefresh: () => _reload(context),
                      ),

                      _ => const SizedBox.shrink(),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


class _OrderDetailsContent extends StatelessWidget {
  const _OrderDetailsContent({
    required this.order,
    required this.onRefresh,
  });

  final OrderDetailsData order;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDelivered = const {
      'DELIVERED',
      'COMPLETED',
      'FULLY_DELIVERED',
    }.contains(
      order.deliveryStatus.trim().toUpperCase(),
    );

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _ReadOnlyBanner(isDelivered: isDelivered),

          const SizedBox(height: 20),

          OrderDeliveryStatusCard(order: order),

          const SizedBox(height: 20),

          OrderDetailsItemsCard(items: order.items),

          const SizedBox(height: 20),

          OrderDetailsFinancialCard(order: order),

          const SizedBox(height: 20),

          const _NotesCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ReadOnlyBanner extends StatelessWidget {
  const _ReadOnlyBanner({
    required this.isDelivered,
  });

  final bool isDelivered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey5,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        spacing: 10,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AppColors.grey4,
            size: 21,
          ),
          Expanded(
            child: Text(
              isDelivered
                  ? context.strings.order_details_confirmed_read_only
                  : context.strings.order_details_read_only,
              style: Styles.textStyle14.copyWith(
                color: AppColors.grey4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            context.strings.order_details_notes,
            style: Styles.textStyle18.copyWith(
              color: AppColors.black1,
            ),
          ),
          Text(
            context.strings.order_details_notes_unavailable,
            style: Styles.textStyle14.copyWith(
              color: AppColors.grey4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsError extends StatelessWidget {
  const _OrderDetailsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

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
              color: AppColors.red1,
              size: 44,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Styles.textStyle14.copyWith(
                color: AppColors.grey4,
              ),
            ),
            OutlinedButton.icon(
              onPressed: onRetry,
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
