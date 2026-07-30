import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/storage_service.dart';
import '../models/user.dart';

/// Parcours client : OTP UNE SEULE FOIS à l'inscription (vérifie le numéro),
/// puis connexion par numéro + mot de passe ensuite — jamais d'OTP à chaque
/// connexion. Voir ClientAuthController côté API pour le détail du flux.
class AuthService {
  final _dio = ApiClient().dio;

  Future<void> sendOtp(String phone) async {
    try {
      await _dio.post('/auth/client/send-otp', data: {'phone': phone});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AppUser> register({
    required String name,
    required String phone,
    required String otpCode,
    required String password,
    required bool termsAccepted,
  }) async {
    try {
      final response = await _dio.post('/auth/client/register', data: {
        'name': name,
        'phone': phone,
        'otp_code': otpCode,
        'password': password,
        'terms_accepted': termsAccepted,
      });

      final token = response.data['token'];
      await StorageService.saveToken(token);

      return AppUser.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AppUser> login({required String phone, required String password}) async {
    try {
      final response = await _dio.post('/auth/client/login', data: {
        'phone': phone,
        'password': password,
      });

      final token = response.data['token'];
      await StorageService.saveToken(token);

      return AppUser.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> sendPasswordResetOtp(String phone) async {
    try {
      await _dio.post('/auth/client/forgot-password/send-otp', data: {'phone': phone});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> resetPassword({required String phone, required String otpCode, required String password}) async {
    try {
      await _dio.post('/auth/client/forgot-password/reset', data: {
        'phone': phone,
        'otp_code': otpCode,
        'password': password,
      });
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
