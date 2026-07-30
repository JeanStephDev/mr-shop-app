import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/ad.dart';
import '../../providers/auth_provider.dart';
import '../../services/ad_service.dart';
import '../../widgets/logo_reveal_animation.dart';
import '../home/main_navigation.dart';

/// Écran de démarrage : joue l'animation du logo pendant que la session est
/// vérifiée en arrière-plan, PUIS affiche la pub d'ouverture SEULEMENT si
/// l'API en renvoie une (règles non-intrusives déjà appliquées côté API :
/// 1x/jour max, jamais 2x en moins de 20h — voir AdController Laravel).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animationDone = false;
  bool _bootstrapDone = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.tryAutoLogin();

    if (!mounted) return;
    setState(() => _bootstrapDone = true);
    _maybeProceed();
  }

  void _onAnimationFinished() {
    setState(() => _animationDone = true);
    _maybeProceed();
  }

  // N'avance qu'une fois l'animation ET la vérification de session terminées
  // toutes les deux — l'animation ne se coupe jamais en plein milieu, mais
  // n'attend pas non plus inutilement si le réseau est lent.
  void _maybeProceed() async {
    if (!_animationDone || !_bootstrapDone) return;

    final ad = await AdService().getSplashAd();
    if (!mounted) return;

    if (ad != null) {
      await _showSplashAd(ad);
    }

    if (!mounted) return;
    _goNext();
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

  void _goNext() {
    // Navigation invité : la boutique reste consultable sans compte — la
    // connexion n'est demandée qu'au moment d'agir (commander, voir ses
    // commandes, son profil). Voir WelcomeAuthScreen et les gardes dans
    // CartScreen/MainNavigation.
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigation()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.logoBg,
      body: Center(
        child: LogoRevealAnimation(onFinished: _onAnimationFinished),
      ),
    );
  }
}
