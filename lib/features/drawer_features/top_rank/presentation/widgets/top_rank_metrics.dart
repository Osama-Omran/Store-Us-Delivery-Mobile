import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

class TopRankMetrics extends StatelessWidget {
  const TopRankMetrics({super.key, required this.entry});

  final TopRankEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        _MetricRow(
          label: context.strings.top_rank_delivery,
          value: entry.deliveryPercentage == null
              ? '—'
              : '${entry.deliveryPercentage}%',
        ),
        _MetricRow(
          label: context.strings.top_rank_collection,
          value: entry.collectionPercentage == null
              ? '—'
              : '${entry.collectionPercentage}%',
        ),
        _MetricRow(
          label: context.strings.top_rank_extra_sales,
          value: entry.extraSales == null
              ? '—'
              : formatTripAmount(context, entry.extraSales!),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Styles.textStyle12.copyWith(
              color: AppColors.grey4,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          textAlign: TextAlign.end,
          style: Styles.textStyle14.copyWith(
            color: AppColors.black1,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class TopRankMovement extends StatelessWidget {
  const TopRankMovement({super.key, required this.movement});

  final int movement;

  @override
  Widget build(BuildContext context) {
    final color = movement > 0
        ? AppColors.green0
        : movement < 0
        ? AppColors.red1
        : AppColors.grey4;
    final label = movement > 0
        ? context.strings.top_rank_moved_up(movement)
        : movement < 0
        ? context.strings.top_rank_moved_down(movement.abs())
        : context.strings.top_rank_unchanged;

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.ltr,
        children: [
          Text(
            movement == 0 ? '—' : '${movement.abs()}',
            style: Styles.textStyle12.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (movement != 0)
            Icon(
              movement > 0
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 14,
              color: color,
            ),
        ],
      ),
    );
  }
}
