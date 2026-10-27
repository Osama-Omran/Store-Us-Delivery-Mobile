// The backend response was not supplied. This parser only trusts an explicit
// stable customer identifier; it never invents one from the submitted name.
class CreateCustomerResponse {
  const CreateCustomerResponse({
    required this.success,
    this.customerId,
    this.customerName,
    this.message,
  });

  final bool success;
  final String? customerId;
  final String? customerName;
  final String? message;

  factory CreateCustomerResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;
    final nested = dataMap?['customer'];
    final nestedMap = nested is Map ? Map<String, dynamic>.from(nested) : null;
    final rawId = dataMap?['customer_id'] ??
        dataMap?['id'] ??
        (nested is String ? nested : null) ??
        nestedMap?['id'] ??
        nestedMap?['customer_id'] ??
        json['customer_id'] ??
        json['id'];
    final customerId = rawId?.toString().trim();
    final rawName = dataMap?['customer_name'] ??
        nestedMap?['customer_name'] ??
        json['customer_name'];

    return CreateCustomerResponse(
      success: json['success'] == true,
      customerId: customerId?.isNotEmpty == true ? customerId : null,
      customerName: rawName?.toString(),
      message: json['message']?.toString(),
    );
  }
}
