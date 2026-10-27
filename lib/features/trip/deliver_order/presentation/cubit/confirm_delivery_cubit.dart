import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
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

  // Generate UUID v4 once for the same logical operation.
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

  Future<void> confirmDelivery({
    required int tripId,
    required int orderId,
    required List<ConfirmDeliveryItem> items,
    required num collectedAmount,
    required num expectedAmount,

    // Optional receipt image path
    String? receiptPhotoPath,
  }) async {
    if (isClosed ||
        state is ConfirmDeliveryLoading ||
        state is ConfirmDeliverySuccess) {
      return;
    }

    // ======= Validate Delivery Items ======= //
    if (items.isEmpty ||
        items.any(
          (item) =>
              item.lineId.trim().isEmpty ||
              item.itemCode.trim().isEmpty ||
              item.qty <= 0,
        )) {
      emit(ConfirmDeliveryFailure('delivery_invalid_items'));
      return;
    }

    // ======= Validate Full Collection ======= //
    // Cash only - No partial or unpaid delivery.
    if (!expectedAmount.isFinite ||
        expectedAmount <= 0 ||
        !collectedAmount.isFinite ||
        collectedAmount <= 0 ||
        (collectedAmount * 100).round() != (expectedAmount * 100).round()) {
      emit(ConfirmDeliveryFailure('delivery_invalid_amount'));
      return;
    }

    // ======= Generate Operation ID ======= //
    _operationId ??= _generateOperationId();

    // ======= Optional Receipt Photo ======= //
    final imagePath = receiptPhotoPath?.trim();

    final File? receiptPhoto = imagePath != null && imagePath.isNotEmpty
        ? File(imagePath)
        : null;

    // ======= Create Request Body ======= //
    final body = ConfirmDeliveryRequestBody(
      clientOperationId: _operationId!,
      items: items,
      extraItems: const [],
      collectedAmount: collectedAmount,
      receiptPhoto: receiptPhoto,
    );

    emit(ConfirmDeliveryLoading());

    try {
      // ======= Call API ======= //
      final ApiResult<dynamic> result = await _usecase.call(
        tripId: tripId,
        orderId: orderId,
        body: body,
      );

      if (isClosed) return;

      result.when(
        success: (response) {
          if (response is Map && response['success'] == false) {
            emit(
              ConfirmDeliveryFailure(
                response['message']?.toString() ?? 'delivery_confirm_failed',
              ),
            );
            return;
          }

          emit(ConfirmDeliverySuccess(response));
        },
        failure: (error) {
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
        emit(ConfirmDeliveryFailure('delivery_confirm_failed'));
      }
    }
  }
}
