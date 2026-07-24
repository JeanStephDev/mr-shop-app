import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'services/admob_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AdMobService.initialize();
  } catch (e) {
    // Ne doit JAMAIS empêcher l'app de démarrer — ex: appareil sans Google
    // Play Services, ou réseau indisponible au tout premier lancement.
    debugPrint('AdMob a échoué à s\'initialiser (non bloquant) : $e');
  }

  // Notifications push désactivées temporairement — voir
  // lib/services/notification_service.dart et README_FLUTTER.md,
  // section "Réactiver les notifications push".

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
      ],
      child: const MrShopApp(),
    ),
  );
}
