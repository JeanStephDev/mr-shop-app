import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

/// Petit wrapper autour de flutter_secure_storage pour le token d'auth
/// et l'identifiant d'appareil (utilisé par le système de pubs quand
/// l'utilisateur n'est pas encore connecté).
class StorageService {
  static final _storage = const FlutterSecureStorage();

  static Future<void> saveToken(String token) => _storage.write(key: AppConstants.authTokenKey, value: token);
  static Future<String?> getToken() => _storage.read(key: AppConstants.authTokenKey);
  static Future<void> clearToken() => _storage.delete(key: AppConstants.authTokenKey);

  static Future<String> getOrCreateDeviceId() async {
    var id = await _storage.read(key: AppConstants.deviceIdKey);
    if (id == null) {
      id = DateTime.now().microsecondsSinceEpoch.toString();
      await _storage.write(key: AppConstants.deviceIdKey, value: id);
    }
    return id;
  }
}
