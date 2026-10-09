
class LoginResponse {
  final bool success;
  final LoginResponseData? data;
  final String? message;

  const LoginResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] == null
          ? null
          : LoginResponseData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      message: json['message'] as String?,
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

class LoginResponseData {
  final String token;
  final String tokenType;
  final LoginUser user;

  const LoginResponseData({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
      user: LoginUser.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }
}

class LoginUser {
  final int id;
  final String name;
  final String employeeId;
  final String? phone;
  final String email;
  final String role;

  const LoginUser({
    required this.id,
    required this.name,
    required this.employeeId,
    this.phone,
    required this.email,
    required this.role,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: json['id'] as int,
      name: json['name'] as String,
      employeeId: json['employee_id'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      role: json['role'] as String,
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
