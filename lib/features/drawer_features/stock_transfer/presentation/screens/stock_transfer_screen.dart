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
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_header.dart';

// StockTransferCubit is owned by LayoutScreen so the Drawer badge and
// this screen always use the same server data and request lifecycle.
class StockTransferScreen extends StatelessWidget {
  const StockTransferScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StockTransferHeader(onBack: onBack),
            Expanded(
              child: BlocBuilder<StockTransferCubit, StockTransferState>(
                builder: (context, state) {
                  final cubit = StockTransferCubit.get(context);
                  if (state.isLoading && !state.hasLoaded) {
                    return const Center(
                      child: CustomLoadingIndicator(size: 96),
                    );
                  }
                  if (state.error != null && !state.hasLoaded) {
                    return _StockTransferError(
                      message: context.strings.stock_transfer_load_failed,
                      onRetry: cubit.load,
                    );
                  }

                  final transfers = state.filteredTransfers;
                  return Column(
                    children: [
                      StockTransferFilters(
                        state: state,
                        onChanged: cubit.selectFilter,
                      ),
                      if (state.isRefreshing)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: CustomLoadingIndicator(size: 36),
                        ),
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _StockTransferError(
                            message: context.strings.stock_transfer_load_failed,
                            onRetry: cubit.load,
                          ),
                        ),
                      if (state.hasMorePages)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            context.strings.stock_transfer_more_pages_notice,
                            textAlign: TextAlign.center,
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.grey4,
                            ),
                          ),
                        ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: cubit.load,
                          child: ListView.separated(
                            key: ValueKey(
                              'stock-transfer-list-${state.filter.name}',
                            ),
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 125),
                            itemCount: transfers.isEmpty ? 1 : transfers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              if (transfers.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 32,
                                  ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockTransferError extends StatelessWidget {
  const _StockTransferError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.localizedErrorMessage(message),
              textAlign: TextAlign.center,
              style: Styles.textStyle14.copyWith(color: AppColors.grey4),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.strings.stock_transfer_retry),
            ),
          ],
        ),
      ),
    );
  }
}
