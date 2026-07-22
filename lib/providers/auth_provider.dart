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

  bool get isAuthenticated => user != null;

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

  Future<bool> verifyOtp({required String phone, required String code, String? name}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _authService.verifyOtp(phone: phone, code: code, name: name);
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

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    notifyListeners();
  }
}
