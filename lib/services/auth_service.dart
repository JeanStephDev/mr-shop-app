import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/storage_service.dart';
import '../models/user.dart';

class AuthService {
  final _dio = ApiClient().dio;

  Future<void> sendOtp(String phone) async {
    try {
      await _dio.post('/auth/client/send-otp', data: {'phone': phone});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AppUser> verifyOtp({required String phone, required String code, String? name}) async {
    try {
      final response = await _dio.post('/auth/client/verify-otp', data: {
        'phone': phone,
        'code': code,
        if (name != null) 'name': name,
      });

      final token = response.data['token'];
      await StorageService.saveToken(token);

      return AppUser.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AppUser> me() async {
    try {
      final response = await _dio.get('/auth/client/me');
      return AppUser.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _dio.post('/auth/client/fcm-token', data: {'fcm_token': fcmToken});
    } on DioException {
      // silencieux : ce n'est pas bloquant pour l'utilisateur si ça échoue
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/client/logout');
    } on DioException {
      // on déconnecte localement même si l'appel réseau échoue
    } finally {
      await StorageService.clearToken();
    }
  }
}
