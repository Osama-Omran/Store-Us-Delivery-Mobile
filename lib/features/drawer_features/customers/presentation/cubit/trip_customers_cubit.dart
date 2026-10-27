import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart'; // Required for the project's ApiResult flow.
import 'package:storeus_delivery/features/drawer_features/customers/domain/usecases/get_trip_customers_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/cubit/trip_customers_state.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/current_trip_usecase.dart';

class TripCustomersCubit extends Cubit<TripCustomersState> {
  TripCustomersCubit(this._currentTrip, this._getCustomers)
    : super(const TripCustomersState());

  final CurrentTripUsecase _currentTrip;
  final GetTripCustomersUsecase _getCustomers;
  bool _working = false;

  static TripCustomersCubit get(BuildContext context) =>
      context.read<TripCustomersCubit>();

  Future<void> load() async {
    if (_working || isClosed) return;
    _working = true;
    emit(const TripCustomersState(status: TripCustomersStatus.loading));
    try {
      final tripResult = await _currentTrip.call();
      if (isClosed) return;
      int? tripId;
      String tripNumber = '';
      String? errorMessage;

      tripResult.when(
        success: (response) {
          if (!response.success ||
              response.data == null ||
              response.data!.id <= 0) {
            errorMessage = response.message;
          } else {
            tripId = response.data!.id;
            tripNumber = response.data!.number;
          }
        },
        failure: (error) {
          errorMessage = error.apiErrorModel.message;
        },
      );
      if (tripId == null) {
        emit(
          TripCustomersState(
            status: TripCustomersStatus.failure,
            errorMessage: errorMessage,
          ),
        );
        return;
      }

      final ApiResult<TripCustomersResponse> result = await _getCustomers.call(
        tripId: tripId!,
      );
      if (isClosed) return;
      result.when(
        success: (response) {
          emit(
            TripCustomersState(
              status: response.success
                  ? TripCustomersStatus.success
                  : TripCustomersStatus.failure,
              tripId: tripId,
              tripNumber: tripNumber,
              customers: response.success ? response.data : const [],
              errorMessage: response.message,
            ),
          );
        },
        failure: (error) {
          emit(
            TripCustomersState(
              status: TripCustomersStatus.failure,
              tripId: tripId,
              tripNumber: tripNumber,
              errorMessage: error.apiErrorModel.message,
            ),
          );
        },
      );
    } catch (error) {
      if (!isClosed) {
        emit(
          TripCustomersState(
            status: TripCustomersStatus.failure,
            errorMessage: 'trip_customers_load_failed',
          ),
        );
      }
    } finally {
      _working = false;
    }
  }
}
