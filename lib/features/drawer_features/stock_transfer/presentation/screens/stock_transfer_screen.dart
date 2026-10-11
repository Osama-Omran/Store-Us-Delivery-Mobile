import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_state.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_card.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_filters.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_header.dart';

class StockTransferScreen extends StatelessWidget {
  const StockTransferScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StockTransferCubit>(),
      child: _StockTransferBody(onBack: onBack),
    );
  }
}

class _StockTransferBody extends StatelessWidget {
  const _StockTransferBody({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======= Header ======= //
            StockTransferHeader(onBack: onBack),

            // ======= Filters and Transfers ======= //
            Expanded(
              child: BlocBuilder<StockTransferCubit, StockTransferState>(
                builder: (context, state) {
                  final cubit = StockTransferCubit.get(context);
                  final transfers = state.filteredTransfers;

                  return Column(
                    children: [
                      StockTransferFilters(
                        state: state,
                        onChanged: cubit.selectFilter,
                      ),
                      Expanded(
                        child: ListView.separated(
                          key: ValueKey(
                            'stock-transfer-list-${state.filter.name}',
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 125),
                          itemCount: transfers.isEmpty ? 1 : transfers.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            if (transfers.isEmpty) {
                              return Padding(
                                key: const ValueKey('stock-transfer-empty'),
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
                              key: ValueKey(
                                'stock-transfer-${transfer.number}',
                              ),
                              transfer: transfer,
                              referenceDate: state.referenceDate,
                            );
                          },
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
