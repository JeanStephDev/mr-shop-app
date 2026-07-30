# Build & signature de l'APK via GitHub — sans rien installer sur ton PC

Package cible : **`org.triax.mr.shop.app`**

## 🔍 Diagnostiquer un crash sans PC : la version Web

Un deuxième workflow (`.github/workflows/build-web.yml`) build une version Web
de l'app et la publie automatiquement sur **GitHub Pages** — une vraie URL
HTTPS ouvrable depuis n'importe quel navigateur, y compris directement sur
ton téléphone, sans rien télécharger ni installer.

**Pourquoi c'est utile** : si l'app fonctionne sur cette version Web mais
plante sur l'APK Android, ça prouve que le bug est spécifique à Android natif
(signature, minification R8, plugin natif incompatible) — pas dans notre
code Dart. Si elle plante aussi sur Web, le bug est dans la logique de l'app
elle-même, ce qui oriente la recherche très différemment.

### Activer GitHub Pages (une seule fois)

1. Sur ton dépôt : **Settings** → **Pages** (menu de gauche).
2. Section "Build and deployment" → **Source** → choisis **"GitHub Actions"**.
3. Rien d'autre à configurer, le workflow se charge du reste.

### Utiliser

Le workflow se lance automatiquement à chaque push (ou manuellement depuis
l'onglet **Actions** → "Build & Deploy Web — MR Shop Client" → "Run workflow").
Une fois terminé (✅), va dans **Settings** → **Pages** : l'URL de ton app
est affichée en haut ("Your site is live at..."). Ouvre-la sur ton téléphone.

⚠️ Limites de cette version Web (attendues, pas des bugs) :
- Le paiement GeniusPay (WebView) et les notifications ne fonctionnent pas
  pareil sur Web — ce n'est pas grave, l'objectif est juste de vérifier que
  l'app s'ouvre et navigue normalement (écran de connexion, catalogue...).
- AdMob n'existe pas sur Web (plugin Android/iOS uniquement) — l'app doit
  simplement continuer à fonctionner sans pub grâce aux `try/catch` déjà en place.

Toute la chaîne (génération du projet Android, signature, build) tourne dans
le cloud via **GitHub Actions**. Tu n'as besoin ni de Flutter, ni de VS Code,
ni d'Android Studio installés localement — juste un compte GitHub et un
navigateur. Le dossier `android/` n'est **pas** dans ce zip : il est généré
automatiquement à chaque build par le workflow (`.github/workflows/build-apk.yml`),
ce qui évite tout risque de fichiers Gradle corrompus ou désynchronisés.

## Étape 1 — Créer le dépôt GitHub

1. Va sur [github.com/new](https://github.com/new), crée un dépôt (public ou privé,
   privé recommandé tant que le projet n'est pas public).
2. Upload tout le contenu de ce dossier `mr-shop-client/` dedans — soit en
   glissant les fichiers sur la page web de GitHub ("Add file" → "Upload files"),
   soit via `git push` si tu as `git` installé.

## Étape 2 — Générer la clé de signature, 100% dans le navigateur

Pas besoin d'installer Java : **GitHub Codespaces** te donne un terminal Linux
complet dans le navigateur, avec Java déjà installé.

1. Sur ton dépôt GitHub, clique sur le bouton vert **"Code"** → onglet
   **"Codespaces"** → **"Create codespace on main"**.
2. Une fois le terminal ouvert (en bas de l'écran), tape :
   ```bash
   keytool -genkey -v -keystore mr-shop-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias mr-shop-key
   ```
3. Réponds aux questions (mot de passe du keystore, mot de passe de la clé,
   nom, organisation "Triax, Inc.", ville "Abidjan", pays "CI").
   **Note ces deux mots de passe précieusement** — tu en as besoin à l'étape 3.
4. Convertis le fichier en base64 (nécessaire pour le stocker comme secret GitHub) :
   ```bash
   base64 -w 0 mr-shop-release.jks > keystore_base64.txt
   cat keystore_base64.txt
   ```
5. Copie tout le texte affiché (une seule longue ligne) — tu vas le coller
   dans un secret GitHub à l'étape suivante.

⚠️ **Sauvegarde aussi `mr-shop-release.jks` en dehors de GitHub** (télécharge-le
depuis Codespaces, garde-le dans un gestionnaire de mots de passe ou un
stockage cloud privé). Si tu perds cette clé, impossible de mettre à jour
l'app publiée — il faudrait republier sous un nouveau package.

## Étape 3 — Ajouter les secrets GitHub

Sur ton dépôt : **Settings** → **Secrets and variables** → **Actions** →
**New repository secret**. Ajoute chacun de ces secrets un par un :

| Nom du secret | Valeur |
|---|---|
| `KEYSTORE_BASE64` | Le contenu de `keystore_base64.txt` (étape 2.4) |
| `KEYSTORE_PASSWORD` | Le mot de passe du keystore (étape 2.3) |
| `KEY_PASSWORD` | Le mot de passe de la clé (étape 2.3) |
| `KEY_ALIAS` | `mr-shop-key` |

Optionnels (le build fonctionne sans, avec des valeurs de test par défaut) :

| Nom du secret | Valeur |
|---|---|
| `MAPS_API_KEY` | Ta clé Google Maps (voir README_FLUTTER.md, étape 5) |
| `ADMOB_APP_ID` | Ton App ID AdMob Android (voir README_FLUTTER.md, étape 4bis) |
| `ADMOB_BANNER_ID` | Ton ID de bloc bannière AdMob |
| `ADMOB_INTERSTITIAL_ID` | Ton ID de bloc interstitiel AdMob |

## Étape 4 — Lancer le build

Le workflow se déclenche automatiquement à chaque `push` sur la branche
`main`. Pour le lancer manuellement (par exemple juste après avoir ajouté les
secrets, sans changer de code) :

1. Onglet **"Actions"** de ton dépôt GitHub.
2. Clique sur **"Build & Sign APK — MR Shop Client"** dans la liste à gauche.
3. Bouton **"Run workflow"** → **"Run workflow"** (confirmer).
4. Attends (3-6 minutes en général) que le workflow passe au vert ✅.

## Étape 5 — Télécharger l'APK

1. Clique sur le run terminé (celui avec le ✅).
2. Tout en bas de la page, section **"Artifacts"** → clique sur
   **"mr-shop-client-apk"** pour le télécharger (fichier `.zip` contenant l'APK).
3. Décompresse, tu obtiens `app-release.apk` — signé, prêt à installer ou à
   déposer dans `public/downloads/mr-shop.apk` du site vitrine.

## Étape 6 — Pour le Play Store (.aab au lieu de .apk)

Le workflow actuel produit un `.apk` (pratique pour tester/distribuer
directement). Pour le Play Store, il faut un `.aab` : dans
`.github/workflows/build-apk.yml`, remplace la ligne de build par :
```yaml
- name: Build de l'App Bundle signé
  run: flutter build appbundle --release
```
et le chemin d'artefact par `build/app/outputs/bundle/release/app-release.aab`.
Tu peux aussi dupliquer le job pour produire les deux (`.apk` ET `.aab`) à
chaque run si tu préfères garder les deux options.

## App Links Android — ouvrir l'app depuis store.hexa-node.site

Une fois configuré, un lien `https://store.hexa-node.site/produit/xxx` ouvre
directement l'app (si installée) au lieu du navigateur. Sans ce fichier, le
lien ouvre toujours le navigateur — ce n'est pas bloquant, juste moins fluide.

1. Récupère l'empreinte SHA-256 de ta clé de signature (celle générée à
   l'étape 2) :
   ```bash
   keytool -list -v -keystore mr-shop-release.jks -alias mr-shop-key
   ```
   Copie la ligne `SHA256:` (format `AA:BB:CC:...`).

2. Crée le fichier `assetlinks.json` :
   ```json
   [{
     "relation": ["delegate_permission/common.handle_all_urls"],
     "target": {
       "namespace": "android_app",
       "package_name": "org.triax.mr.shop.app",
       "sha256_cert_fingerprints": ["TON_EMPREINTE_SHA256_ICI"]
     }
   }]
   ```

3. Sur ton VPS, dépose ce fichier à l'emplacement exact :
   ```bash
   mkdir -p /var/www/mr-shop-client-web/.well-known
   nano /var/www/mr-shop-client-web/.well-known/assetlinks.json
   # colle le JSON ci-dessus
   ```
   (`/var/www/mr-shop-client-web` est le dossier qui sert `store.hexa-node.site`,
   voir DEPLOIEMENT.md du backend).

4. Vérifie que ça répond bien en JSON sur
   `https://store.hexa-node.site/.well-known/assetlinks.json`.

⚠️ Ceci ne fonctionne que sur **Android**. Sans app iOS native (seulement la
PWA), il n'y a pas d'équivalent "Universal Links" possible côté iPhone — un
lien store.hexa-node.site ouvre toujours Safari sur iOS, ce qui est normal
et attendu.

## Si le build échoue

Clique sur le run rouge ❌ dans l'onglet Actions, puis sur l'étape qui a
échoué — le log complet s'affiche et indique la ligne exacte du problème.
Cas fréquents :
- **Secret manquant/mal nommé** : vérifie l'orthographe exacte des 4 secrets
  obligatoires (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`).
- **`keytool` bloque sur une question** en Codespaces : réponds `oui`/`o` à la
  confirmation finale ("Générer une clé... [non]:" → tape `o`).
- **Erreur de dépendance Flutter/pub** : vérifie que `pubspec.yaml` n'a pas
  été modifié accidentellement lors de l'upload sur GitHub.
