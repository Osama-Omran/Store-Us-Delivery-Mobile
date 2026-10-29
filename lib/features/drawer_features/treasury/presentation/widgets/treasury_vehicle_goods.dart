import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../cubit/treasury_cubit.dart';
import '../cubit/treasury_state.dart';
import 'treasury_inventory_widgets.dart';

class TreasuryVehicleGoods extends StatelessWidget {
  const TreasuryVehicleGoods({super.key, required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TreasuryCubit, TreasuryState>(
        buildWhen: (previous, current) =>
            previous.data != current.data ||
            previous.preview != current.preview ||
            previous.searchQuery != current.searchQuery,
        builder: (context, state) {
          final cubit = TreasuryCubit.get(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.hasTrip) ...[
                TreasuryInventorySummary(),
                const SizedBox(height: 16),
              ],
              if (state.inventory.isEmpty)
                TreasuryEmptyInventory(preview: state.preview)
              else ...[
                TreasuryInventorySearch(
                  controller: controller,
                  onChanged: cubit.searchInventory,
                  onClear: () {
                    controller.clear();
                    cubit.searchInventory('');
                  },
                ),
                const SizedBox(height: 16),
                if (state.filteredInventory.isEmpty)
                  Padding(
                    key: const ValueKey('treasury-no-search-results'),
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      context.strings.treasury_no_search_results,
                      textAlign: TextAlign.center,
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.grey4,
                      ),
                    ),
                  ),
                for (final item in state.filteredInventory) ...[
                  TreasuryInventoryCard(
                    key: ValueKey('treasury-item-${item.code}'),
                    item: item,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
              const SizedBox(height: 4),
              Text(
                context.strings.treasury_inventory_read_only,
                textAlign: TextAlign.center,
                style: Styles.textStyle14.copyWith(color: AppColors.grey4),
              ),
            ],
          );
        },
      );
}
