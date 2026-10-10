import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/sample/sample_treasury.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/cubit/treasury_state.dart';

class TreasuryCubit extends Cubit<TreasuryState> {
  TreasuryCubit() : super(TreasuryState(data: buildSampleTreasury()));

  static TreasuryCubit get(BuildContext context) => BlocProvider.of(context);

  // ======= Preview Controls ======= //
  void selectTab(TreasuryTab tab) {
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab));
  }

  void selectPreview(TreasuryPreview preview) {
    if (preview == state.preview) return;
    emit(state.copyWith(preview: preview));
  }

  void searchInventory(String query) {
    if (query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: query));
  }
}
