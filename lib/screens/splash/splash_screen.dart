import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/ad.dart';
import '../../providers/auth_provider.dart';
import '../../services/ad_service.dart';
import '../auth/phone_entry_screen.dart';
import '../home/main_navigation.dart';

/// Écran de démarrage : vérifie la session, PUIS affiche la pub d'ouverture
/// SEULEMENT si l'API en renvoie une (elle applique déjà les règles non-intrusives
/// : 1x/jour max, jamais 2x en moins de 20h — voir AdController côté Laravel).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.tryAutoLogin();

    final ad = await AdService().getSplashAd();
    if (!mounted) return;

    if (ad != null) {
      await _showSplashAd(ad);
    }

    if (!mounted) return;
    _goNext(authProvider.isAuthenticated);
  }

  Future<void> _showSplashAd(Ad ad) async {
    AdService().trackImpression(ad.id);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(ad.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goNext(bool isAuthenticated) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => isAuthenticated ? const MainNavigation() : const PhoneEntryScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('MR Shop', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Fresh Scent by Elo', style: TextStyle(color: AppColors.peach)),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: AppColors.orange),
          ],
        ),
      ),
    );
  }
}
