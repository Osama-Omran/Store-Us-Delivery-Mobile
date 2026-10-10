
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

class TripOrderCard extends StatelessWidget {
  const TripOrderCard({
    super.key,
    required this.order,
    required this.onOpenOrder,
    required this.onShowDeliveryDetails,
    this.onCallCustomer,
    this.onOpenDirections,
  });

  final TripOrderModel order;
  final VoidCallback onOpenOrder;
  final VoidCallback onShowDeliveryDetails;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onOpenDirections;

  @override
  Widget build(BuildContext context) {
    final status = _StatusStyle.forOrder(
      context,
      order,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.grey3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(
              alpha: 0.035,
            ),
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
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              16,
            ),
            child: Column(
              children: [
                // ======= Customer & Order ======= //
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
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

                          _OrderContactLine(
                            icon: Icons.location_on_outlined,
                            text: order.address,
                          ),

                          _OrderContactLine(
                            icon: Icons.phone_outlined,
                            text: order.phoneNumber,
                            isPhone: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    _StatusBadge(style: status),
                  ],
                ),

                const SizedBox(height: 14),

                // ======= Order Amount ======= //
                Padding(
                  padding:
                  const EdgeInsetsDirectional.only(
                    start: 70,
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
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

                      // Payment is based on payment_status,
                      // not delivery_status.
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

          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.grey3,
          ),

          // ======= Bottom Actions ======= //
          if (order.isPending)
            _PendingOrderActions(
              onOpenOrder: onOpenOrder,
              onCallCustomer: onCallCustomer,
              onOpenDirections: onOpenDirections,
            )
          else
            SizedBox(
              height: 54,
              child: TextButton(
                onPressed: onShowDeliveryDetails,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
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

class _OrderContactLine extends StatelessWidget {
  const _OrderContactLine({
    required this.icon,
    required this.text,
    this.isPhone = false,
  });

  final IconData icon;
  final String text;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    final displayText =
    text.trim().isEmpty ? '—' : text;

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.grey4,
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Text(
              displayText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textDirection:
              isPhone ? TextDirection.ltr : null,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 13,
                height: 1.25,
                color: AppColors.grey4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingOrderActions extends StatelessWidget {
  const _PendingOrderActions({
    required this.onOpenOrder,
    this.onCallCustomer,
    this.onOpenDirections,
  });

  final VoidCallback onOpenOrder;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onOpenDirections;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        14,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: onOpenOrder,
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  shadowColor: AppColors.primary
                      .withValues(alpha: 0.22),
                  foregroundColor: AppColors.white0,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(24),
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

          const SizedBox(width: 9),

          _SquareActionButton(
            icon: Icons.near_me_outlined,
            background: AppColors.blue4,
            foreground: AppColors.primary,
            onTap: onOpenDirections,
            tooltip: context.strings.open_directions,
          ),

          const SizedBox(width: 9),

          _SquareActionButton(
            icon: Icons.phone_outlined,
            background: AppColors.green1,
            foreground: AppColors.green0,
            onTap: onCallCustomer,
            tooltip: context.strings.call_customer,
          ),
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
              child: Icon(
                icon,
                color: foreground,
                size: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.style,
  });

  final _StatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 132,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: style.badgeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.title,
        textAlign: TextAlign.center,
        maxLines: 2,
        style: TextStyle(
          fontSize: 12,
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: style.badgeForeground,
        ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.title,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.numberBackground,
    required this.numberForeground,
  });

  final String title;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color numberBackground;
  final Color numberForeground;

  static _StatusStyle forOrder(
      BuildContext context,
      TripOrderModel order,
      ) {
    switch (order.status) {
      case TripOrderStatus.delivered:
        return _StatusStyle(
          title: context.strings.delivered_fully,
          badgeBackground: AppColors.green1,
          badgeForeground: AppColors.green0,
          numberBackground: AppColors.green0,
          numberForeground: AppColors.white0,
        );

      case TripOrderStatus.rescheduled:
        return _StatusStyle(
          title: context.strings.delivery_rescheduled,
          badgeBackground: AppColors.blue4,
          badgeForeground: AppColors.primary,
          numberBackground: AppColors.blue4,
          numberForeground: AppColors.primary,
        );

      case TripOrderStatus.partiallyDelivered:
        return _StatusStyle(
          title: context.strings.delivered_partially,
          badgeBackground: AppColors.orange1,
          badgeForeground: AppColors.orange0,
          numberBackground: AppColors.orange0,
          numberForeground: AppColors.white0,
        );

      case TripOrderStatus.pending:
        return _StatusStyle(
          title: context.strings.awaiting_delivery,
          badgeBackground: AppColors.grey5,
          badgeForeground: AppColors.black1,
          numberBackground: AppColors.primary,
          numberForeground: AppColors.white0,
        );

      case TripOrderStatus.cancelled:
        return _StatusStyle(
          title: context.strings.delivery_cancelled,
          badgeBackground:
          AppColors.red1.withValues(alpha: 0.10),
          badgeForeground: AppColors.red1,
          numberBackground: AppColors.red1,
          numberForeground: AppColors.white0,
        );

      case TripOrderStatus.unknown:
        return _StatusStyle(
          title: order.rawDeliveryStatus?.isNotEmpty == true
              ? order.rawDeliveryStatus!
              : context.strings.trip_tab_unknown_status,
          badgeBackground: AppColors.grey5,
          badgeForeground: AppColors.grey4,
          numberBackground: AppColors.grey3,
          numberForeground: AppColors.black1,
        );
    }
  }
}
