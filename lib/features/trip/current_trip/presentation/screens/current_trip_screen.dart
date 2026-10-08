import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/current_trip_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/current_trip_header.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/current_trip_summary_card.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/trip_order_card.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/trip_orders_filters.dart';

class CurrentTripScreen extends StatefulWidget {
  const CurrentTripScreen({
    super.key,
    required this.trip,
    required this.orders,
    required this.onOpenMap,
    required this.onOpenOrder,
    required this.onShowDeliveryDetails,
    required this.onCallCustomer,
    required this.onOpenDirections,
  });

  final CurrentTripModel trip;
  final List<TripOrderModel> orders;
  final VoidCallback onOpenMap;
  final ValueChanged<TripOrderModel> onOpenOrder;
  final ValueChanged<TripOrderModel> onShowDeliveryDetails;
  final ValueChanged<TripOrderModel> onCallCustomer;
  final ValueChanged<TripOrderModel> onOpenDirections;

  @override
  State<CurrentTripScreen> createState() => _CurrentTripScreenState();
}

class _CurrentTripScreenState extends State<CurrentTripScreen> {
  TripOrdersFilter _selectedFilter = TripOrdersFilter.all;

  @override
  Widget build(BuildContext context) {
    final visibleOrders = widget.orders
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
              CurrentTripHeader(
                tripNumber: widget.trip.id,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  children: [
                    CurrentTripSummaryCard(trip: widget.trip),
                    const SizedBox(height: 22),
                    Text(
                      context.strings.trip_orders,
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.black1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TripOrdersFilters(
                      value: _selectedFilter,
                      onChanged: (newFilter) {
                        setState(() => _selectedFilter = newFilter);
                      },
                    ),
                    const SizedBox(height: 14),
                    if (visibleOrders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            context.strings.no_orders_in_filter,
                            style: TextStyle(
                              color: AppColors.grey4,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final order in visibleOrders) ...[
                        TripOrderCard(
                          key: ValueKey(order.id),
                          order: order,
                          onOpenOrder: () => widget.onOpenOrder(order),
                          onShowDeliveryDetails: () =>
                              widget.onShowDeliveryDetails(order),
                          onCallCustomer: () => widget.onCallCustomer(order),
                          onOpenDirections: () =>
                              widget.onOpenDirections(order),
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
