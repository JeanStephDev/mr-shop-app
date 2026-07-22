import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/storage_service.dart';
import '../models/ad.dart';

class AdService {
  final _dio = ApiClient().dio;

  /// Renvoie la pub d'ouverture si (et seulement si) le backend juge que
  /// l'utilisateur est éligible aujourd'hui (voir règles non-intrusives côté API).
  /// Peut renvoyer `null` -> dans ce cas, ne rien afficher.
  Future<Ad?> getSplashAd() async {
    try {
      final deviceId = await StorageService.getOrCreateDeviceId();
      final response = await _dio.get('/ads/splash', queryParameters: {'device_id': deviceId});
      if (response.data == null) return null;
      return Ad.fromJson(response.data);
    } on DioException {
      return null; // une pub qui échoue à charger ne doit jamais bloquer l'app
    }
  }

  Future<List<Ad>> getBanners({String position = 'banner_home_top'}) async {
    try {
      final response = await _dio.get('/ads/banners', queryParameters: {'position': position});
      return (response.data as List).map((a) => Ad.fromJson(a)).toList();
    } on DioException {
      return [];
    }
  }

  Future<void> trackImpression(int adId) async {
    try {
      await _dio.post('/ads/$adId/impression');
    } on DioException {
      // pas grave si ça échoue, ne jamais gêner l'utilisateur pour une pub
    }
  }

  Future<void> trackClick(int adId) async {
    try {
      await _dio.post('/ads/$adId/click');
    } on DioException {}
  }
}
