# Trouve Moi 🇨🇬

Application Flutter pour **retrouver les documents perdus au Congo-Brazzaville** (carte d'identité, passeport, permis, carte bancaire…) et **rendre ceux qui ont été trouvés** à leurs propriétaires.

## Fonctionnalités

- 🔐 **Connexion Google** (Firebase Authentication) avec acceptation des conditions d'utilisation
- 📢 **Publier un document** trouvé ou perdu (photo, type, ville du Congo, téléphone, description)
- 🔎 **Rechercher et filtrer** par type, ville et statut (Trouvé / Perdu)
- 🗂️ **Parcourir** tous les documents
- 👤 **Profil** avec statistiques, « Mes publications » (CRUD complet : modifier / supprimer)
- 📱 **Contact** par appel ou WhatsApp (récompensé par une publicité, payant à venir)
- 🧭 **Drawer** de navigation complet (Accueil, Rechercher, Parcourir, Publier, Mes publications, Profil, Aide & Support, À propos)
- 🆘 **Aide & Support** et **À propos** (groupe WhatsApp, email de contact)
- 📡 **Mode hors ligne** : persistance Firestore + bandeau d'avertissement
- 🔄 **Notification de mise à jour** pilotée depuis Firestore
- 💰 **Monétisation AdMob** (bannière, interstitielle, app open, récompensée)

## Stack technique

| Technologie | Rôle |
|---|---|
| Flutter / Dart | Framework mobile |
| Flutter Bloc | Gestion d'état (Clean Architecture) |
| Firebase Authentication | Connexion Google |
| Cloud Firestore | Base de données temps réel |
| Firebase Storage | Hébergement des photos |
| GoRouter | Navigation (routes) |
| Google Mobile Ads | Publicités AdMob |
| connectivity_plus | Détection de la connexion |
| package_info_plus | Version de l'application |

## Architecture

Clean Architecture simple, séparée en **domain / data / presentation** :

```
lib/
├── core/
│   ├── constants/        # Villes du Congo, types de documents, constantes
│   ├── routes/           # GoRouter (app_router.dart)
│   ├── services/         # ad_service.dart, app_update_service.dart
│   ├── theme/            # Thème Material 3 (bleu)
│   ├── utils/            # Validateurs (téléphone 04/05/06, requis)
│   └── widgets/          # AppBackButton, AppDrawer, AdBanner, ConnectivityStatus, AppUpdateNotifier
├── features/
│   ├── auth/             # Bloc, domain, data, login_page
│   ├── documents/        # Bloc, domain, data, pages (Add/Edit/Browse/Search/Details/MyPublications)
│   ├── home/             # HomePage
│   ├── profile/          # Bloc profil + ProfilePage
│   ├── splash/           # SplashPage
│   └── support/          # SupportPage, AboutPage
├── firebase_options.dart
└── main.dart
```

Le bloc `DocumentBloc` gère : chargement, recherche, filtres, ajout, mise à jour, suppression et chargement par ID. Chaque document possède : `id`, `type`, `title`, `description`, `imageUrl`, `finderId`, `finderName`, `finderPhone`, `location`, `date`, `status`.

## Démarrage

Prérequis : Flutter SDK, un projet Firebase.

```bash
flutter pub get
flutter run
```

### Configuration Firebase

1. Créez un projet Firebase (ici : `trouvemoi-ad8fd`).
2. Activez **Firebase Authentication** (Google) et **Cloud Firestore** + **Storage**.
3. Ajoutez `google-services.json` dans `android/app/` (et `GoogleService-Info.plist` pour iOS).
4. Régénérez `lib/firebase_options.dart` :
   ```bash
   flutterfire configure
   ```
5. Déployez les règles et les index :
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage --project <PROJECT_ID>
   ```

## Publicités AdMob

Les identifiants sont gérés par `lib/core/services/ad_service.dart` :

| Format | Test (développement) | Production (release) |
|---|---|---|
| Bannière | `ca-app-pub-3940256099942544/6300978111` | `ca-app-pub-3010995346645294/4769033911` |
| Interstitielle | `ca-app-pub-3940256099942544/1033173712` | `ca-app-pub-3010995346645294/9115473033` |
| App Open | `ca-app-pub-3940256099942544/9257395921` | `ca-app-pub-3010995346645294/5125820232` |
| Récompensée | `ca-app-pub-3940256099942544/5224354917` | `ca-app-pub-3010995346645294/4762858156` |

- **`flutter run` / debug** → publicités **de test**.
- **`flutter build appbundle --release`** → vos **vraies publicités** monétisées.

Le choix est automatique via `kReleaseMode`. L'App ID AdMob est déclaré dans `AndroidManifest.xml` et `Info.plist`.

### Emplacements

- **Bannières** : Accueil (au-dessus de la navigation), Parcourir, Rechercher, Détails d'un document
- **Interstitielle** : après une publication réussie
- **App Open** : au lancement
- **Récompensée** : débloque le contact WhatsApp d'un document

> ⚠️ **Important** : déclarez l'app dans le **Play Console** avant publication, sinon les revenus AdMob sont plafonnés à 50 $.

## Notification de mise à jour (Firebase)

`AppUpdateService` compare la version installée (`package_info_plus`) avec `latest_version` stocké dans Firestore. Si la version distante est supérieure, `AppUpdateNotifier` affiche une alerte « Nouvelle version disponible » au démarrage.

Créez dans Firestore Console → collection `app_config` → document `update` :

```json
{
  "latest_version": "1.1.0",
  "update_message": "Nouvelle interface améliorée",
  "update_url": "https://play.google.com/store/apps/details?id=com.leloeduk.trouvemoi",
  "enabled": true
}
```

## Mode hors ligne

- Persistance Firestore activée dans `main.dart` (`persistenceEnabled: true`).
- `connectivity_plus` détecte la perte de réseau et affiche un bandeau **« Hors ligne »** lisible (fond clair, texte sombre).

## Téléphone congolais

Format accepté : **9 chiffres commençant par 04, 05 ou 06**, sans préfixe `+242`.
Le lien WhatsApp ajoute automatiquement l'indicatif `242` au numéro.

## Tests

```bash
flutter test
flutter analyze
```

Couverture : blocs (auth, document, profil), modèles, repositories, validateurs, `AppUpdateService.isUpdateAvailable`, `AdService` (IDs de test en dev) et tests de widgets (login, home, browse, search, détails, profil, publication).

## Déploiement Google Play

1. **Vérifications**
   ```bash
   flutter test
   flutter analyze
   flutter clean
   flutter pub get
   ```
2. **Signature** — `android/key.properties` (ignoré par git) :
   ```properties
   storePassword=<mot de passe du keystore>
   keyPassword=<mot de passe de la clé>
   keyAlias=upload
   storeFile=<chemin vers upload-keystore.jks>
   ```
   Générer le keystore :
   ```
   keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
3. **Version** — incrémenter `version:` dans `pubspec.yaml` (ex : `1.0.0+1`).
4. **Build**
   ```bash
   flutter build appbundle --release
   ```
   → `build/app/outputs/bundle/release/app-release.aab`
5. **Play Console** — créer l'app `com.leloeduk.trouvemoi`, téléverser le `.aab`, remplir la fiche (icônes, captures, description), déclarer la **politique de confidentialité** et le **Data Safety**.
6. **AdMob** — déclarer l'application dans AdMob, vérifier que les vrais IDs de production sont utilisés (release).
7. **Publier** en production, puis inviter l'équipe via *Utilisateurs et autorisations*.

## Commandes utiles

```bash
flutter run                        # exécuter en debug (ads de test)
flutter test                       # lancer les tests
flutter analyze                    # analyse statique
flutter build appbundle --release  # bundle de production (vraies ads)
firebase deploy --only firestore:rules,firestore:indexes --project trouvemoi-ad8fd
```

## Contact

- Groupe WhatsApp : https://chat.whatsapp.com/J5z73UFA8s18j8b7xotLYY
- Email : trouvemoisolution@gmail.com