
class RescheduleOrderRequestBody {
  const RescheduleOrderRequestBody({
    required this.reason,
    required this.rescheduledFor,
  });

  final String reason;
  final DateTime rescheduledFor;

  Map<String, dynamic> toJson() => {
    'outcome': 'RESCHEDULED',
    'reason': reason.trim(),
    'rescheduled_for':
    rescheduledFor.toUtc().toIso8601String(),
  };
}
