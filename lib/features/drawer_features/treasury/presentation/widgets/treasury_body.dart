import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../../data/models/treasury_models.dart';
import '../cubit/treasury_cubit.dart';
import '../cubit/treasury_state.dart';
import 'treasury_header.dart';
import 'treasury_selectors.dart';
import 'treasury_wallet_live.dart';
import 'treasury_vehicle_goods.dart';

class TreasuryBody extends StatefulWidget {
  const TreasuryBody({super.key});
  @override
  State<TreasuryBody> createState() => _TreasuryBodyState();
}

class _TreasuryBodyState extends State<TreasuryBody> {
  // The inventory search survives switching between both tabs.
  final _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.grey0,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TreasuryHeader(),
          Expanded(
            child: BlocBuilder<TreasuryCubit, TreasuryState>(
              buildWhen: (previous, current) => previous.tab != current.tab,
              builder: (context, state) => ListView(
                key: ValueKey('treasury-scroll-${state.tab.name}'),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 125),
                children: [
                  const TreasuryTabs(),
                  const SizedBox(height: 20),
                  if (state.tab == TreasuryTab.wallet)
                    const _TreasuryWalletSection(),
                  if (state.tab == TreasuryTab.vehicleGoods)
                    TreasuryVehicleGoods(controller: _searchController),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TreasuryWalletSection extends StatelessWidget {
  const _TreasuryWalletSection();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TreasuryCubit, TreasuryState>(
        buildWhen: (previous, current) =>
            previous.wallet != current.wallet ||
            previous.walletLoading != current.walletLoading ||
            previous.walletHasNoTrip != current.walletHasNoTrip ||
            previous.walletError != current.walletError,
        builder: (context, state) => TreasuryWalletLive(
          state: state,
          onRefresh: TreasuryCubit.get(context).loadWallet,
        ),
      );
}
