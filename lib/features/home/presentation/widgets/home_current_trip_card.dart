import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_state.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';

import 'home_order_statistics.dart';

class HomeCurrentTripCard extends StatelessWidget {
  const HomeCurrentTripCard({
    super.key,
    required this.state,
    required this.onRetryOrders,
  });

  final HomeSuccessState state;
  final VoidCallback onRetryOrders;

  String _nameOrId(String? name, String? id) {
    if (name != null && name.trim().isNotEmpty) return name;
    if (id != null && id.trim().isNotEmpty) return id;
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final trip = state.trip;

    final vehicleName = _nameOrId(trip.vehicle?.name, trip.vehicle?.id);

    final driverName = _nameOrId(trip.driver?.name, trip.driver?.id);

    final warehouseName = _nameOrId(trip.warehouse?.name, trip.warehouse?.id);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.blue2, AppColors.blue5],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.blue3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ======= Trip Header ======= //
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
                  '#${trip.number}',
                  textDirection: TextDirection.ltr,
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

          // ======= Trip Information ======= //
          _TripInfoRow(
            icon: Icons.local_shipping_outlined,
            text: '${context.strings.van}: $vehicleName',
          ),

          const Gap(8),

          _TripInfoRow(text: '${context.strings.driver}: $driverName'),

          const Gap(8),

          _TripInfoRow(icon: Icons.location_on_outlined, text: warehouseName),

          const Gap(20),

          // ======= Orders Statistics ======= //
          HomeOrderStatistics(
            total: trip.ordersSummary?.total,
            delivered: state.deliveredOrders,
            remaining: state.remainingOrders,
          ),

          if (state.ordersStatus == HomeOrdersStatus.loading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),

          if (state.ordersStatus == HomeOrdersStatus.failure)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton.icon(
                onPressed: onRetryOrders,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.strings.home_retry_orders),
              ),
            ),

          const Gap(14),

          // ======= Collected Amount ======= //
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            decoration: BoxDecoration(
              color: AppColors.white0,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 21,
                  color: AppColors.grey4,
                ),

                const Gap(8),

                Expanded(
                  child: Text(
                    context.strings.collected_amount,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey4,
                    ),
                  ),
                ),

                Text(
                  '—',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
              ],
            ),
          ),

          const Gap(20),

          // ======= Continue Trip ======= //
          SizedBox(
            height: 70,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                LayoutCubit.get(context).selectTap(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white0,
                elevation: 5,
                shadowColor: AppColors.primary.withValues(alpha: .24),
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

                  const Icon(Icons.arrow_forward_ios, size: 17),
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
  const _TripInfoRow({required this.text, this.icon});

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
              : Icon(icon, size: 19, color: AppColors.grey4),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.grey4),
          ),
        ),
      ],
    );
  }
}
