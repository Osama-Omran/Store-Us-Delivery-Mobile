
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/data/models/cancel_delivery_request_body.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/domain/usecases/cancel_delivery_usecase.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/cubit/cancel_delivery_state.dart';

class CancelDeliveryCubit extends Cubit<CancelDeliveryState> {
  CancelDeliveryCubit(this._usecase)
      : super(CancelDeliveryInitial());

  final CancelDeliveryUsecase _usecase;

  static CancelDeliveryCubit get(BuildContext context) =>
      BlocProvider.of<CancelDeliveryCubit>(context);

  // ======= Cancel Delivery ======= //
  Future<void> cancelDelivery({
    required int tripId,
    required int orderId,
    required String reason,
  }) async {
    if (isClosed || state is CancelDeliveryLoading ||
        state is CancelDeliverySuccess) {
      return;
    }

    if (reason.trim().isEmpty) {
      emit(CancelDeliveryFailure('cancel_reason_required'));
      return;
    }

    emit(CancelDeliveryLoading());

    final result = await _usecase.call(
      tripId: tripId,
      orderId: orderId,
      body: CancelDeliveryRequestBody(reason: reason),
    );

    if (isClosed) return;

    result.when(
      success: (response) {
        // The API response is dynamic.
        if (response is Map && response['success'] == false) {
          emit(
            CancelDeliveryFailure(
              response['message']?.toString() ??
                  'cancel_delivery_failed',
            ),
          );
          return;
        }

        emit(CancelDeliverySuccess());
      },
      failure: (error) {
        final dynamic rawMessage =
            error.apiErrorModel.message;

        final message = rawMessage is String
            ? rawMessage.trim()
            : '';

        emit(
          CancelDeliveryFailure(
            message.isNotEmpty
                ? message
                : 'cancel_delivery_failed',
          ),
        );
      },
    );
  }
}
