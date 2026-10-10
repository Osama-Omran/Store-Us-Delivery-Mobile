
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';

import 'package:storeus_delivery/features/home/domain/usecases/get_trip_history_usecase.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_state.dart';

class HomeHistoryCubit extends Cubit<HomeHistoryState> {
  final GetTripHistoryUsecase _getTripHistoryUsecase;

  HomeHistoryCubit(this._getTripHistoryUsecase)
      : super(HomeHistoryInitial());

  static HomeHistoryCubit get(BuildContext context) =>
      BlocProvider.of<HomeHistoryCubit>(context);

  // ======= Get Trip History ======= //
  Future<void> getTripHistory() async {
    if (isClosed ||
        state is HomeHistoryLoadingState) {
      return;
    }

    emit(HomeHistoryLoadingState());

    final result = await _getTripHistoryUsecase.call();

    if (isClosed) return;

    result.when(
      success: (response) {
        if (!response.success) {
          emit(
            HomeHistoryFailureState(response.message),
          );
          return;
        }

        emit(HomeHistorySuccessState(response.data));
      },
      failure: (error) {
        emit(
          HomeHistoryFailureState(
            error.apiErrorModel.message,
          ),
        );
      },
    );
  }
}
