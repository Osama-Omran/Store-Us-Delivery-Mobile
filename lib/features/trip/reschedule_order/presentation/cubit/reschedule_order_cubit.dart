
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';

import 'package:storeus_delivery/features/trip/reschedule_order/data/models/reschedule_order_request_body.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/domain/usecases/reschedule_order_usecase.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/cubit/reschedule_order_state.dart';

class RescheduleOrderCubit extends Cubit<RescheduleOrderState> {
  RescheduleOrderCubit(this._usecase)
      : super(RescheduleOrderInitial());

  final RescheduleOrderUsecase _usecase;

  static RescheduleOrderCubit get(BuildContext context) =>
      BlocProvider.of<RescheduleOrderCubit>(context);

  // ======= Reschedule Order ======= //
  Future<void> rescheduleOrder({
    required int tripId,
    required int orderId,
    required String reason,
    required DateTime rescheduledFor,
  }) async {
    if (isClosed || state is RescheduleOrderLoading) {
      return;
    }

    emit(RescheduleOrderLoading());

    final body = RescheduleOrderRequestBody(
      reason: reason,
      rescheduledFor: rescheduledFor,
    );

    final result = await _usecase.call(
      tripId: tripId,
      orderId: orderId,
      body: body,
    );

    if (isClosed) return;

    result.when(
      success: (response) {
        // The backend response model is not yet provided.
        // Handle an explicit business failure if present.
        if (response is Map &&
            response['success'] == false) {
          emit(
            RescheduleOrderFailure(
              response['message']?.toString() ??
                  'reschedule_order_failed',
            ),
          );
          return;
        }

        emit(RescheduleOrderSuccess());
      },
      failure: (error) {
        final message = error.apiErrorModel.message;

        emit(
          RescheduleOrderFailure(
            message.trim().isNotEmpty
                ? message
                : 'reschedule_order_failed',
          ),
        );
      },
    );
  }
}
