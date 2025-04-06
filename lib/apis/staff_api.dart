import 'package:dio/dio.dart';
import 'package:furcare_app/core/config/base_url_config.dart';
import 'package:furcare_app/models/booking_payload.dart';

class StaffApi {
  Dio dio = Dio();
  StaffApi(String accessToken) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.headers = {
      'Authorization': 'Bearer $accessToken',
      'nodex-user-origin': 'web',
      'nodex-access-key': 'v7pb6wylg4m0xf0kx5zzoved',
      'nodex-secret-key': 'glrvdwi46mq00fg1oqtdx3rg',
    };
  }

  Future<Response> getBookingsByAccessToken(String status) async {
    try {
      Response response = await dio.get(
        '/staff/v1/booking',
        queryParameters: {'status': status},
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateBookingStatus(
    UpdateBookingStatusPayload payload,
  ) async {
    try {
      Response response = await dio.put(
        '/staff/v1/booking/status',
        data: payload.toJson(),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}
