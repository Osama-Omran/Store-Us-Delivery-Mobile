import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';

enum TripOrdersFilter {
  all,
  pending,
  delivered,
  partial,
  rescheduled,
  cancelled,
}

extension TripOrdersFilterX on TripOrdersFilter {
  bool matches(TripOrderStatus status) {
    switch (this) {
      case TripOrdersFilter.all:
        return true;
      case TripOrdersFilter.pending:
        return status == TripOrderStatus.pending;
      case TripOrdersFilter.delivered:
        return status == TripOrderStatus.delivered;
      case TripOrdersFilter.partial:
        return status == TripOrderStatus.partiallyDelivered;
      case TripOrdersFilter.rescheduled:
        return status == TripOrderStatus.rescheduled;
      case TripOrdersFilter.cancelled:
        return status == TripOrderStatus.cancelled;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case TripOrdersFilter.all:
        return context.strings.all_orders;
      case TripOrdersFilter.pending:
        return context.strings.awaiting_delivery;
      case TripOrdersFilter.delivered:
        return context.strings.delivered_fully;
      case TripOrdersFilter.partial:
        return context.strings.delivered_partially;
      case TripOrdersFilter.rescheduled:
        return context.strings.delivery_rescheduled;
      case TripOrdersFilter.cancelled:
        return context.strings.delivery_cancelled;
    }
  }
}

class TripOrdersFilters extends StatelessWidget {
  const TripOrdersFilters({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TripOrdersFilter value;
  final ValueChanged<TripOrdersFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in TripOrdersFilter.values) ...[
            _FilterChip(
              title: filter.localizedLabel(context),
              isSelected: filter == value,
              onTap: () => onChanged(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.white0,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.grey3,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isSelected ? AppColors.white0 : AppColors.grey4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
