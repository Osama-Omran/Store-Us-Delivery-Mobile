import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/delivery_flow_data.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';

class DeliveryNextOrderButton extends StatefulWidget {
  const DeliveryNextOrderButton({super.key, required this.flow});
  final DeliveryFlowData flow;
  @override
  State<DeliveryNextOrderButton> createState() =>
      _DeliveryNextOrderButtonState();
}

class _DeliveryNextOrderButtonState extends State<DeliveryNextOrderButton> {
  bool _loading = false;
  Future<void> _nextOrder() async {
    if (_loading) return;

    setState(() => _loading = true);

    int? nextOrderId;
    String? error;

    try {
      final result = await getIt<GetTripOrdersUsecase>().call(
        tripId: widget.flow.tripId,
      );

      result.when(
        success: (response) {
          if (!response.success) {
            error = context.strings.delivery_next_order_failed;
            return;
          }

          final orders = List<TripOrderData>.from(response.data)
            ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

          int? currentStopOrder;

          for (final order in orders) {
            if (order.id == widget.flow.orderId) {
              currentStopOrder = order.stopOrder;
              break;
            }
          }

          final pending = orders
              .where(
                (order) =>
                    order.id != widget.flow.orderId &&
                    order.deliveryStatus.toUpperCase() == 'PENDING',
              )
              .toList();

          if (currentStopOrder != null) {
            for (final order in pending) {
              if (order.stopOrder > currentStopOrder) {
                nextOrderId = order.id;
                break;
              }
            }
          }

          if (nextOrderId == null && pending.isNotEmpty) {
            nextOrderId = pending.first.id;
          }
        },
        failure: (failure) {
          error = failure.apiErrorModel.message;
        },
      );
    } catch (_) {
      error = mounted ? context.strings.delivery_next_order_failed : null;
    }

    if (!mounted) return;

    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.localizedErrorMessage(error))),
      );
      return;
    }

    if (nextOrderId != null) {
      context.goNamed(
        RoutesNames.orderDetails,
        extra: {'trip_id': widget.flow.tripId, 'order_id': nextOrderId!},
      );
    } else {
      context.goNamed(RoutesNames.layout);
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 65,
    child: ElevatedButton(
      onPressed: _loading ? null : _nextOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white0,
      ),
      child: _loading
          ? CircularProgressIndicator(color: AppColors.white0)
          : Text(
              context.strings.delivery_next_order,
              style: Styles.textStyle18.copyWith(fontWeight: FontWeight.w800),
            ),
    ),
  );
}
