import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_state.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_card.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_filters.dart';

import 'stock_transfer_error.dart';
import 'stock_transfer_shimmer.dart';

class StockTransferBody extends StatelessWidget {
  const StockTransferBody({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StockTransferCubit, StockTransferState>(
        builder: (context, state) {
          final cubit = StockTransferCubit.get(context);
          if (state.isLoading && !state.hasLoaded) {
            return const StockTransferShimmer();
          }
          if (state.error != null && !state.hasLoaded) {
            return const StockTransferError();
          }

          final transfers = state.filteredTransfers;
          return Column(
            children: [
              StockTransferFilters(),
              if (state.isRefreshing)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: CustomLoadingIndicator(size: 36),
                ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const StockTransferError(),
                ),
              if (state.hasMorePages)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    context.strings.stock_transfer_more_pages_notice,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle14.copyWith(color: AppColors.grey4),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: cubit.load,
                  child: ListView.separated(
                    key: ValueKey('stock-transfer-list-${state.filter.name}'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 125),
                    itemCount: transfers.isEmpty ? 1 : transfers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (transfers.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            context.strings.stock_transfer_empty,
                            textAlign: TextAlign.center,
                            style: Styles.textStyle16.copyWith(
                              color: AppColors.grey4,
                            ),
                          ),
                        );
                      }
                      final transfer = transfers[index];
                      return StockTransferCard(
                        key: ValueKey('stock-transfer-${transfer.id}'),
                        transfer: transfer,
                        referenceDate: state.referenceDate,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      );
}
