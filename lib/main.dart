import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'services/admob_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AdMobService.initialize();

  // Nécessite d'avoir généré firebase_options.dart via `flutterfire configure`
  // (voir README_FLUTTER.md, étape Firebase) avant de décommenter :
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
