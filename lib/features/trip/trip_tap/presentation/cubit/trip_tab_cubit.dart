
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';

import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/current_trip_usecase.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

class TripTabCubit extends Cubit<TripTabState> {
  final CurrentTripUsecase _currentTripUsecase;
  final GetTripOrdersUsecase _getTripOrdersUsecase;

  TripTabCubit(
      this._currentTripUsecase,
      this._getTripOrdersUsecase,
      ) : super(TripTabInitial());

  static TripTabCubit get(BuildContext context) =>
      BlocProvider.of<TripTabCubit>(context);

  int _currentTripRequestId = 0;
  int _ordersRequestId = 0;

  // ======= Get Current Trip ======= //
  Future<void> getCurrentTrip() async {
    if (isClosed || state is TripTabLoadingState) return;

    final requestId = ++_currentTripRequestId;

    // Invalidate any older orders request.
    ++_ordersRequestId;

    emit(TripTabLoadingState());

    final result = await _currentTripUsecase.call();

    if (isClosed ||
        requestId != _currentTripRequestId) {
      return;
    }

    CurrentTripData? acceptedTrip;

    result.when(
      success: (response) {
        if (!response.success) {
          emit(
            TripTabFailureState(response.message),
          );
          return;
        }

        final trip = response.data;

        if (trip == null) {
          emit(TripTabEmptyState());
          return;
        }

        emit(TripTabSuccessState(trip));

        if (trip.acceptance?.status
            .trim()
            .toUpperCase() ==
            'ACCEPTED') {
          acceptedTrip = trip;
        }
      },
      failure: (error) {
        emit(
          TripTabFailureState(
            error.apiErrorModel.message,
          ),
        );
      },
    );

    if (acceptedTrip != null) {
      await getTripOrders();
    }
  }

  // ======= Get Trip Orders ======= //
  Future<void> getTripOrders() async {
    if (isClosed) return;

    final currentState = state;

    if (currentState is! TripTabSuccessState ||
        currentState.ordersStatus ==
            TripOrdersStatus.loading) {
      return;
    }

    final trip = currentState.trip;

    if (trip.acceptance?.status
        .trim()
        .toUpperCase() !=
        'ACCEPTED') {
      return;
    }

    final requestId = ++_ordersRequestId;

    emit(
      TripTabSuccessState(
        trip,
        ordersStatus: TripOrdersStatus.loading,
        orders: currentState.orders,
      ),
    );

    final result = await _getTripOrdersUsecase.call(
      tripId: trip.id,
    );

    if (isClosed ||
        requestId != _ordersRequestId) {
      return;
    }

    final latestState = state;

    if (latestState is! TripTabSuccessState ||
        latestState.trip.id != trip.id) {
      return;
    }

    result.when(
      success: (response) {
        if (!response.success) {
          emit(
            TripTabSuccessState(
              trip,
              ordersStatus: TripOrdersStatus.failure,
              ordersError: response.message,
            ),
          );
          return;
        }

        final orders = response.data
            .map(TripOrderModel.fromApi)
            .toList()
          ..sort(
                (a, b) =>
                a.stopNumber.compareTo(b.stopNumber),
          );

        emit(
          TripTabSuccessState(
            trip,
            ordersStatus: TripOrdersStatus.success,
            orders: orders,
          ),
        );
      },
      failure: (error) {
        emit(
          TripTabSuccessState(
            trip,
            ordersStatus: TripOrdersStatus.failure,
            ordersError: error.apiErrorModel.message,
          ),
        );
      },
    );
  }
}
