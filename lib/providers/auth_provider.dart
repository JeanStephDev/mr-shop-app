import 'package:flutter/foundation.dart';
import '../core/storage_service.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  AppUser? user;
  bool isLoading = false;
  String? error;
  bool isDemoMode = false;

  bool get isAuthenticated => user != null;

  /// Connexion de démonstration — SANS appel réseau, pour naviguer dans
  /// l'app et montrer les écrans même si l'API/le serveur est indisponible.
  /// Bouton "Continuer en mode démo" sur WelcomeAuthScreen. À ne jamais
  /// utiliser en production réelle (isDemoMode désactive certains appels
  /// réseau ailleurs, voir CatalogProvider/OrderService).
  void loginAsDemo() {
    user = AppUser(id: 0, name: 'Client Démo', phone: '0700000000', role: 'client');
    isDemoMode = true;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final token = await StorageService.getToken();
    if (token == null) return;

    isLoading = true;
    notifyListeners();
    try {
      user = await _authService.me();
      await NotificationService.initialize();
    } catch (_) {
      await StorageService.clearToken();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendOtp(String phone) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _authService.sendOtp(phone);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String otpCode,
    required String password,
    required bool termsAccepted,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _authService.register(
        name: name,
        phone: phone,
        otpCode: otpCode,
        password: password,
        termsAccepted: termsAccepted,
      );
      await NotificationService.initialize();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String phone, required String password}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _authService.login(phone: phone, password: password);
      await NotificationService.initialize();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetOtp(String phone) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _authService.sendPasswordResetOtp(phone);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({required String phone, required String otpCode, required String password}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _authService.resetPassword(phone: phone, otpCode: otpCode, password: password);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (!isDemoMode) {
      await _authService.logout();
    }
    user = null;
    isDemoMode = false;
    notifyListeners();
  }
}
