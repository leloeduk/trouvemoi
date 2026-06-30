Crée une application Flutter moderne appelée "RetrouvePièce".

Architecture :

- Clean Architecture simple
- Flutter Bloc
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- GoRouter

L'application permet :

1. Publier une pièce retrouvée.
2. Rechercher une pièce perdue.
3. Voir les détails.
4. Appeler ou écrire sur WhatsApp la personne qui a trouvé la pièce.

Pages :

- Splash
- Login
- Home
- AddDocument
- SearchDocument
- DocumentList
- DocumentDetails
- Profile

Le modèle Document contient :
id
nom
prenom
numero
type
ville
lieu
telephone
photo
description
createdAt
status

Créer une interface Material 3 moderne, responsive et propre.

Ajouter les blocs, repositories, services Firebase, modèles, routes et toutes les pages fonctionnelles.

Le code doit être propre, commenté et prêt à être compilé.
Guide complet de déploiement Flutter vers Google Play (2026)
Ce guide couvre les étapes principales de la préparation à la publication.

1. Vérifications
   flutter test, flutter analyze, dart format ., flutter clean, flutter pub get.
2. Signature
   Créer upload-keystore.jks, key.properties, configurer Gradle.
3. Version
   Modifier version dans pubspec.yaml.
4. Build
   flutter build appbundle --release
5. Play Console
   Créer compte, créer application, remplir fiche.
6. Assets
   Icône 512x512, captures, bannière 1024x500.
7. Confidentialité
   Ajouter une politique de confidentialité.
8. Data Safety
   Déclarer les données collectées.
9. Publication
   Créer une version, téléverser app-release.aab.
10. Accès équipe
    Inviter des utilisateurs via Utilisateurs et autorisations, sans partager le mot de passe Google.
11. Mises à jour
    Incrémenter version puis reconstruire l'AAB.
12. Checklist
    Tests réels, Crashlytics, sauvegarde du keystore.
    Commandes utiles
    • flutter test
    • flutter analyze
    • dart format .
    • flutter clean
    • flutter pub get
    • flutter build appbundle –release

& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

Configuration du signing dans Android
Créez ou modifiez android/key.properties :
properties
storePassword=<mot de passe du keystore>
keyPassword=<mot de passe de la clé>
keyAlias=upload
storeFile=<chemin vers upload-keystore.jks>

android/app/build.gradle :
gradle

au debut
....

import java.util.Properties
import java.io.FileInputStream

......
apres plugin
....

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
...

signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
   buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
    }
}
}
