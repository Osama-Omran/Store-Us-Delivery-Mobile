import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

import 'trip_order_card.dart';
import 'trip_orders_filters.dart';
import 'trip_orders_shimmer.dart';

class CurrentTripOrdersSection extends StatefulWidget {
  const CurrentTripOrdersSection({super.key});

  @override
  State<CurrentTripOrdersSection> createState() =>
      _CurrentTripOrdersSectionState();
}

class _CurrentTripOrdersSectionState extends State<CurrentTripOrdersSection> {
  TripOrdersFilter _selectedFilter = TripOrdersFilter.all;

  @override
  Widget build(BuildContext context) => BlocBuilder<TripTabCubit, TripTabState>(
    builder: (context, state) {
      if (state is! TripTabSuccessState) return const SizedBox.shrink();
      final ordersLoaded = state.ordersStatus == TripOrdersStatus.success;
      final ordersLoading = state.ordersStatus == TripOrdersStatus.loading;
      final ordersError = state.ordersStatus == TripOrdersStatus.failure
          ? state.ordersError ?? context.strings.trip_orders_load_failed
          : null;
      final visibleOrders =
          state.orders
              .where((order) => _selectedFilter.matches(order.status))
              .toList()
            ..sort((a, b) => a.stopNumber.compareTo(b.stopNumber));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 23,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  context.strings.trip_orders,
                  style: Styles.textStyle20.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (ordersLoaded && !ordersLoading && ordersError == null)
                Container(
                  constraints: const BoxConstraints(minWidth: 30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blue4,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${visibleOrders.length}',
                    textAlign: TextAlign.center,
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          TripOrdersFilters(
            value: _selectedFilter,
            onChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),
          const SizedBox(height: 16),
          if (ordersLoading)
            const TripOrdersShimmer()
          else if (ordersError != null)
            _OrdersMessage(
              icon: Icons.wifi_off_rounded,
              message: ordersError.isNotEmpty
                  ? ordersError
                  : context.strings.trip_orders_load_failed,
              onRetry: () => TripTabCubit.get(context).getTripOrders(),
            )
          else if (!ordersLoaded)
            _OrdersMessage(
              icon: Icons.cloud_download_outlined,
              message: context.strings.trip_tab_orders_not_loaded,
            )
          else if (visibleOrders.isEmpty)
            _OrdersMessage(
              icon: Icons.inventory_2_outlined,
              message: context.strings.no_orders_in_filter,
            )
          else
            for (final order in visibleOrders) ...[
              TripOrderCard(
                key: ValueKey(order.apiId ?? order.id),
                order: order,
                tripID: state.trip.id,
              ),
              const SizedBox(height: 13),
            ],
        ],
      );
    },
  );
}

class _OrdersMessage extends StatelessWidget {
  const _OrdersMessage({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.blue5,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            context.localizedErrorMessage(message),
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(
              color: AppColors.grey4,
              height: 1.55,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 17),
            OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.blue3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.strings.trip_tab_retry),
            ),
          ],
        ],
      ),
    );
  }
}
