import 'package:dio/dio.dart';
import 'package:furcare_app/core/config/base_url_config.dart';

class AuthenticationApi {
  Dio dio = Dio();
  AuthenticationApi(String origin) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.headers = {
      'nodex-user-origin': origin,
      'nodex-access-key': 'v7pb6wylg4m0xf0kx5zzoved',
      'nodex-secret-key': 'glrvdwi46mq00fg1oqtdx3rg',
    };
  }

  Future<Response> login({
    required String username,
    required String password,
  }) async {
    try {
      Response response = await dio.post(
        '/auth/v1/login',
        data: {"username": username, "password": password},
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      Response response = await dio.post(
        '/auth/v1/register',
        data: {"email": email, "username": username, "password": password},
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}

class EnrollmentApi {
  Dio dio = Dio();
  EnrollmentApi(String accessToken) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.headers = {
      'Authorization': 'Bearer $accessToken',
      'nodex-user-origin': 'web',
      'nodex-access-key': 'v7pb6wylg4m0xf0kx5zzoved',
      'nodex-secret-key': 'glrvdwi46mq00fg1oqtdx3rg',
    };
  }

  Future<Response> ekyc({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String middleName,
    required String lastName,
    required String birthdate,
    required String presentAddress,
    required String permanentAddress,
    required String contactEmail,
    required String contactNo,
    required String gender,
  }) async {
    try {
      Response response = await dio.post(
        '/auth/v1/ekyc',
        data: {
          "account": {
            "username": username,
            "email": email,
            "password": password,
          },
          "profile": {
            "firstName": firstName,
            "middleName": middleName,
            "lastName": lastName,
            "birthdate": birthdate,
            "address": {
              "present": presentAddress,
              "permanent": permanentAddress,
            },
            "contact": {"email": contactEmail, "number": contactNo},
            "gender": gender,
          },
        },
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}
