class LoginResponse {
  final String message;
  final String code;
  final String role;
  final String accessToken;

  LoginResponse({
    required this.message,
    required this.code,
    required this.role,
    required this.accessToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'],
      code: json['code'],
      role: json['role'],
      accessToken: json['data'],
    );
  }
}

class RegistrationResponse {
  final String message;
  final String code;
  final String role;
  final String accessToken;

  RegistrationResponse({
    required this.message,
    required this.code,
    required this.role,
    required this.accessToken,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      message: json['message'],
      code: json['code'],
      role: json['role'],
      accessToken: json['data'],
    );
  }
}

class ErrorResponse {
  final String message;
  final String code;
  final String? accessToken; // Declare accessToken as nullable

  ErrorResponse({
    required this.message,
    required this.code,
    required this.accessToken,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'],
      code: json['code'],
      accessToken: json['data'],
    );
  }
}
