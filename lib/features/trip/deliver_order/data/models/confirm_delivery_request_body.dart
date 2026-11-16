import 'dart:io';

import 'package:dio/dio.dart';

class ConfirmDeliveryRequestBody {
  const ConfirmDeliveryRequestBody({
    required this.clientOperationId,
    required this.items,
    required this.extraItems,
    required this.collectedAmount,
    this.partialDeliveryReason,
    this.receiptPhoto,
  });

  final String clientOperationId;
  final List<ConfirmDeliveryItem> items;
  final List<ConfirmDeliveryExtraItem> extraItems;
  final num collectedAmount;

  /// Required by the API for partial deliveries. Preserve the original
  /// server-provided value (including whitespace) when serializing.
  final String? partialDeliveryReason;

  // Optional receipt photo
  final File? receiptPhoto;

  Map<String, dynamic> toJson() => {
    'client_operation_id': clientOperationId,
    'items': items.map((e) => e.toJson()).toList(),
    'extra_items': extraItems.map((e) => e.toJson()).toList(),
    'collected_amount': collectedAmount,
    'payment_method': 'cash',
    if (partialDeliveryReason != null &&
        partialDeliveryReason!.trim().isNotEmpty)
      'partial_delivery_reason': partialDeliveryReason,
  };

  Future<FormData> toFormData() async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('client_operation_id', clientOperationId),
      MapEntry('collected_amount', collectedAmount.toString()),
      const MapEntry('payment_method', 'cash'),
    ]);

    if (partialDeliveryReason != null &&
        partialDeliveryReason!.trim().isNotEmpty) {
      formData.fields.add(
        MapEntry('partial_delivery_reason', partialDeliveryReason!),
      );
    }

    for (var i = 0; i < items.length; i++) {
      for (final entry in items[i].toJson().entries) {
        formData.fields.add(
          MapEntry('items[$i][${entry.key}]', entry.value.toString()),
        );
      }
    }

    for (var i = 0; i < extraItems.length; i++) {
      for (final entry in extraItems[i].toJson().entries) {
        formData.fields.add(
          MapEntry('extra_items[$i][${entry.key}]', entry.value.toString()),
        );
      }
    }

    if (receiptPhoto != null) {
      formData.files.add(
        MapEntry(
          'receipt_photo',
          await MultipartFile.fromFile(
            receiptPhoto!.path,
            filename: receiptPhoto!.uri.pathSegments.last,
          ),
        ),
      );
    }

    return formData;
  }
}

class ConfirmDeliveryItem {
  const ConfirmDeliveryItem({
    required this.lineId,
    required this.itemCode,
    required this.qty,
  });

  final String lineId;
  final String itemCode;
  final num qty;

  Map<String, dynamic> toJson() => {
    'line_id': lineId,
    'item_code': itemCode,
    'qty': qty,
  };
}

class ConfirmDeliveryExtraItem {
  const ConfirmDeliveryExtraItem({required this.itemCode, required this.qty});

  final String itemCode;
  final num qty;

  Map<String, dynamic> toJson() => {'item_code': itemCode, 'qty': qty};
}
