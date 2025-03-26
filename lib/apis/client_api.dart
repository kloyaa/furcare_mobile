import 'package:dio/dio.dart';
import 'package:furcare_app/core/config/base_url_config.dart';
import 'package:furcare_app/models/owner_info.dart';
import 'package:furcare_app/models/pet_info.dart';

class ClientApi {
  Dio dio = Dio();
  ClientApi(String accessToken) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.headers = {
      'Authorization': 'Bearer $accessToken',
      'nodex-user-origin': 'web',
      'nodex-access-key': 'v7pb6wylg4m0xf0kx5zzoved',
      'nodex-secret-key': 'glrvdwi46mq00fg1oqtdx3rg',
    };
  }

  Future<Response> getMeProfile() async {
    try {
      Response response = await dio.get('/user/v1/profile/me');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getCages() async {
    try {
      Response response = await dio.get('/cage/v1');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getSchedules() async {
    try {
      Response response = await dio.get('/schedule/v1');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getMePets() async {
    try {
      Response response = await dio.get('/pet/v1/me');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> createPet(CreatePetPayload payload) async {
    try {
      Response response = await dio.post('/pet/v1/me', data: payload.toJson());
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> createOwner(OwnerProfilePayload payload) async {
    try {
      Response response = await dio.post('/owner/v1', data: payload.toJson());
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateOwner(OwnerProfilePayload payload) async {
    try {
      Response response = await dio.put('/owner/v1/me', data: payload.toJson());
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getMeOwnerProfile() async {
    try {
      Response response = await dio.get('/owner/v1/me');
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> createMeProfile(Map profile) async {
    try {
      Response response = await dio.post('/user/v1/profile/me', data: profile);
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updateeMeProfile(Map profile) async {
    try {
      Response response = await dio.put('/user/v1/profile/me', data: profile);
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> getMeActivityLog() async {
    try {
      Response response = await dio.get('/activity/v1/me');
      return response;
    } on DioException {
      rethrow;
    }
  }
}
