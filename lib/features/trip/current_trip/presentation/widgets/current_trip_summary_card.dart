import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/current_trip_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

class CurrentTripSummaryCard extends StatelessWidget {
  const CurrentTripSummaryCard({
    super.key,
    required this.trip,
  });

  final CurrentTripModel trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: 0.04),
            blurRadius: 12,
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
              Icon(Icons.local_shipping_outlined,
                  color: AppColors.grey4, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${context.strings.van}:  ',
                          style: TextStyle(color: AppColors.grey4)),
                      TextSpan(
                        text: '${trip.vehicleName} - ${trip.plateNumber}',
                        style: TextStyle(
                          color: AppColors.black1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 13, height: 1.5),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 2,
            children: [
              _SummaryInfoLabel(
                label: context.strings.driver,
                value: trip.driverName,
              ),
              _SummaryInfoLabel(
                label: context.strings.warehouse,
                value: trip.warehouseName,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  count: trip.totalOrders,
                  label: context.strings.order,
                  background: AppColors.grey5,
                  foreground: AppColors.black1,
                  labelColor: AppColors.grey4,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _SummaryStat(
                  count: trip.handledOrders,
                  label: context.strings.handled_orders_label,
                  background: AppColors.green1,
                  foreground: AppColors.green0,
                  labelColor: AppColors.green0,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _SummaryStat(
                  count: trip.remainingOrders,
                  label: context.strings.remaining_orders,
                  background: AppColors.orange1,
                  foreground: AppColors.orange0,
                  labelColor: AppColors.orange0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.blue4,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.primary, size: 21),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.strings.collected_so_far,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  formatTripAmount(context, trip.collectedAmount),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${trip.handledOrders} ${context.strings.of_total} '
                  '${trip.totalOrders} ${context.strings.orders_handled}',
                  style: TextStyle(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${trip.progressPercent}%',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: trip.progress,
              minHeight: 12,
              backgroundColor: AppColors.grey5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryInfoLabel extends StatelessWidget {
  const _SummaryInfoLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: '$label: ', style: TextStyle(color: AppColors.grey4)),
        TextSpan(text: value, style: TextStyle(color: AppColors.black1,
            fontWeight: FontWeight.w700)),
      ]),
      style: const TextStyle(fontSize: 13, height: 1.45),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.count,
    required this.label,
    required this.background,
    required this.foreground,
    required this.labelColor,
  });

  final int count;
  final String label;
  final Color background;
  final Color foreground;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                color: foreground),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: labelColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
