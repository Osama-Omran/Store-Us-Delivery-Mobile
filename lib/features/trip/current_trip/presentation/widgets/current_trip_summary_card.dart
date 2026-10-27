import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/current_trip_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class CurrentTripSummaryCard extends StatelessWidget {
  const CurrentTripSummaryCard({super.key, required this.trip});

  final CurrentTripModel trip;

  @override
  Widget build(BuildContext context) {
    final vehicleDisplay = trip.plateNumber.trim().isEmpty
        ? trip.vehicleName
        : '${trip.vehicleName} - ${trip.plateNumber}';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: 0.045),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ======= Vehicle Heading ======= //
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [AppColors.blue5, AppColors.white0],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.blue4,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.primary,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.strings.van,
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.grey4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicleDisplay,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Styles.textStyle17.copyWith(
                          color: AppColors.black1,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ======= Driver & Warehouse ======= //
                _TripInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: context.strings.driver,
                  value: trip.driverName,
                ),
                const SizedBox(height: 8),
                _TripInfoRow(
                  icon: Icons.warehouse_outlined,
                  label: context.strings.warehouse,
                  value: trip.warehouseName,
                ),
                const SizedBox(height: 18),

                // ======= Live Order Statistics ======= //
                Row(
                  children: [
                    Expanded(
                      child: _SummaryStat(
                        count: trip.totalOrders,
                        label: context.strings.order,
                        background: AppColors.grey5,
                        foreground: AppColors.black1,
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryStat(
                        count: trip.handledOrders,
                        label: context.strings.handled_orders_label,
                        background: AppColors.green1,
                        foreground: AppColors.green0,
                        icon: Icons.task_alt_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryStat(
                        count: trip.remainingOrders,
                        label: context.strings.remaining_orders,
                        background: AppColors.orange1,
                        foreground: AppColors.orange0,
                        icon: Icons.pending_actions_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ======= Collection (unknown stays unknown) ======= //
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blue5,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.blue4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.blue4,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.strings.collected_so_far,
                          style: Styles.textStyle13.copyWith(
                            color: AppColors.black1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          trip.collectedAmount == null
                              ? '—'
                              : formatTripAmount(
                                  context,
                                  trip.collectedAmount!,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: Styles.textStyle19.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ======= Progress ======= //
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trip.handledOrders == null || trip.totalOrders == null
                            ? context.strings.trip_progress_unavailable
                            : context.strings.trip_handled_orders_summary(
                                trip.handledOrders!,
                                trip.totalOrders!,
                              ),
                        style: Styles.textStyle13.copyWith(
                          color: AppColors.black1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trip.progressPercent == null
                          ? '—'
                          : '${trip.progressPercent}%',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: trip.progress ?? 0,
                    minHeight: 9,
                    backgroundColor: AppColors.grey5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripInfoRow extends StatelessWidget {
  const _TripInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.grey4),
        const SizedBox(width: 9),
        Text(
          context.strings.label_with_colon(label),
          style: Styles.textStyle13.copyWith(color: AppColors.grey4),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Styles.textStyle13.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.count,
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final int? count;
  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 18),
          const SizedBox(height: 4),
          Text(
            count?.toString() ?? '—',
            style: Styles.textStyle25.copyWith(
              fontWeight: FontWeight.w900,
              color: foreground,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Styles.textStyle11.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
