
class MeResponse {
  final bool success;
  final AccountUser? data;
  final String? message;

  const MeResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory MeResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return MeResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] is Map
          ? AccountUser.fromJson(
        Map<String, dynamic>.from(
          json['data'] as Map,
        ),
      )
          : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class AccountUser {
  final int id;
  final String name;
  final String employeeId;
  final String? phone;
  final String email;
  final String role;

  const AccountUser({
    required this.id,
    required this.name,
    required this.employeeId,
    this.phone,
    required this.email,
    required this.role,
  });

  factory AccountUser.fromJson(
      Map<String, dynamic> json,
      ) {
    return AccountUser(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      employeeId:
      json['employee_id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'employee_id': employeeId,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }
}
