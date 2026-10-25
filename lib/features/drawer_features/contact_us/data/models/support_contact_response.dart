class SupportContactResponse {
  const SupportContactResponse({
    required this.success,
    this.data,
    this.message,
  });

  final bool success;
  final SupportContactData? data;
  final String? message;

  factory SupportContactResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return SupportContactResponse(
      success: json['success'] == true,
      data: rawData is Map
          ? SupportContactData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
    );
  }
}

class SupportContactData {
  const SupportContactData({
    required this.phone,
    required this.whatsapp,
    required this.phoneUrl,
    required this.whatsappUrl,
    this.messageEndpoint,
  });

  final String phone;
  final String whatsapp;
  final String phoneUrl;
  final String whatsappUrl;
  final String? messageEndpoint;

  factory SupportContactData.fromJson(Map<String, dynamic> json) {
    return SupportContactData(
      phone: json['phone']?.toString().trim() ?? '',
      whatsapp: json['whatsapp']?.toString().trim() ?? '',
      phoneUrl: json['phone_url']?.toString().trim() ?? '',
      whatsappUrl: json['whatsapp_url']?.toString().trim() ?? '',
      messageEndpoint: json['message_endpoint']?.toString(),
    );
  }
}
