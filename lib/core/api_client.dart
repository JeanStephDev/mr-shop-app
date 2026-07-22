import 'package:dio/dio.dart';
import 'constants.dart';
import 'navigation_service.dart';
import 'storage_service.dart';

/// Client HTTP unique de l'app, avec injection automatique du token Bearer
/// et gestion centralisée des erreurs 401 (déconnecte l'utilisateur).
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final hadToken = await StorageService.getToken() != null;
          await StorageService.clearToken();
          // Ne redirige que si l'utilisateur était réellement connecté (évite de
          // rediriger sur un 401 renvoyé par une route publique mal appelée).
          if (hadToken) {
            NavigationService.goToLogin();
          }
        }
        handler.next(error);
      },
    ));
  }
}

/// Exception applicative simple pour remonter un message lisible à l'UI,
/// à partir des erreurs de validation Laravel (422) ou autres.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  factory ApiException.fromDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return ApiException(data['message'].toString());
    }
    if (data is Map && data['errors'] != null) {
      final errors = data['errors'] as Map;
      final firstError = errors.values.first;
      return ApiException(firstError is List ? firstError.first.toString() : firstError.toString());
    }
    return ApiException('Une erreur est survenue. Vérifiez votre connexion.');
  }
}
