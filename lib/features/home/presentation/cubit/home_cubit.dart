
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';

import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/current_trip_usecase.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final CurrentTripUsecase _currentTripUsecase;
  final GetTripOrdersUsecase _getTripOrdersUsecase;

  HomeCubit(
      this._currentTripUsecase,
      this._getTripOrdersUsecase,
      ) : super(HomeInitial());

  static HomeCubit get(BuildContext context) =>
      BlocProvider.of<HomeCubit>(context);

  int _tripRequestId = 0;
  int _ordersRequestId = 0;

  // ======= Get Current Trip ======= //
  Future<void> getCurrentTrip() async {
    if (isClosed || state is HomeLoadingState) return;

    final requestId = ++_tripRequestId;
    ++_ordersRequestId;

    emit(HomeLoadingState());

    final result = await _currentTripUsecase.call();

    if (isClosed || requestId != _tripRequestId) return;

    CurrentTripData? activeTrip;

    result.when(
      success: (response) {
        if (!response.success) {
          emit(HomeFailureState(response.message));
          return;
        }

        if (response.data == null) {
          emit(HomeEmptyState());
          return;
        }

        activeTrip = response.data;
        emit(HomeSuccessState(response.data!));
      },
      failure: (error) {
        emit(
          HomeFailureState(error.apiErrorModel.message),
        );
      },
    );

    if (activeTrip?.acceptance?.status
        .trim()
        .toUpperCase() ==
        'ACCEPTED') {
      await getTripOrders();
    }
  }

  // ======= Get Trip Orders ======= //
  Future<void> getTripOrders() async {
    if (isClosed) return;

    final currentState = state;

    if (currentState is! HomeSuccessState ||
        currentState.ordersStatus == HomeOrdersStatus.loading) {
      return;
    }

    final trip = currentState.trip;
    final requestId = ++_ordersRequestId;

    emit(
      HomeSuccessState(
        trip,
        ordersStatus: HomeOrdersStatus.loading,
        orders: currentState.orders,
      ),
    );

    final result = await _getTripOrdersUsecase.call(
      tripId: trip.id,
    );

    if (isClosed || requestId != _ordersRequestId) return;

    final latestState = state;

    if (latestState is! HomeSuccessState ||
        latestState.trip.id != trip.id) {
      return;
    }

    result.when(
      success: (response) {
        if (!response.success) {
          emit(
            HomeSuccessState(
              trip,
              ordersStatus: HomeOrdersStatus.failure,
              ordersError: response.message,
            ),
          );
          return;
        }

        emit(
          HomeSuccessState(
            trip,
            ordersStatus: HomeOrdersStatus.success,
            orders: response.data,
          ),
        );
      },
      failure: (error) {
        emit(
          HomeSuccessState(
            trip,
            ordersStatus: HomeOrdersStatus.failure,
            ordersError: error.apiErrorModel.message,
          ),
        );
      },
    );
  }
}
