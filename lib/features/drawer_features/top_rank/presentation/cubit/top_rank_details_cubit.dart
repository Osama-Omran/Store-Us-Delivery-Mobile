import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/domain/usecases/get_top_rank_usecase.dart';

class TopRankDetailsState {
  const TopRankDetailsState({
    required this.entry,
    this.loading = false,
    this.error,
    this.loadedFromDetail = false,
  });

  final TopRankEntry entry;
  final bool loading;
  final String? error;
  final bool loadedFromDetail;
}

class TopRankDetailsCubit extends Cubit<TopRankDetailsState> {
  TopRankDetailsCubit(this._usecase, TopRankEntry entry)
    : super(TopRankDetailsState(entry: entry));

  final GetTopRankUsecase _usecase;

  Future<void> load({
    required String range,
    required String category,
    required String entity,
  }) async {
    final fallback = state.entry;

    emit(TopRankDetailsState(entry: fallback, loading: true));

    try {
      final result = await _usecase.call(
        range: range,
        category: category,
        entity: entity,
      );

      if (isClosed) return;

      result.when(
        success: (response) {
          final data = response.data;
          final detail = data?.detail;

          emit(
            TopRankDetailsState(
              entry: detail != null && detail.id == entity ? detail : fallback,
              loadedFromDetail: detail != null && detail.id == entity,
            ),
          );
        },
        failure: (error) {
          emit(
            TopRankDetailsState(
              entry: fallback,
              error: error.apiErrorModel.message.toString(),
            ),
          );
        },
      );
    } catch (_) {
      if (isClosed) return;

      emit(
        TopRankDetailsState(
          entry: fallback,
          error: 'top_rank_details_load_failed',
        ),
      );
    }
  }
}
