class LoginRequestBody {
  final String username;
  final String password;
  final String deviceName;

  const LoginRequestBody({
    required this.username,
    required this.password,
    required this.deviceName,
  });

  factory LoginRequestBody.fromJson(Map<String, dynamic> json) {
    return LoginRequestBody(
      username: json['username'] as String,
      password: json['password'] as String,
      deviceName: json['device_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'device_name': deviceName,
    };
  }
}
