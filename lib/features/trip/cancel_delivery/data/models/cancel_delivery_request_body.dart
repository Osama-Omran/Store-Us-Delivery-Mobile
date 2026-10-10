
class CancelDeliveryRequestBody {
  const CancelDeliveryRequestBody({
    required this.reason,
  });

  final String reason;

  Map<String, dynamic> toJson() => {
    'outcome': 'CANCELLED',
    'reason': reason.trim(),
  };
}
