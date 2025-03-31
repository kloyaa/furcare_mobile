import 'package:dio/dio.dart';
import 'package:furcare_app/core/config/base_url_config.dart';

class FeesApi {
  Dio dio = Dio();
  FeesApi(String accessToken) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.headers = {
      'Authorization': 'Bearer $accessToken',
      'nodex-user-origin': 'mobile',
      'nodex-access-key': 'v7pb6wylg4m0xf0kx5zzoved',
      'nodex-secret-key': 'glrvdwi46mq00fg1oqtdx3rg',
    };
  }

  Future<Response> getServiceFees({queryParameters}) async {
    try {
      Response response = await dio.get(
        '/service/v1/fees',
        queryParameters: queryParameters,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getGroomingServiceFees({queryParameters}) async {
    try {
      Response response = await dio.get(
        '/service/v1/grooming/fees',
        queryParameters: queryParameters,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}
