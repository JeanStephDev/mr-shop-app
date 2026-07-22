# MR Shop — App Client (Flutter)

Toutes les fonctionnalités sont implémentées : auth OTP, catalogue, panier,
adresse avec sélection sur carte, paiement GeniusPay, suivi de commande en
temps réel, avis/notation, annulation, notifications push (premier plan +
tap pour ouvrir la commande), icônes d'app, publicités AdMob. Il ne reste
que des **comptes externes à créer** (Firebase, Google Maps, AdMob, Play
Store) — pas de code manquant.

## 🚀 Pas d'installation locale ? Utilise GitHub Actions

Si tu n'as pas Flutter/Android Studio installés (ou que ça ne fonctionne pas
sur ta machine), **ignore les étapes 1-2 ci-dessous** et va directement à
**`BUILD_AND_SIGN_APK.md`** — il explique comment builder et signer l'APK
entièrement dans le cloud (GitHub Actions + Codespaces), sans rien installer,
juste avec un navigateur.

Les étapes ci-dessous supposent que tu as Flutter installé en local (pour du
développement actif avec hot reload, voir étape 7). Pour juste obtenir un
APK final, le chemin GitHub est plus simple.

## Étape 1 — Créer le vrai projet Flutter (en local uniquement)

```bash
flutter create --org org.triax.mr.shop --project-name mr_shop_client mr_shop_client
cd mr_shop_client
```

⚠️ Le package Android généré par défaut ne sera pas exactement `org.triax.mr.shop.app`
— voir **`BUILD_AND_SIGN_APK.md`** pour le fixer précisément et signer l'APK.

## Étape 2 — Copier notre code

```
lib/            → lib/
pubspec.yaml    → pubspec.yaml
assets/         → assets/
```

```bash
flutter pub get
```

## Étape 3 — Adresse de l'API (domaine de test : hexa-node.site)

Dans `lib/core/constants.dart` :
- Test local (émulateur Android) : `http://10.0.2.2:8000/api/v1`
- Test local (appareil physique, même Wi-Fi) : `http://IP_DE_TON_PC:8000/api/v1`
- Une fois le VPS déployé sur le domaine de test : `https://www.hexa-node.site/api/v1`

## Étape 4 — Firebase (notifications push)

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Génère `lib/firebase_options.dart`. Décommente ensuite les 2 lignes Firebase
dans `lib/main.dart` :
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

## Étape 4bis — AdMob (publicités)

1. Crée un compte sur [admob.google.com](https://admob.google.com), ajoute l'app
   (Android + iOS séparément) → tu obtiens un **App ID** par plateforme
   (`ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`) et des **ID de blocs d'annonces**
   (bannière, interstitiel).
2. Tant que tu n'as pas ces IDs, l'app utilise automatiquement les **IDs de
   test officiels de Google** (déjà configurés dans `lib/services/admob_service.dart`)
   — pubs factices affichées, zéro risque de bannissement pendant le dev.
3. **Android** — dans `android/app/src/main/AndroidManifest.xml`, à l'intérieur
   de `<application>` :
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="TON_APP_ID_ANDROID"/>
   ```
4. **iOS** — dans `ios/Runner/Info.plist` :
   ```xml
   <key>GADApplicationIdentifier</key>
   <string>TON_APP_ID_IOS</string>
   ```
5. Une fois tes vrais ID de blocs d'annonces obtenus, build en les passant en variable :
   ```bash
   flutter build apk --release \
     --dart-define=ADMOB_BANNER_ID=ca-app-pub-xxx/xxx \
     --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-xxx/xxx
   ```

## Étape 5 — Google Maps (sélection d'adresse)

1. Crée une clé API sur [console.cloud.google.com](https://console.cloud.google.com)
   → active "Maps SDK for Android" et "Maps SDK for iOS".
2. **Android** : dans `android/app/src/main/AndroidManifest.xml`, à l'intérieur de `<application>` :
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY" android:value="TA_CLE_ICI"/>
   ```
3. **iOS** : dans `ios/Runner/AppDelegate.swift`, ajoute avant `return super.application(...)` :
   ```swift
   GMSServices.provideAPIKey("TA_CLE_ICI")
   ```
   (nécessite `import GoogleMaps` en haut du fichier)
4. **Permissions de localisation** (utilisées par `geolocator` pour centrer la carte) :
   - Android, dans `AndroidManifest.xml` (avant `<application>`) :
     ```xml
     <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
     ```
   - iOS, dans `ios/Runner/Info.plist` :
     ```xml
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>MR Shop utilise votre position pour localiser votre adresse de livraison</string>
     ```

## Étape 6 — Icônes de l'app

Un logo généré (couleurs MR Shop) est déjà dans `assets/images/logo.png` — à
remplacer par le vrai logo si tu en as une version haute résolution. Puis :
```bash
dart run flutter_launcher_icons
```
Ça génère automatiquement toutes les tailles d'icônes Android/iOS/Web.

## Étape 7 — Tester en local

```bash
flutter run                  # émulateur/appareil
flutter run -d chrome        # version Web (UI uniquement — webview/FCM limités sur web)
```
Hot reload : sauvegarde un fichier `.dart`, tape `r` dans le terminal (ou `Ctrl+S`
dans VS Code avec l'extension Flutter) → mise à jour instantanée sans perdre l'état.

## Étape 8 — Builds de production

⚠️ Pour un APK **signé** (obligatoire pour le Play Store, recommandé même pour
une distribution directe), suis d'abord **`BUILD_AND_SIGN_APK.md`** — package
`org.triax.mr.shop.app`, génération de la clé, configuration Gradle. Sans ça,
`flutter build apk` produit un APK signé avec une clé de debug (installable
pour tester, mais à ne jamais distribuer publiquement).

```bash
flutter build apk --release        # → build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release  # → pour le Play Store (.aab)
flutter build web --release        # → build/web/, à déposer sur app.hexa-node.site
```

### iOS
Nécessite un Mac + Xcode + compte développeur Apple (99$/an) pour l'App Store.
Sans ça, seule la version Web (PWA, étape ci-dessus) est utilisable par les
utilisateurs iPhone.
