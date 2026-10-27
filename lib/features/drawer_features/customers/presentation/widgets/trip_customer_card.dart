import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';

import 'trip_customer_actions.dart';

class TripCustomerCard extends StatelessWidget {
  const TripCustomerCard({super.key, required this.customer, this.onOrders});
  final TripCustomer customer;
  final VoidCallback? onOrders;

  @override
  Widget build(BuildContext context) {
    final status = customer.deliveryStatus.toUpperCase().trim();
    final (statusText, statusColor, statusBackground) = switch (status) {
      'DELIVERED' || 'COMPLETED' || 'FULLY_DELIVERED' => (
        context.strings.trip_customers_delivered,
        const Color(0xFF119550),
        const Color(0xFFD9F8E4),
      ),
      'PARTIAL' || 'PARTIALLY_DELIVERED' => (
        context.strings.trip_customers_partial,
        const Color(0xFFE58610),
        const Color(0xFFFFEDCE),
      ),
      'RESCHEDULED' => (
        context.strings.trip_customers_rescheduled,
        const Color(0xFF1264D5),
        const Color(0xFFE0EDFF),
      ),
      'CANCELLED' || 'CANCELED' => (
        context.strings.trip_customers_cancelled,
        const Color(0xFFE74444),
        const Color(0xFFFDE3E3),
      ),
      'PENDING' || 'NOT_DELIVERED' => (
        context.strings.trip_customers_pending,
        const Color(0xFF425A78),
        const Color(0xFFEDF2F7),
      ),
      _ => (
        context.strings.trip_customers_unknown_status,
        const Color(0xFF425A78),
        const Color(0xFFEDF2F7),
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: .035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name.isEmpty ? '—' : customer.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.textStyle18.copyWith(
                        color: AppColors.black1,
                      ),
                    ),
                    if (customer.phone.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        customer.phone,
                        textDirection: TextDirection.ltr,
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.grey4,
                        ),
                      ),
                    ],
                    if (customer.address.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: AppColors.grey4,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Styles.textStyle12.copyWith(
                                color: AppColors.grey4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      context.strings.orders_count(customer.ordersCount),
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    statusText,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Styles.textStyle11.copyWith(
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TripCustomerActions(customer: customer, onOrders: onOrders),
        ],
      ),
    );
  }
}
