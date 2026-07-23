/// Notifications push — DÉSACTIVÉ TEMPORAIREMENT.
///
/// firebase_core/firebase_messaging ont été retirés de pubspec.yaml : sans
/// google-services.json (généré par `flutterfire configure`), leur composant
/// natif Android plante l'app AU DÉMARRAGE, avant même le premier écran.
///
/// Cette classe reste en place comme point d'entrée unique (appelée depuis
/// AuthProvider) pour que la réactivation soit un simple copier-coller une
/// fois Firebase configuré — voir README_FLUTTER.md, section "Réactiver les
/// notifications push", qui donne le contenu exact à remettre ici.
class NotificationService {
  static Future<void> initialize() async {
    // no-op tant que Firebase n'est pas configuré.
  }
}
