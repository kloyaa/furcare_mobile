import 'package:dio/dio.dart';
import 'package:furcare_app/core/config/base_url_config.dart';
import 'package:furcare_app/models/active_status.dart';
import 'package:furcare_app/models/ekyc.dart';

class AdminApi {
  Dio dio = Dio();
  AdminApi(String accessToken) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.headers = {
      'Authorization': 'Bearer $accessToken',
      'nodex-user-origin': 'web',
      'nodex-access-key': 'v7pb6wylg4m0xf0kx5zzoved',
      'nodex-secret-key': 'glrvdwi46mq00fg1oqtdx3rg',
    };
  }

  Future<Response> getStaffs() async {
    try {
      Response response = await dio.get('/admin/v1/staffs');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getCustomers() async {
    try {
      Response response = await dio.get('/admin/v1/customers');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> deleteUser(String id) async {
    try {
      Response response = await dio.delete('/admin/v1/remove/user/$id');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateProfileActiveStatus(UpdateActiveStatus payload) async {
    try {
      Response response = await dio.put(
        '/admin/v1/management/user-status',
        data: payload.toJson(),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateProfile(Map profile, String id) async {
    try {
      Response response = await dio.put(
        '/admin/v1/management/profile/$id',
        data: profile,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> geCheckins() async {
    try {
      Response response = await dio.get('/admin/v1/stats/checkins');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getServiceUsages() async {
    try {
      Response response = await dio.get('/admin/v1/stats/service-usage');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getTransactions() async {
    try {
      Response response = await dio.get('/admin/v1/transactions');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> enrollment(Ekyc ekyc) async {
    try {
      ekyc.profile.isActive;
      Response response = await dio.post('/auth/v1/ekyc', data: ekyc.toJson());
      return response;
    } on DioException {
      rethrow;
    }
  }
}
