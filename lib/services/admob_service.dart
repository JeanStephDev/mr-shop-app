import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralise AdMob : bannières (affichées dans l'accueil/catalogue) et
/// interstitiels (affichés à des moments peu intrusifs, ex: après avoir
/// consulté quelques fiches produits — jamais pendant un paiement ou un
/// suivi de commande).
///
/// ⚠️ Les IDs ci-dessous sont les IDs de TEST officiels Google — ils
/// affichent des pubs factices sans risque de bannissement pendant le dev.
/// Remplace-les par tes vrais IDs AdMob avant publication (voir README_FLUTTER.md).
class AdMobService {
  static const String bannerAdUnitId = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111', // ID de test Google
  );

  static const String interstitialAdUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712', // ID de test Google
  );

  static InterstitialAd? _interstitialAd;
  static int _productViewCount = 0;

  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _loadInterstitial();
    } catch (e) {
      // Sur un appareil sans Google Play Services (ou hors ligne au premier
      // lancement), l'initialisation peut échouer — l'app doit continuer
      // à fonctionner normalement, juste sans publicités.
      // ignore: avoid_print
      print('AdMob indisponible (non bloquant) : $e');
    }
  }

  static void _loadInterstitial() {
    try {
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (_) => _interstitialAd = null,
        ),
      );
    } catch (_) {
      // Idem : un échec de chargement d'interstitiel ne doit jamais planter l'app.
    }
  }

  /// À appeler à chaque consultation de fiche produit. Affiche un
  /// interstitiel toutes les 5 consultations (évite de matraquer l'utilisateur),
  /// puis recharge le suivant en arrière-plan.
  static void notifyProductViewed() {
    _productViewCount++;
    if (_productViewCount % 5 == 0 && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitial();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  static BannerAd createBannerAd({required void Function() onLoaded, required void Function() onFailed}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed();
        },
      ),
    )..load();
  }
}
