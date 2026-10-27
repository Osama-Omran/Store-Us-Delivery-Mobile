import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/domain/usecases/get_top_rank_usecase.dart';

import 'top_rank_state.dart';

class TopRankCubit extends Cubit<TopRankState> {
  TopRankCubit(this._usecase) : super(const TopRankState());

  final GetTopRankUsecase _usecase;

  int _requestId = 0;

  static TopRankCubit get(BuildContext context) => context.read<TopRankCubit>();

  Future<void> load({
    TopRankPeriod? period,
    TopRankRole? role,
    bool fetchAllCategories = false,
  }) async {
    final selectedPeriod = period ?? state.period;
    final selectedRole = role ?? state.role;

    final requestId = ++_requestId;

    emit(
      TopRankState(period: selectedPeriod, role: selectedRole, isLoading: true),
    );

    try {
      final result = await _usecase.call(
        range: selectedPeriod.apiValue,
        category: fetchAllCategories ? null : selectedRole.apiValue,
      );

      if (isClosed || requestId != _requestId) return;

      result.when(
        success: (response) {
          final data = response.data;
          final category = data?.categories[selectedRole.apiValue];

          if (data == null || category == null) {
            emit(
              TopRankState(
                period: selectedPeriod,
                role: selectedRole,
                error: 'top_rank_category_empty',
              ),
            );
            return;
          }

          emit(
            TopRankState(
              period: selectedPeriod,
              role: selectedRole,
              category: category,
              periodData: data.period,
              warnings: data.warnings,
            ),
          );
        },
        failure: (error) {
          final message = error.apiErrorModel.message.toString().trim();

          emit(
            TopRankState(
              period: selectedPeriod,
              role: selectedRole,
              error: message.isNotEmpty && message != 'null'
                  ? message
                  : 'top_rank_load_failed',
            ),
          );
        },
      );
    } catch (_) {
      if (isClosed || requestId != _requestId) return;

      emit(
        TopRankState(
          period: selectedPeriod,
          role: selectedRole,
          error: 'top_rank_load_failed',
        ),
      );
    }
  }

  void selectPeriod(TopRankPeriod value) {
    if (value == state.period) return;

    load(period: value);
  }

  void selectRole(TopRankRole value) {
    if (value == state.role) return;

    load(role: value);
  }

  void retry() {
    load();
  }
}
