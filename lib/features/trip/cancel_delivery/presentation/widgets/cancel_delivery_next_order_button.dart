import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';

class CancelNextOrderButton extends StatefulWidget {
  const CancelNextOrderButton({
    super.key,
    required this.tripId,
    required this.orderId,
  });
  final int tripId;
  final int orderId;
  @override
  State<CancelNextOrderButton> createState() => _CancelNextOrderButtonState();
}

class _CancelNextOrderButtonState extends State<CancelNextOrderButton> {
  bool _loadingNext = false;
  Future<void> _goToNextOrder() async {
    if (_loadingNext) return;

    setState(() => _loadingNext = true);

    int? nextOrderId;
    bool requestFailed = false;

    try {
      final result = await getIt<GetTripOrdersUsecase>().call(
        tripId: widget.tripId,
      );

      result.when(
        success: (response) {
          if (!response.success) {
            requestFailed = true;
            return;
          }

          final List<TripOrderData> orders = [...response.data]
            ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

          int? currentStopOrder;

          for (final order in orders) {
            if (order.id == widget.orderId) {
              currentStopOrder = order.stopOrder;
              break;
            }
          }

          final pendingOrders = orders.where((order) {
            return order.id != widget.orderId &&
                order.deliveryStatus.trim().toUpperCase() == 'PENDING';
          }).toList();

          // Prefer the next stop in the actual trip order.
          if (currentStopOrder != null) {
            for (final order in pendingOrders) {
              if (order.stopOrder > currentStopOrder) {
                nextOrderId = order.id;
                break;
              }
            }
          }

          // Otherwise select the first pending order.
          if (nextOrderId == null && pendingOrders.isNotEmpty) {
            nextOrderId = pendingOrders.first.id;
          }
        },
        failure: (_) {
          requestFailed = true;
        },
      );
    } catch (_) {
      requestFailed = true;
    }

    if (!mounted) return;

    setState(() => _loadingNext = false);

    // ======= API Failure ======= //
    if (requestFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.strings.cancel_delivery_next_order_failed),
          backgroundColor: AppColors.red0,
        ),
      );
      return;
    }

    // ======= Next Pending Order ======= //
    if (nextOrderId != null) {
      context.goNamed(
        RoutesNames.orderDetails,
        extra: {'trip_id': widget.tripId, 'order_id': nextOrderId},
      );
      return;
    }

    // ======= No Remaining Pending Orders ======= //
    context.goNamed(RoutesNames.layout);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 70,
    child: ElevatedButton(
      onPressed: _loadingNext ? null : _goToNextOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      child: _loadingNext
          ? CircularProgressIndicator(color: AppColors.white0)
          : Text(
              context.strings.cancel_delivery_next_order,
              style: Styles.textStyle20.copyWith(
                color: AppColors.white0,
                fontWeight: FontWeight.w800,
              ),
            ),
    ),
  );
}
