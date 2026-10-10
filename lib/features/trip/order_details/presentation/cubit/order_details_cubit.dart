
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';

import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/update_delivery_location_request_body.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/get_order_details_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/update_delivery_location_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(
      this._getOrderDetailsUsecase,
      this._getTripOrdersUsecase,
      this._updateDeliveryLocationUsecase,
      ) : super(OrderDetailsInitial());

  final GetOrderDetailsUsecase _getOrderDetailsUsecase;
  final GetTripOrdersUsecase _getTripOrdersUsecase;
  final UpdateOrderDeliveryLocationUsecase _updateDeliveryLocationUsecase;

  static OrderDetailsCubit get(BuildContext context) =>
      BlocProvider.of<OrderDetailsCubit>(context);

  int _requestId = 0;
  bool _locationUpdated = false;

  // ======= Get Order Details ======= //
  Future<void> getOrderDetails({
    required int tripId,
    required int orderId,
  }) async {
    if (isClosed) return;

    final requestId = ++_requestId;

    emit(OrderDetailsLoadingState());

    final detailsResult = await _getOrderDetailsUsecase.call(
      tripId: tripId,
      orderId: orderId,
    );

    if (isClosed || requestId != _requestId) return;

    OrderDetailsData? details;

    detailsResult.when(
      success: (response) {
        if (response.success && response.data != null) {
          details = response.data;

          emit(
            OrderDetailsSuccessState(
              response.data!,
              locationUpdated: _locationUpdated,
            ),
          );
        } else {
          emit(
            OrderDetailsFailureState(response.message),
          );
        }
      },
      failure: (error) {
        emit(
          OrderDetailsFailureState(
            error.apiErrorModel.message,
          ),
        );
      },
    );

    if (details == null) return;

    // ======= Get Latest Customer Address ======= //
    final ordersResult = await _getTripOrdersUsecase.call(
      tripId: tripId,
    );

    if (isClosed || requestId != _requestId) return;

    TripOrderData? tripOrder;

    ordersResult.when(
      success: (response) {
        if (!response.success) return;

        for (final item in response.data) {
          if (item.id == orderId) {
            tripOrder = item;
            break;
          }
        }
      },
      failure: (_) {
        // Keep order details visible.
      },
    );

    emit(
      OrderDetailsSuccessState(
        details!,
        tripOrder: tripOrder,
        locationUpdated: _locationUpdated,
      ),
    );
  }


// ======= Update Delivery Location ======= //
  Future<String?> updateDeliveryLocation({
    required int tripId,
    required int orderId,
    required UpdateDeliveryLocationBody body,
  }) async {
    if (isClosed) return 'order_location_save_failed';

    final currentState = state;

    if (currentState is! OrderDetailsSuccessState ||
        currentState.isSavingLocation) {
      return 'order_location_save_failed';
    }

    // Reset any success message from a previous update.
    _locationUpdated = false;

    emit(
      currentState.copyWith(
        isSavingLocation: true,
        locationUpdated: false,
      ),
    );

    String? errorMessage;

    try {
      final result = await _updateDeliveryLocationUsecase.call(
        tripId: tripId,
        orderId: orderId,
        body: body,
      );

      result.when(
        success: (response) {
          // A 2xx response may still contain a business failure.
          if (response is Map &&
              response['success'] == false) {
            final message =
            response['message']?.toString().trim();

            errorMessage =
            message != null && message.isNotEmpty
                ? message
                : 'order_location_save_failed';
          }
        },
        failure: (error) {
          final message =
          error.apiErrorModel.message.trim();

          errorMessage = message.isNotEmpty
              ? message
              : 'order_location_save_failed';
        },
      );
    } catch (_) {
      errorMessage = 'order_location_save_failed';
    }

    if (isClosed) return 'order_location_save_failed';

    final success = errorMessage == null;

    _locationUpdated = success;

    final latestState = state;

    if (latestState is OrderDetailsSuccessState) {
      emit(
        latestState.copyWith(
          isSavingLocation: false,
          locationUpdated: success,
        ),
      );
    }

    return errorMessage;
  }
}
