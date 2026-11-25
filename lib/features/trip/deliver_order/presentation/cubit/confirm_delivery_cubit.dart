import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/confirm_delivery_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/usecases/confirm_delivery_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/confirm_delivery_state.dart';

class ConfirmDeliveryCubit extends Cubit<ConfirmDeliveryState> {
  ConfirmDeliveryCubit(this._usecase) : super(ConfirmDeliveryInitial());

  final ConfirmDeliveryUsecase _usecase;

  static ConfirmDeliveryCubit get(BuildContext context) =>
      BlocProvider.of<ConfirmDeliveryCubit>(context);

  String? _operationId;
  ConfirmDeliveryRequestBody? _pendingBody;

  String _generateOperationId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  void _clearOperation() {
    _pendingBody = null;
    _operationId = null;
  }

  bool _isSameRequest(
    ConfirmDeliveryRequestBody old,
    ConfirmDeliveryRequestBody next,
  ) =>
      jsonEncode(old.toJson()) == jsonEncode(next.toJson()) &&
      old.receiptPhoto?.path == next.receiptPhoto?.path;

  Future<void> confirmDelivery({
    required int tripId,
    required int orderId,
    required List<ConfirmDeliveryItem> items,
    List<ConfirmDeliveryExtraItem> extraItems = const [],
    required num collectedAmount,
    required num expectedAmount,
    bool isPartial = false,
    String? partialDeliveryReason,
    String? receiptPhotoPath,
  }) async {
    if (isClosed ||
        state is ConfirmDeliveryLoading ||
        state is ConfirmDeliverySuccess) {
      return;
    }

    if (items.isEmpty ||
        items.any(
          (item) =>
              item.lineId.trim().isEmpty ||
              item.itemCode.trim().isEmpty ||
              item.qty <= 0 ||
              !item.qty.isFinite,
        ) ||
        extraItems.any(
          (item) =>
              item.itemCode.trim().isEmpty ||
              item.qty <= 0 ||
              !item.qty.isFinite,
        ) ||
        extraItems.map((item) => item.itemCode).toSet().length !=
            extraItems.length) {
      emit(ConfirmDeliveryFailure('delivery_invalid_items'));
      return;
    }

    // The backend requires the exact selected reason for partial delivery.
    // Never send a partial confirmation without it.
    if (isPartial &&
        (partialDeliveryReason == null ||
            partialDeliveryReason.trim().isEmpty)) {
      emit(ConfirmDeliveryFailure('delivery_partial_reason_required'));
      return;
    }

    // Cash only: collect the original selected items PLUS all extra items.
    if (!expectedAmount.isFinite ||
        expectedAmount <= 0 ||
        !collectedAmount.isFinite ||
        collectedAmount <= 0 ||
        (collectedAmount * 100).round() != (expectedAmount * 100).round()) {
      emit(ConfirmDeliveryFailure('delivery_invalid_amount'));
      return;
    }

    _operationId ??= _generateOperationId();
    final path = receiptPhotoPath?.trim();
    final receiptPhoto = path == null || path.isEmpty ? null : File(path);
    final candidate = ConfirmDeliveryRequestBody(
      clientOperationId: _operationId!,
      items: List.unmodifiable(items),
      extraItems: List.unmodifiable(extraItems),
      collectedAmount: collectedAmount,
      partialDeliveryReason: isPartial ? partialDeliveryReason : null,
      receiptPhoto: receiptPhoto,
    );

    // A timeout/5xx might mean the server completed the operation. Reuse the
    // exact original body and idempotency key; never retry changed quantities.
    if (_pendingBody != null && !_isSameRequest(_pendingBody!, candidate)) {
      emit(ConfirmDeliveryFailure('delivery_confirm_retry_original'));
      return;
    }
    final body = _pendingBody ?? candidate;
    _pendingBody = body;

    emit(ConfirmDeliveryLoading());
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
            // Explicit business rejection: allow corrected new operation.
            _clearOperation();
            emit(
              ConfirmDeliveryFailure(
                response['message']?.toString() ?? 'delivery_confirm_failed',
              ),
            );
            return;
          }
          _clearOperation();
          emit(ConfirmDeliverySuccess(response));
        },
        failure: (error) {
          final status = error.apiErrorModel.errorCode;
          final definiteRejection =
              status != null &&
              status >= 400 &&
              status < 500 &&
              !const {408, 409, 425, 429}.contains(status);
          if (definiteRejection) _clearOperation();
          final message = error.apiErrorModel.message;
          emit(
            ConfirmDeliveryFailure(
              message.trim().isNotEmpty ? message : 'delivery_confirm_failed',
            ),
          );
        },
      );
    } catch (_) {
      if (!isClosed) {
        // Uncertain result; keep the immutable pending request for retry.
        emit(ConfirmDeliveryFailure('delivery_confirm_failed'));
      }
    }
  }
}
