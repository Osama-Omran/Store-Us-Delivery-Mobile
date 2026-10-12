import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';

import '../utils/trip_order_navigation.dart';

class TripPendingOrderActions extends StatelessWidget {
  const TripPendingOrderActions({
    super.key,
    required this.tripID,
    required this.orderID,
    required this.order,
  });

  final int tripID;
  final int? orderID;
  final TripOrderModel order;

  @override
  Widget build(BuildContext context) {
    final bool hasLocation = order.hasCoordinates;
    final bool hasPhone = hasValidOrderPhone(order.phoneNumber);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Row(
        children: [
          // ======= Open Order ======= //
          Expanded(
            child: SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: () => openTripOrderDetails(
                  context,
                  tripID: tripID,
                  orderID: orderID,
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.22),
                  foregroundColor: AppColors.white0,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  context.strings.open_order,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),

          // ======= Directions Button ======= //
          if (hasLocation) ...[
            const SizedBox(width: 9),

            _SquareActionButton(
              icon: Icons.near_me_outlined,
              background: AppColors.blue4,
              foreground: AppColors.primary,
              onTap: () => openOrderDirections(context, order),
              tooltip: context.strings.open_directions,
            ),
          ],

          // ======= Call Customer Button ======= //
          if (hasPhone) ...[
            const SizedBox(width: 9),

            _SquareActionButton(
              icon: Icons.phone_outlined,
              background: AppColors.green1,
              foreground: AppColors.green0,
              onTap: () => callOrderCustomer(context, order.phoneNumber),
              tooltip: context.strings.call_customer,
            ),
          ],
        ],
      ),
    );
  }
}

class _SquareActionButton extends StatelessWidget {
  const _SquareActionButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 58,
              width: 55,
              child: Icon(icon, color: foreground, size: 25),
            ),
          ),
        ),
      ),
    );
  }
}
