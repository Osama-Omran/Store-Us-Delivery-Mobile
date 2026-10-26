import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';

import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/retry_collection_request_body.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/update_delivery_location_request_body.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/get_order_details_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/update_delivery_location_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/utils/order_collection_policy.dart';

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
          emit(OrderDetailsFailureState(response.message));
        }
      },
      failure: (error) {
        emit(OrderDetailsFailureState(error.apiErrorModel.message));
      },
    );

    if (details == null) return;

    // ======= Get Latest Customer Address ======= //
    final ordersResult = await _getTripOrdersUsecase.call(tripId: tripId);

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

  bool _collectionRequestInProgress = false;

  /// Returns null ONLY if the backend accepted the collection request.
  /// Never retries automatically on connection errors: first refresh status.
  Future<String?> retryCollection({
    required int tripId,
    required int orderId,
    required String clientOperationId,
    required num collectedAmount,
    String? notes,
  }) async {
    if (isClosed || _collectionRequestInProgress) {
      return 'عملية تحصيل قيد التنفيذ بالفعل';
    }
    if (clientOperationId.trim().isEmpty ||
        collectedAmount <= 0 ||
        !collectedAmount.isFinite ||
        ((collectedAmount * 100).round() - collectedAmount * 100).abs() > 0.0001) {
      return 'راجع مبلغ التحصيل وبيانات العملية';
    }

    final current = state;
    if (current is! OrderDetailsSuccessState ||
        current.tripOrder?.canRetryCollection != true ||
        !OrderCollectionPolicy.showCollectButton(current.tripOrder?.paymentStatus) ||
        !current.tripOrder!.pendingCollections.any(
          (p) => p.clientOperationId == clientOperationId,
        )) {
      return 'العملية غير متاحة للتحصيل حاليًا. حدّث حالة الطلب.';
    }

    _collectionRequestInProgress = true;
    emit(current.copyWith(isSubmittingCollection: true));
    String? message;

    try {
      final result = await _getOrderDetailsUsecase.retryCollection(
        tripId: tripId,
        orderId: orderId,
        body: RetryCollectionRequestBody(
          clientOperationId: clientOperationId,
          collectedAmount: collectedAmount,
          notes: notes,
        ),
      );
      result.when(
        success: (response) {
          if (response is Map && response['success'] == false) {
            message = response['message']?.toString().trim();
            if (message == null || message!.isEmpty) {
              message = 'السيرفر لم يؤكد نجاح التحصيل. حدّث حالة الطلب.';
            }
          }
        },
        failure: (error) {
          message = error.apiErrorModel.message.trim();
          if (message == null || message!.isEmpty) {
            message = 'تعذر تأكيد التحصيل. حدّث حالة الطلب أولًا.';
          }
        },
      );
    } catch (_) {
      message = 'تعذر تأكيد التحصيل. حدّث حالة الطلب قبل إعادة المحاولة.';
    } finally {
      _collectionRequestInProgress = false;
      if (!isClosed && state is OrderDetailsSuccessState) {
        emit((state as OrderDetailsSuccessState).copyWith(
          isSubmittingCollection: false,
        ));
      }
    }
    return message;
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

    emit(currentState.copyWith(isSavingLocation: true, locationUpdated: false));

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
          if (response is Map && response['success'] == false) {
            final message = response['message']?.toString().trim();

            errorMessage = message != null && message.isNotEmpty
                ? message
                : 'order_location_save_failed';
          }
        },
        failure: (error) {
          final message = error.apiErrorModel.message.trim();

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
        latestState.copyWith(isSavingLocation: false, locationUpdated: success),
      );
    }

    return errorMessage;
  }
}
