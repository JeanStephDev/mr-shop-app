import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'services/admob_service.dart';

void main() {
  // Capture TOUTE erreur non interceptée, y compris celles qui surviennent
  // avant même l'affichage du premier écran — sans ça, un crash à ce stade
  // ferme l'app instantanément sans rien afficher, impossible à diagnostiquer
  // sans PC/logcat. Ici, on affiche le message d'erreur directement à
  // l'écran à la place.
  runZonedGuarded(() async {
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
  }, (error, stack) {
    // Si quoi que ce soit plante avant l'affichage normal de l'app, on
    // affiche quand même quelque chose de lisible à l'écran plutôt que de
    // fermer silencieusement.
    runApp(_CrashScreen(error: error));
  });
}

class _CrashScreen extends StatelessWidget {
  final Object error;
  const _CrashScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Text(
                'MR Shop n\'a pas pu démarrer :\n\n$error',
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
