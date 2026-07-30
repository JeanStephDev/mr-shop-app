import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../home/main_navigation.dart';
import 'login_screen.dart';
import 'register_phone_screen.dart';

/// Écran affiché quand un visiteur (non connecté) essaie de faire une action
/// qui nécessite un compte — commander, voir ses commandes, son profil.
/// La navigation/le catalogue restent visibles sans compte (voir MainNavigation).
class WelcomeAuthScreen extends StatelessWidget {
  const WelcomeAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/logo.png', width: 120, height: 120),
              const SizedBox(height: 24),
              Text(
                'Bienvenue chez MR Shop',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Connectez-vous ou créez un compte pour commander',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.navySoft),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Se connecter'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterPhoneScreen())),
                child: const Text('Créer un compte'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuer sans compte', style: TextStyle(color: AppColors.navySoft)),
              ),

              // Mode démo : uniquement en build debug (jamais en release/production)
              // — permet de naviguer et montrer toutes les pages sans backend
              // fonctionnel. Voir AuthProvider.loginAsDemo().
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.bug_report_outlined, size: 18, color: AppColors.orange),
                  label: const Text('Continuer en mode démo (test)', style: TextStyle(color: AppColors.orange)),
                  onPressed: () {
                    context.read<AuthProvider>().loginAsDemo();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                      (r) => false,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
