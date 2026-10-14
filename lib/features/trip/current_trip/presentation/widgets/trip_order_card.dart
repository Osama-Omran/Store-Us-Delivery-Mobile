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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======= Stop & Customer ======= //
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 49,
                      height: 49,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: status.numberBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${order.stopNumber}',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: status.numberForeground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.3,
                              color: AppColors.black1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            order.id,
                            textDirection: TextDirection.ltr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                // Status stays a separately readable chip on narrow screens.
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TripOrderStatusBadge(style: status),
                ),

                if (order.address.trim().isNotEmpty ||
                    hasValidOrderPhone(order.phoneNumber)) ...[
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey5.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        if (order.address.trim().isNotEmpty)
                          TripOrderContactLine(
                            icon: Icons.location_on_outlined,
                            text: order.address,
                          ),
                        if (hasValidOrderPhone(order.phoneNumber)) ...[
                          if (order.address.trim().isNotEmpty)
                            const SizedBox(height: 7),
                          TripOrderContactLine(
                            icon: Icons.phone_outlined,
                            text: order.phoneNumber,
                            isPhone: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                // ======= Order Amount ======= //
                Row(
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
                          const SizedBox(height: 3),
                          Text(
                            order.orderAmount == null
                                ? '—'
                                : formatTripAmount(context, order.orderAmount!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.black1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (order.isPaymentCollected) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: _PaymentTag(
                          title: context.strings.payment_collected,
                          color: AppColors.green0,
                          background: AppColors.green1,
                        ),
                      ),
                    ] else if (order.collectedAmount > 0) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: _PaymentTag(
                          title: '${context.strings.amount_collected} '
                              '${formatTripAmount(context, order.collectedAmount)}',
                          color: AppColors.orange0,
                          background: AppColors.orange1,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.grey3),

          // ======= Original Bottom Actions ======= //
          if (order.isPending)
            TripPendingOrderActions(
              tripID: tripID,
              orderID: order.apiId,
              order: order,
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                height: 45,
                child: TextButton.icon(
                  onPressed: () => openTripOrderDetails(
                    context,
                    tripID: tripID,
                    orderID: order.apiId,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.blue5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined, size: 19),
                  label: Text(
                    context.strings.view_delivery_details,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentTag extends StatelessWidget {
  const _PaymentTag({
    required this.title,
    required this.color,
    required this.background,
  });

  final String title;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }
}
