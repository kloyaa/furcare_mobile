import 'package:dio/dio.dart';
import 'package:furcare_app/core/config/base_url_config.dart';

class BranchApi {
  Dio dio = Dio();
  BranchApi(String accessToken) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.headers = {
      'Authorization': 'Bearer $accessToken',
      'nodex-user-origin': 'mobile',
      'nodex-access-key': 'v7pb6wylg4m0xf0kx5zzoved',
      'nodex-secret-key': 'glrvdwi46mq00fg1oqtdx3rg',
    };
  }

  Future<Response> getBranches() async {
    try {
      Response response = await dio.get('/branch/v1');
      return response;
    } on DioException {
      rethrow;
    }
  }
}
