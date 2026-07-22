/// Constantes globales de l'app. Adapte [apiBaseUrl] selon l'environnement
/// (à remplacer par la vraie URL une fois le VPS déployé, voir DEPLOIEMENT.md du backend).
class AppConstants {
  // ⚠️ À changer : mets ton domaine réel une fois le DNS/VPS en place.
  // En attendant, tu peux pointer vers ton serveur Laravel local (php artisan serve)
  // pendant les tests, ex: 'http://10.0.2.2:8000/api/v1' pour l'émulateur Android.
  static const String apiBaseUrl = 'https://www.hexa-node.site/api/v1';

  static const String appName = 'MR Shop';
  static const String currency = 'FCFA';

  static const String authTokenKey = 'mr_shop_auth_token';
  static const String userKey = 'mr_shop_user';
  static const String deviceIdKey = 'mr_shop_device_id';
}
