# Build & signature de l'APK via GitHub — sans rien installer sur ton PC

Package cible : **`org.triax.mr.shop.app`**

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
