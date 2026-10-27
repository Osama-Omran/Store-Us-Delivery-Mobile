import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_state.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';

import 'home_order_statistics.dart';

import 'package:storeus_delivery/core/theme/text_styles.dart';

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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.blue4, AppColors.white0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blue3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: .035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.your_current_trip,
                  style: Styles.textStyle19.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '#${trip.number}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.white0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.white0,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.grey3),
            ),
            child: Column(
              children: [
                _TripInfoRow(
                  icon: Icons.local_shipping_outlined,
                  text: context.strings.home_van_label(vehicleName),
                ),
                const SizedBox(height: 12),
                _TripInfoRow(
                  icon: Icons.person_outline_rounded,
                  text: context.strings.home_driver_label(driverName),
                ),
                const SizedBox(height: 12),
                _TripInfoRow(
                  icon: Icons.location_on_outlined,
                  text: warehouseName,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HomeOrderStatistics(
            total: trip.ordersSummary?.total,
            delivered: state.deliveredOrders,
            remaining: state.remainingOrders,
          ),
          if (state.ordersStatus == HomeOrdersStatus.loading)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(
                child: CustomLoadingIndicator(size: 44, primaryColor: true),
              ),
            ),
          if (state.ordersStatus == HomeOrdersStatus.failure)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onRetryOrders,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.strings.home_retry_orders),
              ),
            ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white0,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.grey3),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 21,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    context.strings.collected_amount,
                    style: Styles.textStyle15.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey4,
                    ),
                  ),
                ),
                Text(
                  '—',
                  style: Styles.textStyle21.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: ElevatedButton(
              onPressed: () => LayoutCubit.get(context).selectTap(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white0,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      context.strings.continue_trip,
                      textAlign: TextAlign.center,
                      style: Styles.textStyle17.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
  const _TripInfoRow({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.blue4,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Styles.textStyle14.copyWith(
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: AppColors.black1,
            ),
          ),
        ),
      ],
    );
  }
}
