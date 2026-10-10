import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/sample/sample_top_rank.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/cubit/top_rank_state.dart';

class TopRankCubit extends Cubit<TopRankState> {
  TopRankCubit()
    : super(
        TopRankState(
          entries: buildSampleTopRank(
            period: TopRankPeriod.thisMonth,
            role: TopRankRole.representatives,
            warehouse: TopRankWarehouse.all,
          ),
        ),
      );

  static TopRankCubit get(BuildContext context) => BlocProvider.of(context);

  void selectPeriod(TopRankPeriod period) {
    if (period == state.period) return;
    _select(period: period);
  }

  void selectRole(TopRankRole role) {
    if (role == state.role) return;
    _select(role: role);
  }

  void selectWarehouse(TopRankWarehouse warehouse) {
    if (warehouse == state.warehouse) return;
    _select(warehouse: warehouse);
  }

  // ======= Apply Preview Filters ======= //
  void _select({
    TopRankPeriod? period,
    TopRankRole? role,
    TopRankWarehouse? warehouse,
  }) {
    final selectedPeriod = period ?? state.period;
    final selectedRole = role ?? state.role;
    final selectedWarehouse = warehouse ?? state.warehouse;

    emit(
      TopRankState(
        period: selectedPeriod,
        role: selectedRole,
        warehouse: selectedWarehouse,
        entries: buildSampleTopRank(
          period: selectedPeriod,
          role: selectedRole,
          warehouse: selectedWarehouse,
        ),
      ),
    );
  }
}
