import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/auth_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:provider/provider.dart';

enum AuthRole { admin, staff, customer }

enum AuthResult {
  success,
  invalidRole,
  invalidCredentials,
  needsProfile,
  error,
}

class AuthResultData {
  final AuthResult result;
  final String message;
  final String? accessToken;

  AuthResultData({
    required this.result,
    required this.message,
    this.accessToken,
  });
}

/// A service class to manage authentication operations
class AuthService {
  final BuildContext context;
  final String platform;
  final AuthRole allowedRole;

  AuthService({
    required this.context,
    required this.platform,
    required this.allowedRole,
  });

  /// Handle login process with proper error handling
  Future<AuthResultData> login({
    required String username,
    required String password,
  }) async {
    final authenticationApi = AuthenticationApi(platform);
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    try {
      Response response = await authenticationApi.login(
        username: username,
        password: password,
      );

      // Parse response
      final String role = response.data["role"].toString().toLowerCase();

      // Validate role
      if (role != _roleToString(allowedRole)) {
        String appType = "";
        switch (allowedRole) {
          case AuthRole.admin:
            appType = "web";
            break;
          case AuthRole.staff:
          case AuthRole.customer:
            appType = "mobile";
            break;
        }

        return AuthResultData(
          result: AuthResult.invalidRole,
          message: "Please use the Furcare $appType app, Thank you.",
        );
      }

      // Login successful
      if (response.data["data"] != null) {
        accessTokenProvider.setAuthToken(response.data['data']);
      } else {
        LoginResponse loginResponse = LoginResponse.fromJson(response.data);
        accessTokenProvider.setAuthToken(loginResponse.accessToken);
      }

      return AuthResultData(
        result: AuthResult.success,
        message: "Login successful",
        accessToken: response.data["data"] ?? response.data["accessToken"],
      );
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);

      // Handle case when user needs to create profile
      if (errorResponse.code == '0104') {
        if (errorResponse.accessToken != null) {
          accessTokenProvider.setAuthToken(errorResponse.accessToken!);
        }

        return AuthResultData(
          result: AuthResult.needsProfile,
          message: e.response?.data["message"] ?? "Profile setup required",
          accessToken: errorResponse.accessToken,
        );
      }

      return AuthResultData(
        result: AuthResult.error,
        message:
            e.response?.data["message"] ?? "Login failed. Please try again.",
      );
    } catch (e) {
      return AuthResultData(
        result: AuthResult.error,
        message: "An unexpected error occurred. Please try again.",
      );
    }
  }

  /// Handle registration process with proper error handling
  Future<AuthResultData> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final authenticationApi = AuthenticationApi(platform);
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    try {
      Response response = await authenticationApi.register(
        username: username,
        email: email,
        password: password,
      );

      final String role = response.data["role"].toString().toLowerCase();

      // Validate role
      if (role != _roleToString(allowedRole)) {
        return AuthResultData(
          result: AuthResult.invalidRole,
          message: "Please use the Furcare web app, Thank you.",
        );
      }

      // Registration successful
      final registerResponse = RegistrationResponse.fromJson(response.data);
      accessTokenProvider.setAuthToken(registerResponse.accessToken);

      return AuthResultData(
        result: AuthResult.success,
        message: "Registration successful",
        accessToken: registerResponse.accessToken,
      );
    } on DioException catch (e) {
      return AuthResultData(
        result: AuthResult.error,
        message:
            e.response?.data["message"] ??
            "Registration failed. Please try again.",
      );
    } catch (e) {
      return AuthResultData(
        result: AuthResult.error,
        message: "An unexpected error occurred. Please try again.",
      );
    }
  }

  String _roleToString(AuthRole role) {
    switch (role) {
      case AuthRole.admin:
        return "administrator";
      case AuthRole.staff:
        return "staff";
      case AuthRole.customer:
        return "customer";
    }
  }
}
