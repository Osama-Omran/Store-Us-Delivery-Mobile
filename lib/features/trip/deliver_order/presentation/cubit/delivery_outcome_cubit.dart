import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/usecases/submit_delivery_outcome_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_state.dart';

class DeliveryOutcomeCubit extends Cubit<DeliveryOutcomeState> {
  DeliveryOutcomeCubit(this._usecase) : super(DeliveryOutcomeInitial());

  final SubmitDeliveryOutcomeUsecase _usecase;

  static DeliveryOutcomeCubit get(BuildContext context) =>
      BlocProvider.of<DeliveryOutcomeCubit>(context);

  String? _pendingPayload;
  String? _pendingOperationId;

  void resetFailure() {
    if (!isClosed && state is DeliveryOutcomeFailure) {
      emit(DeliveryOutcomeInitial());
    }
  }

  /// Generate the UUID locally; no extra dependency is required.
  static String _createUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  Future<void> submit({
    required int tripId,
    required int orderId,
    required DeliveryOutcomeType outcome,
    required String reason,
    String? rescheduledFor,
  }) async {
    if (isClosed || state is DeliveryOutcomeLoading ||
        state is DeliveryOutcomeSuccess) {
      return;
    }

    final trimmedReason = reason.trim();
    if (tripId <= 0 || orderId <= 0 || trimmedReason.isEmpty) {
      emit(DeliveryOutcomeFailure('delivery_outcome_invalid_reason'));
      return;
    }

    if (outcome == DeliveryOutcomeType.rescheduled) {
      final dateTime = rescheduledFor == null
          ? null
          : DateTime.tryParse(rescheduledFor);
      // Require an explicit timezone designator, not a naive timestamp.
      final hasTimeZone = rescheduledFor != null &&
          RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(rescheduledFor);
      if (!hasTimeZone || dateTime == null ||
          !dateTime.isAfter(DateTime.now())) {
        emit(DeliveryOutcomeFailure('delivery_outcome_invalid_date'));
        return;
      }
    }

    // Idempotency: reuse the UUID only when retrying exactly the same payload.
    // Edits, including changes to reason/time/outcome/order, start a NEW operation.
    final payload = jsonEncode([
      tripId,
      orderId,
      outcome.apiValue,
      trimmedReason,
      outcome == DeliveryOutcomeType.rescheduled ? rescheduledFor : null,
    ]);
    if (_pendingPayload != payload) {
      _pendingPayload = payload;
      _pendingOperationId = _createUuidV4();
    }

    final body = DeliveryOutcomeRequestBody(
      outcome: outcome,
      reason: trimmedReason,
      rescheduledFor: outcome == DeliveryOutcomeType.rescheduled
          ? rescheduledFor
          : null,
      clientOperationId: _pendingOperationId!,
    );

    emit(DeliveryOutcomeLoading());

    try {
      final ApiResult<dynamic> result = await _usecase.call(
        tripId: tripId,
        orderId: orderId,
        body: body,
      );
      if (isClosed) return;

      result.when(
        success: (response) {
          if (response is Map && response['success'] == false) {
            emit(DeliveryOutcomeFailure(
              response['message']?.toString() ?? 'delivery_outcome_failed',
            ));
            return;
          }
          emit(DeliveryOutcomeSuccess(outcome: outcome, response: response));
        },
        failure: (error) {
          final message = error.apiErrorModel.message;
          emit(DeliveryOutcomeFailure(
            message.trim().isEmpty ? 'delivery_outcome_failed' : message,
          ));
        },
      );
    } catch (_) {
      if (!isClosed) emit(DeliveryOutcomeFailure('delivery_outcome_failed'));
    }
  }
}
