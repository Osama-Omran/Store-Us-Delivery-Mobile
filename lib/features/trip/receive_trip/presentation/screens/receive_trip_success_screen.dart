
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class ReceiveTripSuccessScreen extends StatelessWidget {
  const ReceiveTripSuccessScreen({
    super.key,
    required this.tripNumber,
    required this.receivedAt,
    required this.onShowTripOrders,
  });

  final String tripNumber;
  final DateTime receivedAt;
  final VoidCallback onShowTripOrders;

  @override
  Widget build(BuildContext context) {
    final receivingTime = MaterialLocalizations.of(context)
        .formatTimeOfDay(
      TimeOfDay.fromDateTime(receivedAt.toLocal()),
    );

    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(110),

              // Success Icon
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.green1,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 78,
                    color: AppColors.green0,
                  ),
                ),
              ),

              const Gap(24),

              // Success Title
              Text(
                context.strings.trip_receiving_success_title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                ),
              ),

              const Gap(8),

              // Success Description
              Text(
                context.strings.trip_receiving_success_description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey4,
                ),
              ),

              const Gap(30),

              // Trip Details
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white0,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: AppColors.grey3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black0.withValues(
                        alpha: 0.04,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  spacing: 14,
                  children: [
                    _TripDetailRow(
                      title: context.strings.trip_number,
                      value: tripNumber,
                    ),
                    _TripDetailRow(
                      title: context.strings.receiving_time,
                      value: receivingTime,
                    ),
                  ],
                ),
              ),

              const Gap(40),

              // Show Trip Orders Button
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: onShowTripOrders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white0,
                    elevation: 5,
                    shadowColor: AppColors.primary.withValues(
                      alpha: 0.25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    context.strings.show_trip_orders,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripDetailRow extends StatelessWidget {
  const _TripDetailRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 12,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.grey4,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
            ),
          ),
        ),
      ],
    );
  }
}
