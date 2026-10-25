import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';

import 'package:storeus_delivery/features/trip/current_trip/data/models/current_trip_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/current_trip_header.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/current_trip_summary_card.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/trip_order_card.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/trip_orders_filters.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';

class CurrentTripScreen extends StatefulWidget {
  const CurrentTripScreen({
    super.key,
    required this.trip,
    this.orders = const [],
    this.onOpenOrder,
    this.onShowDeliveryDetails,
    this.onCallCustomer,
    this.onOpenDirections,
    this.ordersLoaded = true,
    this.ordersLoading = false,
    this.ordersError,
    this.onRetryOrders,
  });

  factory CurrentTripScreen.fromApi({
    Key? key,
    required CurrentTripData trip,
    List<TripOrderModel>? orders,
    bool ordersLoading = false,
    String? ordersError,
    VoidCallback? onRetryOrders,
    ValueChanged<TripOrderModel>? onOpenOrder,
    ValueChanged<TripOrderModel>? onShowDeliveryDetails,
  }) {
    return CurrentTripScreen(
      key: key,
      trip: CurrentTripModel.fromApi(trip, orders: orders),
      orders: orders ?? const [],
      ordersLoaded: orders != null,
      ordersLoading: ordersLoading,
      ordersError: ordersError,
      onRetryOrders: onRetryOrders,
      onOpenOrder: onOpenOrder,
      onShowDeliveryDetails: onShowDeliveryDetails,
    );
  }

  final CurrentTripModel trip;
  final List<TripOrderModel> orders;

  final bool ordersLoaded;
  final bool ordersLoading;
  final String? ordersError;
  final VoidCallback? onRetryOrders;

  final ValueChanged<TripOrderModel>? onOpenOrder;
  final ValueChanged<TripOrderModel>? onShowDeliveryDetails;
  final ValueChanged<TripOrderModel>? onCallCustomer;
  final ValueChanged<TripOrderModel>? onOpenDirections;

  @override
  State<CurrentTripScreen> createState() => _CurrentTripScreenState();
}

class _CurrentTripScreenState extends State<CurrentTripScreen> {
  TripOrdersFilter _selectedFilter = TripOrdersFilter.all;

  @override
  Widget build(BuildContext context) {
    final visibleOrders =
        widget.orders
            .where((order) => _selectedFilter.matches(order.status))
            .toList()
          ..sort((a, b) => a.stopNumber.compareTo(b.stopNumber));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CurrentTripHeader(tripNumber: widget.trip.id.toString()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 122),
                  children: [
                    CurrentTripSummaryCard(trip: widget.trip),
                    const SizedBox(height: 26),
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
                        if (widget.ordersLoaded &&
                            !widget.ordersLoading &&
                            widget.ordersError == null)
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
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
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
                    if (widget.ordersLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 42),
                        child: Center(
                          child: CustomLoadingIndicator(
                            size: 92,
                            primaryColor: true,
                          ),
                        ),
                      )
                    else if (widget.ordersError != null)
                      _OrdersMessage(
                        icon: Icons.wifi_off_rounded,
                        message: widget.ordersError!.isNotEmpty
                            ? widget.ordersError!
                            : context.strings.trip_orders_load_failed,
                        onRetry: widget.onRetryOrders,
                      )
                    else if (!widget.ordersLoaded)
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
                          tripID: widget.trip.id,
                        ),
                        const SizedBox(height: 13),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            message,
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
