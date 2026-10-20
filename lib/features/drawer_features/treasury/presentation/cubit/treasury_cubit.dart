import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/sample/sample_treasury.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/domain/usecases/get_treasury_wallet_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/cubit/treasury_state.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/current_trip_usecase.dart';

import '../../../../../core/helpers/apis/api_result.dart' show ApiResultPatterns;

class TreasuryCubit extends Cubit<TreasuryState> {
  TreasuryCubit(this._currentTrip, this._getWallet)
      : super(TreasuryState(data: buildSampleTreasury()));

  final CurrentTripUsecase _currentTrip;
  final GetTreasuryWalletUsecase _getWallet;
  int _requestId = 0;

  static TreasuryCubit get(BuildContext context) => BlocProvider.of(context);

  /// Resolve the real trip ID; never hardcode trip 30 or use sample trips.
  Future<void> loadWallet() async {
    if (isClosed || state.walletLoading) return;
    final requestId = ++_requestId;
    emit(state.copyWith(
      walletLoading: true,
      walletLoadStarted: true,
      walletError: null,
      walletHasNoTrip: false,
    ));

    try {
      int? tripId;
      String? currentTripError;
      var noTrip = false;

      final tripResult = await _currentTrip.call();
      if (isClosed || requestId != _requestId) return;

      tripResult.when(
        success: (response) {
          if (!response.success) {
            currentTripError = response.message;
          } else if (response.data == null) {
            noTrip = true;
          } else {
            tripId = response.data!.id;
          }
        },
        failure: (error) {
          currentTripError = error.apiErrorModel.message;
        },
      );

      if (noTrip) {
        emit(state.copyWith(
          wallet: null,
          walletLoading: false,
          walletHasNoTrip: true,
        ));
        return;
      }
      if (tripId == null || tripId! <= 0) {
        emit(state.copyWith(
          walletLoading: false,
          walletError: currentTripError ?? '',
        ));
        return;
      }

      final walletResult = await _getWallet.call(tripId: tripId!);
      if (isClosed || requestId != _requestId) return;

      walletResult.when(
        success: (response) {
          if (response.success && response.data != null) {
            emit(state.copyWith(
              wallet: response.data,
              walletLoading: false,
              walletError: null,
            ));
          } else {
            emit(state.copyWith(
              walletLoading: false,
              walletError: response.message ?? '',
            ));
          }
        },
        failure: (error) {
          emit(state.copyWith(
            walletLoading: false,
            walletError: error.apiErrorModel.message,
          ));
        },
      );
    } catch (_) {
      if (isClosed || requestId != _requestId) return;
      emit(state.copyWith(walletLoading: false, walletError: ''));
    }
  }

  void selectTab(TreasuryTab tab) {
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab));
    if (tab == TreasuryTab.wallet) unawaited(loadWallet());
  }

  // Kept for existing inventory-side preview compatibility; no wallet filter UI.
  void selectPreview(TreasuryPreview preview) {
    if (preview == state.preview) return;
    emit(state.copyWith(preview: preview));
  }

  void searchInventory(String query) {
    if (query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: query));
  }
}
