import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';

import '../utils/trip_amount_formatter.dart';
import '../utils/trip_order_navigation.dart';
import 'trip_order_contact_line.dart';
import 'trip_order_status.dart';
import 'trip_pending_order_actions.dart';

class TripOrderCard extends StatelessWidget {
  const TripOrderCard({
    super.key,
    required this.order,
    required this.tripID,
    this.onCallCustomer,
    this.onOpenDirections,
  });

  final TripOrderModel order;
  final int tripID;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onOpenDirections;

  @override
  Widget build(BuildContext context) {
    final status = TripOrderStatusStyle.forOrder(context, order);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              children: [
                // ======= Customer & Order ======= //
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: status.numberBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${order.stopNumber}',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: status.numberForeground,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.25,
                              color: AppColors.black1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            order.id,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 4),

                          if (order.address.trim().isNotEmpty)
                            TripOrderContactLine(
                              icon: Icons.location_on_outlined,
                              text: order.address,
                            ),

                          if (hasValidOrderPhone(order.phoneNumber))
                            TripOrderContactLine(
                              icon: Icons.phone_outlined,
                              text: order.phoneNumber,
                              isPhone: true,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    TripOrderStatusBadge(style: status),
                  ],
                ),

                const SizedBox(height: 14),

                // ======= Order Amount ======= //
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 70),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.strings.order_value,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey4,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              order.orderAmount == null
                                  ? '—'
                                  : formatTripAmount(
                                      context,
                                      order.orderAmount!,
                                    ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ======= Payment Status ======= //
                      if (order.isPaymentCollected) ...[
                        const SizedBox(width: 6),

                        Flexible(
                          child: Text(
                            '✓ ${context.strings.payment_collected}',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.green0,
                            ),
                          ),
                        ),
                      ] else if (order.collectedAmount > 0) ...[
                        const SizedBox(width: 6),

                        Flexible(
                          child: Text(
                            '${context.strings.amount_collected} '
                            '${formatTripAmount(context, order.collectedAmount)}',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.orange0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: AppColors.grey3),

          // ======= Bottom Actions ======= //
          if (order.isPending)
            TripPendingOrderActions(
              tripID: tripID,
              orderID: order.apiId,
              order: order,
            )
          else
            SizedBox(
              height: 54,
              child: TextButton(
                onPressed: () => openTripOrderDetails(
                  context,
                  tripID: tripID,
                  orderID: order.apiId,
                ),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: Text(
                  context.strings.view_delivery_details,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
