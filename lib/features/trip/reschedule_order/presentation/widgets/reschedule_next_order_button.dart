import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class RescheduleNextOrderButton extends StatefulWidget {
  const RescheduleNextOrderButton({
    super.key,
    required this.tripId,
    required this.orderId,
  });
  final int tripId;
  final int orderId;
  @override
  State<RescheduleNextOrderButton> createState() =>
      _RescheduleNextOrderButtonState();
}

class _RescheduleNextOrderButtonState extends State<RescheduleNextOrderButton> {
  bool _loadingNext = false;
  Future<void> _openNextOrder() async {
    if (_loadingNext) return;

    setState(() => _loadingNext = true);

    TripOrderData? nextOrder;

    try {
      final result = await getIt<GetTripOrdersUsecase>().call(
        tripId: widget.tripId,
      );

      result.when(
        success: (response) {
          if (!response.success) return;

          final orders = response.data;

          TripOrderData? currentOrder;

          for (final item in orders) {
            if (item.id == widget.orderId) {
              currentOrder = item;
              break;
            }
          }

          final pending =
              orders
                  .where(
                    (item) =>
                        item.deliveryStatus.trim().toUpperCase() == 'PENDING' &&
                        item.id != widget.orderId,
                  )
                  .toList()
                ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

          if (pending.isEmpty) return;

          if (currentOrder != null) {
            for (final item in pending) {
              if (item.stopOrder > currentOrder.stopOrder) {
                nextOrder = item;
                break;
              }
            }
          }

          nextOrder ??= pending.first;
        },
        failure: (_) {},
      );
    } catch (_) {
      // Fall back to trip orders screen.
    }

    if (!mounted) return;

    if (nextOrder != null) {
      context.goNamed(
        RoutesNames.orderDetails,
        extra: {'trip_id': widget.tripId, 'order_id': nextOrder!.id},
      );
    } else {
      context.goNamed(RoutesNames.layout);
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 70,
    child: ElevatedButton(
      onPressed: _loadingNext ? null : _openNextOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      child: _loadingNext
          ? CircularProgressIndicator(color: AppColors.white0)
          : Text(
              context.strings.reschedule_next_order,
              style: Styles.textStyle20.copyWith(fontWeight: FontWeight.w800),
            ),
    ),
  );
}
