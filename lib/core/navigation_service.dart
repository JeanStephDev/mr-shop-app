import 'package:flutter/material.dart';

/// Permet de naviguer depuis n'importe où (services, intercepteurs Dio) sans
/// avoir de BuildContext sous la main — utilisé pour la déconnexion automatique
/// sur 401 et pour ouvrir une commande depuis une notification push.
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void goToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  static void goToOrderTracking(int orderId) {
    navigatorKey.currentState?.pushNamed('/order-tracking', arguments: orderId);
  }
}
