import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';

extension TopRankPeriodLabels on TopRankPeriod {
  String label(BuildContext context) => switch (this) {
    TopRankPeriod.today => context.strings.top_rank_today,
    TopRankPeriod.week => context.strings.top_rank_week,
    TopRankPeriod.thisMonth => context.strings.top_rank_this_month,
    TopRankPeriod.previousMonth => context.strings.top_rank_previous_month,
  };
}

extension TopRankWarehouseLabels on TopRankWarehouse {
  String label(BuildContext context) => switch (this) {
    TopRankWarehouse.all => context.strings.top_rank_all_warehouses,
    TopRankWarehouse.october => context.strings.top_rank_warehouse_october,
    TopRankWarehouse.nasrCity => context.strings.top_rank_warehouse_nasr_city,
  };
}

extension TopRankRoleLabels on TopRankRole {
  String label(BuildContext context) => switch (this) {
    TopRankRole.representatives => context.strings.top_rank_representatives,
    TopRankRole.drivers => context.strings.top_rank_drivers,
    TopRankRole.dispatchers => context.strings.top_rank_dispatchers,
  };

  String bestLabel(BuildContext context) => switch (this) {
    TopRankRole.representatives =>
      context.strings.top_rank_best_representatives,
    TopRankRole.drivers => context.strings.top_rank_best_drivers,
    TopRankRole.dispatchers => context.strings.top_rank_best_dispatchers,
  };

  String winnerLabel(BuildContext context) => switch (this) {
    TopRankRole.representatives => context.strings.top_rank_best_representative,
    TopRankRole.drivers => context.strings.top_rank_best_driver,
    TopRankRole.dispatchers => context.strings.top_rank_best_dispatcher,
  };

  IconData get icon => switch (this) {
    TopRankRole.representatives => Icons.person_outline_rounded,
    TopRankRole.drivers => Icons.local_shipping_outlined,
    TopRankRole.dispatchers => Icons.assignment_outlined,
  };
}

class TopRankFilters extends StatelessWidget {
  const TopRankFilters({
    super.key,
    required this.period,
    required this.role,
    required this.warehouse,
    required this.onPeriodChanged,
    required this.onRoleChanged,
    required this.onWarehouseChanged,
  });

  final TopRankPeriod period;
  final TopRankRole role;
  final TopRankWarehouse warehouse;
  final ValueChanged<TopRankPeriod> onPeriodChanged;
  final ValueChanged<TopRankRole> onRoleChanged;
  final ValueChanged<TopRankWarehouse> onWarehouseChanged;

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
                _TopRankFilterChip(
                  key: ValueKey('top-rank-period-${value.name}'),
                  title: value.label(context),
                  selected: value == period,
                  onTap: () => onPeriodChanged(value),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ======= Warehouse ======= //
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white0,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.grey3),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TopRankWarehouse>(
              key: const ValueKey('top-rank-warehouse'),
              value: warehouse,
              isExpanded: true,
              dropdownColor: AppColors.white0,
              borderRadius: BorderRadius.circular(20),
              style: Theme.of(context).textTheme.bodyMedium!
                  .merge(Styles.textStyle16)
                  .copyWith(color: AppColors.black1),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.black1,
              ),
              items: [
                for (final value in TopRankWarehouse.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(
                      value.label(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onWarehouseChanged(value);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ======= Role ======= //
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10,
            children: [
              for (final value in TopRankRole.values)
                _TopRankFilterChip(
                  key: ValueKey('top-rank-role-${value.name}'),
                  title: value.label(context),
                  icon: value.icon,
                  selected: value == role,
                  isRole: true,
                  onTap: () => onRoleChanged(value),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopRankFilterChip extends StatelessWidget {
  const _TopRankFilterChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.icon,
    this.isRole = false,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isRole;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? isRole
              ? AppColors.rankTeal
              : AppColors.white0
        : AppColors.grey4;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? isRole
                  ? AppColors.rankTealLight
                  : AppColors.primary
            : AppColors.white0,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? Colors.transparent : AppColors.grey3,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                if (icon != null) Icon(icon, size: 20, color: color),
                Text(title, style: Styles.textStyle16.copyWith(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
