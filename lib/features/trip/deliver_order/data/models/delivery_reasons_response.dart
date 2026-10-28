/// Server-owned reason values. Never translate, trim, or modify the values.
enum DeliveryReasonCategory { cancellation, partialDelivery, rescheduling }

class DeliveryReasonsData {
  const DeliveryReasonsData({
    required this.cancellation,
    required this.partialDelivery,
    required this.rescheduling,
  });

  final List<String> cancellation;
  final List<String> partialDelivery;
  final List<String> rescheduling;

  List<String> forCategory(DeliveryReasonCategory category) => switch (category) {
    DeliveryReasonCategory.cancellation => cancellation,
    DeliveryReasonCategory.partialDelivery => partialDelivery,
    DeliveryReasonCategory.rescheduling => rescheduling,
  };

  factory DeliveryReasonsData.fromJson(Map<String, dynamic> json) =>
      DeliveryReasonsData(
        cancellation: List<String>.unmodifiable(
          (json['cancellation'] as List).cast<String>(),
        ),
        partialDelivery: List<String>.unmodifiable(
          (json['partial_delivery'] as List).cast<String>(),
        ),
        rescheduling: List<String>.unmodifiable(
          (json['rescheduling'] as List).cast<String>(),
        ),
      );
}

class DeliveryReasonsResponse {
  const DeliveryReasonsResponse({required this.success, required this.data});

  final bool success;
  final DeliveryReasonsData data;

  factory DeliveryReasonsResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true || json['data'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid delivery reasons response');
    }
    return DeliveryReasonsResponse(
      success: true,
      data: DeliveryReasonsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
