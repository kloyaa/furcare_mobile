import 'package:dio/dio.dart';
import 'package:furcare_app/core/config/base_url_config.dart';
import 'package:furcare_app/models/booking_payload.dart';

class BookingApi {
  Dio dio = Dio();
  BookingApi(String accessToken) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.headers = {
      'Authorization': 'Bearer $accessToken',
      'nodex-user-origin': 'web',
      'nodex-access-key': 'v7pb6wylg4m0xf0kx5zzoved',
      'nodex-secret-key': 'glrvdwi46mq00fg1oqtdx3rg',
    };
  }

  Future<Response> boardBooking(BoardingPayload payload) async {
    try {
      Response response = await dio.post(
        '/application/v1/boarding',
        data: payload.toJson(),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> groomingBooking(GroomingPayload payload) async {
    try {
      Response response = await dio.post(
        '/application/v1/grooming',
        data: payload.toJson(),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> transitBooking(TransitgPayload payload) async {
    try {
      Response response = await dio.post(
        '/application/v1/transit',
        data: payload.toJson(),
      );

      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getBookingsByAccessToken(String status) async {
    try {
      Response response = await dio.get(
        '/customer/v1/booking',
        queryParameters: {'status': status},
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getBookingDetails(String id) async {
    try {
      Response response = await dio.get('/staff/v1/booking/boarding/$id');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getGroomingDetails(String id) async {
    try {
      Response response = await dio.get('/staff/v1/booking/grooming/$id');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getTransitDetails(String id) async {
    try {
      Response response = await dio.get('/staff/v1/booking/transit/$id');
      return response;
    } on DioException {
      rethrow;
    }
  }
}
