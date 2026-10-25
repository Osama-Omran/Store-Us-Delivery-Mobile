import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class TripOrderStatusBadge extends StatelessWidget {
  const TripOrderStatusBadge({super.key, required this.style});

  final TripOrderStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: style.badgeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.title,
        textAlign: TextAlign.center,
        maxLines: 2,
        style: Styles.textStyle12.copyWith(
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: style.badgeForeground,
        ),
      ),
    );
  }
}

class TripOrderStatusStyle {
  const TripOrderStatusStyle({
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

  static TripOrderStatusStyle forOrder(
    BuildContext context,
    TripOrderModel order,
  ) {
    switch (order.status) {
      case TripOrderStatus.delivered:
        return TripOrderStatusStyle(
          title: context.strings.delivered_fully,
          badgeBackground: AppColors.green1,
          badgeForeground: AppColors.green0,
          numberBackground: AppColors.green0,
          numberForeground: AppColors.white0,
        );

      case TripOrderStatus.rescheduled:
        return TripOrderStatusStyle(
          title: context.strings.delivery_rescheduled,
          badgeBackground: AppColors.blue4,
          badgeForeground: AppColors.primary,
          numberBackground: AppColors.blue4,
          numberForeground: AppColors.primary,
        );

      case TripOrderStatus.partiallyDelivered:
        return TripOrderStatusStyle(
          title: context.strings.delivered_partially,
          badgeBackground: AppColors.orange1,
          badgeForeground: AppColors.orange0,
          numberBackground: AppColors.orange0,
          numberForeground: AppColors.white0,
        );

      case TripOrderStatus.pending:
        return TripOrderStatusStyle(
          title: context.strings.awaiting_delivery,
          badgeBackground: AppColors.grey5,
          badgeForeground: AppColors.black1,
          numberBackground: AppColors.primary,
          numberForeground: AppColors.white0,
        );

      case TripOrderStatus.cancelled:
        return TripOrderStatusStyle(
          title: context.strings.delivery_cancelled,
          badgeBackground: AppColors.red1.withValues(alpha: 0.10),
          badgeForeground: AppColors.red1,
          numberBackground: AppColors.red1,
          numberForeground: AppColors.white0,
        );

      case TripOrderStatus.unknown:
        return TripOrderStatusStyle(
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
