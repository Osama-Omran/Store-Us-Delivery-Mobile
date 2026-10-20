/// POST /trips/{tripId}/orders/{orderId}/retry-collection.
/// Use only the ORIGINAL client_operation_id from pending_collections.
class RetryCollectionRequestBody {
  const RetryCollectionRequestBody({
    required this.clientOperationId,
    required this.collectedAmount,
    this.notes,
  });

  final String clientOperationId;
  final num collectedAmount;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'client_operation_id': clientOperationId,
    'collected_amount': collectedAmount,
    'payment_method': 'cash',
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
  };
}
