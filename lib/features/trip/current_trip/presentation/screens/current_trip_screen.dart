import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

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

  // ======= API Constructor ======= //
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ======= Customer Directions ======= //
  Future<void> _openDirections(TripOrderModel order) async {
    if (!order.hasCoordinates) return;

    if (widget.onOpenDirections != null) {
      widget.onOpenDirections!(order);
      return;
    }

    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${order.latitude},${order.longitude}',
    });

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && mounted) {
        _showMessage(context.strings.trip_action_unavailable);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(context.strings.trip_action_unavailable);
      }
    }
  }

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
              // ======= Original Header ======= //
              CurrentTripHeader(tripNumber: widget.trip.id.toString()),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 122),
                  children: [
                    // ======= Original Summary ======= //
                    CurrentTripSummaryCard(trip: widget.trip),

                    const SizedBox(height: 22),

                    // ======= Orders Title ======= //
                    Text(
                      context.strings.trip_orders,
                      style: Styles.textStyle20.copyWith(
                        color: AppColors.black1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ======= Original Filters ======= //
                    TripOrdersFilters(
                      value: _selectedFilter,
                      onChanged: (filter) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // ======= Orders Loading ======= //
                    if (widget.ordersLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    // ======= Orders Failure ======= //
                    else if (widget.ordersError != null)
                      _OrdersMessage(
                        message: widget.ordersError!.isNotEmpty
                            ? widget.ordersError!
                            : context.strings.trip_orders_load_failed,
                        onRetry: widget.onRetryOrders,
                      )
                    // ======= Not Loaded Yet ======= //
                    else if (!widget.ordersLoaded)
                      _OrdersMessage(
                        message: context.strings.trip_tab_orders_not_loaded,
                      )
                    // ======= Empty Orders / Filter ======= //
                    else if (visibleOrders.isEmpty)
                      _OrdersMessage(
                        message: context.strings.no_orders_in_filter,
                      )
                    // ======= Actual Order Cards ======= //
                    else
                      for (final order in visibleOrders) ...[
                        TripOrderCard(
                          key: ValueKey(order.apiId ?? order.id),
                          order: order,
                          tripID: widget.trip.id,
                          onOpenDirections: order.hasCoordinates
                              ? () => _openDirections(order)
                              : null,
                        ),
                        const SizedBox(height: 14),
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

// ======= Orders Loading / Error / Empty ======= //
class _OrdersMessage extends StatelessWidget {
  const _OrdersMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        spacing: 14,
        children: [
          Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 42),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
          if (onRetry != null)
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.strings.trip_tab_retry),
            ),
        ],
      ),
    );
  }
}
