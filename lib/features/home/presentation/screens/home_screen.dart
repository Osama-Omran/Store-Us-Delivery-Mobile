
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.userName,
    required this.currentTrip,
    required this.onNotificationsTap,
    required this.onContinueTrip,
    this.previousTrip,
    this.onPreviousTripTap,
    this.unreadNotifications = 0,
  });

  final String userName;
  final HomeCurrentTrip currentTrip;
  final HomePreviousTrip? previousTrip;
  final int unreadNotifications;

  final VoidCallback onNotificationsTap;
  final VoidCallback onContinueTrip;
  final VoidCallback? onPreviousTripTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            _HomeHeader(
              userName: userName,
              unreadNotifications: unreadNotifications,
              onNotificationsTap: onNotificationsTap,
            ),
            const Gap(24),
            _CurrentTripCard(
              trip: currentTrip,
              onContinueTrip: onContinueTrip,
            ),
            if (previousTrip != null) ...[
              const Gap(24),
              Text(
                context.strings.previous_today_trips,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                ),
              ),
              const Gap(12),
              _PreviousTripCard(
                trip: previousTrip!,
                onTap: onPreviousTripTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  final String userName;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                context.strings.welcome,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.grey4,
                ),
              ),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.blue4,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            context.strings.currently_on_trip,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const Gap(10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: onNotificationsTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.white0,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.grey3,
                  ),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 27,
                  color: AppColors.black1,
                ),
              ),
            ),
            if (unreadNotifications > 0)
              Positioned(
                top: 8,
                right: 7,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.red1,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white0,
                      width: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CurrentTripCard extends StatelessWidget {
  const _CurrentTripCard({
    required this.trip,
    required this.onContinueTrip,
  });

  final HomeCurrentTrip trip;
  final VoidCallback onContinueTrip;

  @override
  Widget build(BuildContext context) {
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(
      TimeOfDay.fromDateTime(trip.startedAt.toLocal()),
    );

    final amount = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(trip.collectedAmount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.blue2,
            AppColors.blue5,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.blue3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  context.strings.your_current_trip,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${trip.id}',
                  style: TextStyle(
                    color: AppColors.white0,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Gap(20),
          _TripInfoRow(
            icon: Icons.local_shipping_outlined,
            text:
            '${context.strings.van}: ${trip.vehicleName}',
          ),
          const Gap(8),
          _TripInfoRow(
            text:
            '${context.strings.driver}: ${trip.driverName}',
          ),
          const Gap(8),
          _TripInfoRow(
            icon: Icons.location_on_outlined,
            text:
            '${trip.warehouseName} — '
                '${context.strings.started_at} $time',
          ),
          const Gap(20),

          // Order Statistics
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: _OrderStatCard(
                  count: trip.totalOrders,
                  label: context.strings.order,
                  backgroundColor: AppColors.white0,
                  countColor: AppColors.black1,
                  labelColor: AppColors.grey4,
                ),
              ),
              Expanded(
                child: _OrderStatCard(
                  count: trip.deliveredOrders,
                  label: context.strings.delivered_orders,
                  backgroundColor: AppColors.green1,
                  countColor: AppColors.green0,
                  labelColor: AppColors.green0,
                ),
              ),
              Expanded(
                child: _OrderStatCard(
                  count: trip.remainingOrders,
                  label: context.strings.remaining_orders,
                  backgroundColor: AppColors.orange1,
                  countColor: AppColors.orange0,
                  labelColor: AppColors.orange0,
                ),
              ),
            ],
          ),
          const Gap(14),

          // Collected Amount
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            decoration: BoxDecoration(
              color: AppColors.white0,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 21,
                      color: AppColors.grey4,
                    ),
                    Text(
                      context.strings.collected_amount,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey4,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    '$amount ${context.strings.egp_currency}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(20),

          // Continue Trip
          SizedBox(
            height: 70,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinueTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white0,
                elevation: 5,
                shadowColor: AppColors.primary.withValues(
                  alpha: 0.24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  Text(
                    context.strings.continue_trip,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripInfoRow extends StatelessWidget {
  const _TripInfoRow({
    required this.text,
    this.icon,
  });

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SizedBox(
          width: 20,
          child: icon == null
              ? const SizedBox.shrink()
              : Icon(
            icon,
            size: 19,
            color: AppColors.grey4,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.grey4,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderStatCard extends StatelessWidget {
  const _OrderStatCard({
    required this.count,
    required this.label,
    required this.backgroundColor,
    required this.countColor,
    required this.labelColor,
  });

  final int count;
  final String label;
  final Color backgroundColor;
  final Color countColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: countColor,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviousTripCard extends StatelessWidget {
  const _PreviousTripCard({
    required this.trip,
    this.onTap,
  });

  final HomePreviousTrip trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(
      TimeOfDay.fromDateTime(trip.completedAt.toLocal()),
    );

    return Material(
      color: AppColors.white0,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.grey3),
          ),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      '${context.strings.trip_label} '
                          '\u2066#${trip.id}\u2069',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black1,
                      ),
                    ),
                    Text(
                      '${trip.totalOrders} '
                          '${context.strings.orders_plural} — '
                          '${context.strings.completed_at} $time',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey4,
                      ),
                    ),
                  ],
                ),
              ),
              if (trip.isSettled)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: AppColors.green0,
                    ),
                    Text(
                      context.strings.settled,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green0,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeCurrentTrip {
  const HomeCurrentTrip({
    required this.id,
    required this.vehicleName,
    required this.driverName,
    required this.warehouseName,
    required this.startedAt,
    required this.totalOrders,
    required this.deliveredOrders,
    required this.remainingOrders,
    required this.collectedAmount,
  });

  final String id;
  final String vehicleName;
  final String driverName;
  final String warehouseName;
  final DateTime startedAt;
  final int totalOrders;
  final int deliveredOrders;
  final int remainingOrders;
  final num collectedAmount;
}

class HomePreviousTrip {
  const HomePreviousTrip({
    required this.id,
    required this.totalOrders,
    required this.completedAt,
    required this.isSettled,
  });

  final String id;
  final int totalOrders;
  final DateTime completedAt;
  final bool isSettled;
}
