// Both operations share the same backend endpoint.
enum DeliveryOutcomeType {
  cancelled('CANCELLED'),
  rescheduled('RESCHEDULED');

  const DeliveryOutcomeType(this.apiValue);

  final String apiValue;
}

class DeliveryOutcomeRequestBody {
  const DeliveryOutcomeRequestBody({
    required this.outcome,
    required this.reason,
    required this.clientOperationId,
    this.rescheduledFor,
  });

  final DeliveryOutcomeType outcome;
  final String reason;
  final String clientOperationId;
  final String? rescheduledFor;

  Map<String, dynamic> toJson() => {
    'outcome': outcome.apiValue,
    'reason': reason,
    if (outcome == DeliveryOutcomeType.rescheduled)
      'rescheduled_for': rescheduledFor,
    'client_operation_id': clientOperationId,
  };
}
