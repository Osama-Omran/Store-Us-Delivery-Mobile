import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_state.dart';

extension StockTransferFilterLabels on StockTransferFilter {
  String label(BuildContext context) => switch (this) {
    StockTransferFilter.awaitingReceipt =>
      context.strings.stock_transfer_awaiting_acceptance,
    StockTransferFilter.onVehicle => context.strings.stock_transfer_on_vehicle,
    StockTransferFilter.awaitingWarehouse =>
      context.strings.stock_transfer_awaiting_warehouse,
    StockTransferFilter.completed => context.strings.stock_transfer_completed,
    StockTransferFilter.other => context.strings.stock_transfer_other,
  };
}

class StockTransferFilters extends StatelessWidget {
  const StockTransferFilters({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final StockTransferState state;
  final ValueChanged<StockTransferFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = [
      ...StockTransferFilter.values.where(
        (filter) => filter != StockTransferFilter.other,
      ),
      if (state.countFor(StockTransferFilter.other) > 0)
        StockTransferFilter.other,
    ];
    return SingleChildScrollView(
      key: const ValueKey('stock-transfer-filters'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        spacing: 10,
        children: [
          for (final filter in filters)
            Semantics(
              selected: filter == state.filter,
              button: true,
              child: Material(
                color: filter == state.filter
                    ? AppColors.primary
                    : AppColors.white0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: filter == state.filter
                        ? AppColors.primary
                        : AppColors.grey3,
                  ),
                ),
                child: InkWell(
                  key: ValueKey('stock-transfer-filter-${filter.name}'),
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => onChanged(filter),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 9,
                    ),
                    child: Text(
                      context.strings.filter_count_label(
                        filter.label(context),
                        state.countFor(filter),
                      ),
                      style: Styles.textStyle18.copyWith(
                        color: filter == state.filter
                            ? AppColors.white0
                            : AppColors.black1,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
