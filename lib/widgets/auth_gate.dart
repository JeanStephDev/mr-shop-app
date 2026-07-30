import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/welcome_auth_screen.dart';

/// Affiche [child] si l'utilisateur est connecté, sinon une invite à se
/// connecter/créer un compte — utilisé pour les onglets Commandes/Profil,
/// qui n'ont pas de sens pour un visiteur non connecté (contrairement à
/// l'accueil/catalogue/panier, consultables sans compte).
class AuthGate extends StatelessWidget {
  final Widget child;
  final String message;
  const AuthGate({super.key, required this.child, this.message = 'Connectez-vous pour accéder à cette page'});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;

    if (isAuthenticated) return child;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: AppColors.navySoft),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.navySoft)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WelcomeAuthScreen())),
              child: const Text('Se connecter / Créer un compte'),
            ),
          ],
        ),
      ),
    );
  }
}
