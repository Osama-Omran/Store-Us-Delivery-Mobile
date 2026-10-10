import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/cubit/treasury_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/cubit/treasury_state.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_header.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_inventory_widgets.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_selectors.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_wallet_cards.dart';

class TreasuryScreen extends StatelessWidget {
  const TreasuryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TreasuryCubit>(),
      child: const _TreasuryBody(),
    );
  }
}

class _TreasuryBody extends StatefulWidget {
  const _TreasuryBody();

  @override
  State<_TreasuryBody> createState() => _TreasuryBodyState();
}

class _TreasuryBodyState extends State<_TreasuryBody> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======= Header ======= //
            const TreasuryHeader(),

            Expanded(
              child: BlocBuilder<TreasuryCubit, TreasuryState>(
                builder: (context, state) {
                  final cubit = TreasuryCubit.get(context);

                  return ListView(
                    key: ValueKey('treasury-scroll-${state.tab.name}'),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 125),
                    children: [
                      // ======= Tabs ======= //
                      TreasuryTabs(
                        value: state.tab,
                        onChanged: cubit.selectTab,
                      ),
                      const SizedBox(height: 20),

                      // ======= Wallet ======= //
                      if (state.tab == TreasuryTab.wallet) ...[
                        TreasuryPreviewSelector(
                          value: state.preview,
                          onChanged: cubit.selectPreview,
                        ),
                        const SizedBox(height: 16),
                        if (!state.hasTrip)
                          const TreasuryEmptyWallet()
                        else ...[
                          TreasuryTripStrip(data: state.data),
                          const SizedBox(height: 16),
                          TreasuryBalanceCard(balance: state.custodyBalance),
                          const SizedBox(height: 16),
                          if (state.preview == TreasuryPreview.settled) ...[
                            TreasurySettlementNotice(
                              preview: state.preview,
                              balance: state.custodyBalance,
                            ),
                            const SizedBox(height: 16),
                          ],
                          TreasuryWalletStatistics(data: state.data),
                          const SizedBox(height: 28),
                          Text(
                            context.strings.treasury_collection_details,
                            style: Styles.textStyle24.copyWith(
                              color: AppColors.black1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (final collection in state.collections) ...[
                            TreasuryCollectionCard(
                              key: ValueKey(
                                'treasury-collection-${collection.orderNumber}',
                              ),
                              collection: collection,
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (state.preview == TreasuryPreview.activeTrip)
                            TreasurySettlementNotice(
                              preview: state.preview,
                              balance: state.custodyBalance,
                            ),
                        ],
                      ],

                      // ======= Vehicle Goods ======= //
                      if (state.tab == TreasuryTab.vehicleGoods) ...[
                        if (state.hasTrip) ...[
                          TreasuryInventorySummary(
                            data: state.data,
                            remainingUnits: state.remainingUnits,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (state.inventory.isEmpty)
                          TreasuryEmptyInventory(preview: state.preview)
                        else ...[
                          TreasuryInventorySearch(
                            controller: _searchController,
                            onChanged: cubit.searchInventory,
                            onClear: () {
                              _searchController.clear();
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
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.grey4,
                          ),
                        ),
                      ],
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
