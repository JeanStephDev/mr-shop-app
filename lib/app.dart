import 'package:flutter/material.dart';
import 'core/navigation_service.dart';
import 'core/theme.dart';
import 'screens/auth/phone_entry_screen.dart';
import 'screens/orders/order_tracking_screen.dart';
import 'screens/splash/splash_screen.dart';

class MrShopApp extends StatelessWidget {
  const MrShopApp({super.key});

  @override
  Widget build(BuildContext context) {
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
            return MaterialPageRoute(builder: (_) => const PhoneEntryScreen());
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
