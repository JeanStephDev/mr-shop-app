import 'package:flutter/material.dart';
import 'core/navigation_service.dart';
import 'core/theme.dart';
import 'screens/auth/welcome_auth_screen.dart';
import 'screens/orders/order_tracking_screen.dart';
import 'screens/splash/splash_screen.dart';

class MrShopApp extends StatelessWidget {
  const MrShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Affiche le message d'erreur complet directement à l'écran en cas de
    // problème (au lieu de l'écran gris générique de Flutter en release,
    // qui ne montre rien d'exploitable) — permet de diagnostiquer sans PC
    // ni câble, juste en lisant le texte affiché sur le téléphone.
    ErrorWidget.builder = (FlutterErrorDetails details) => Material(
          color: Colors.red.shade50,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Text(
                  'Erreur MR Shop :\n\n${details.exceptionAsString()}',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ),
          ),
        );

    return MaterialApp(
      title: 'MR Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: NavigationService.navigatorKey,
      home: const SplashScreen(),
      // Routes nommées : utilisées pour naviguer depuis du code sans BuildContext
      // (redirection auto sur 401, ouverture d'une commande depuis une notif push).
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const WelcomeAuthScreen());
          case '/order-tracking':
            final orderId = settings.arguments as int;
            return MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: orderId));
          default:
            return null;
        }
      },
    );
  }
}
