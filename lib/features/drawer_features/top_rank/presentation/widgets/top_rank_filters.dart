
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';

extension TopRankPeriodLabels on TopRankPeriod {
  String label(BuildContext context) => switch (this) {
    TopRankPeriod.month =>
    context.strings.top_rank_this_month,
    TopRankPeriod.last30Days =>
    context.strings.top_rank_last_30_days,
  };
}

extension TopRankRoleLabels on TopRankRole {
  String label(BuildContext context) => switch (this) {
    TopRankRole.representatives =>
    context.strings.top_rank_representatives,
    TopRankRole.drivers =>
    context.strings.top_rank_drivers,
    TopRankRole.dispatchers =>
    context.strings.top_rank_dispatchers,
    TopRankRole.warehouses =>
    context.strings.top_rank_warehouses,
    TopRankRole.warehouseStaff =>
    context.strings.top_rank_warehouse_staff,
    TopRankRole.vehicles =>
    context.strings.top_rank_vehicles,
  };

  IconData get icon => switch (this) {
    TopRankRole.representatives =>
    Icons.person_outline_rounded,
    TopRankRole.drivers =>
    Icons.local_shipping_outlined,
    TopRankRole.dispatchers =>
    Icons.assignment_outlined,
    TopRankRole.warehouses =>
    Icons.warehouse_outlined,
    TopRankRole.warehouseStaff =>
    Icons.manage_accounts_outlined,
    TopRankRole.vehicles =>
    Icons.directions_car_outlined,
  };
}

class TopRankFilters extends StatelessWidget {
  const TopRankFilters({
    super.key,
    required this.period,
    required this.role,
    required this.onPeriodChanged,
    required this.onRoleChanged,
  });

  final TopRankPeriod period;
  final TopRankRole role;
  final ValueChanged<TopRankPeriod> onPeriodChanged;
  final ValueChanged<TopRankRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ======= Period ======= //
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10,
            children: [
              for (final value in TopRankPeriod.values)
                _RankChip(
                  title: value.label(context),
                  selected: period == value,
                  onTap: () => onPeriodChanged(value),
                ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ======= Warehouse Filter Placeholder ======= //
        // No warehouse query/filter contract supplied by backend.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: AppColors.white0,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: AppColors.grey3),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.top_rank_all_warehouses,
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.grey4,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.grey4,
                size: 17,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ======= Categories ======= //
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 9,
            children: [
              for (final value in TopRankRole.values)
                _RankChip(
                  title: value.label(context),
                  icon: value.icon,
                  selected: role == value,
                  onTap: () => onRoleChanged(value),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankChip extends StatelessWidget {
  const _RankChip({
    required this.title,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.blue4
          : AppColors.white0,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? AppColors.blue3
              : AppColors.grey3,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 7,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? AppColors.primary
                      : AppColors.grey4,
                ),
              Text(
                title,
                style: Styles.textStyle14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.primary
                      : AppColors.black1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
