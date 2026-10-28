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

  /// Explicitly append the selected local time-zone offset.
  /// Dart's local DateTime.toIso8601String() omits the offset.
  static String formatRescheduledFor(DateTime local) {
    final wallTime =
        '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}T'
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:00';
    final offset = local.timeZoneOffset;
    final minutes = offset.inMinutes;
    final sign = minutes < 0 ? '-' : '+';
    final absoluteMinutes = minutes.abs();
    final hh = (absoluteMinutes ~/ 60).toString().padLeft(2, '0');
    final mm = (absoluteMinutes % 60).toString().padLeft(2, '0');
    return '$wallTime$sign$hh:$mm';
  }

  Map<String, dynamic> toJson() => {
    'outcome': outcome.apiValue,
    'reason': reason,
    if (outcome == DeliveryOutcomeType.rescheduled)
      'rescheduled_for': rescheduledFor,
    'client_operation_id': clientOperationId,
  };
}
