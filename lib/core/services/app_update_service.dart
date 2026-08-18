import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Informations de mise à jour renvoyées par Firebase.
class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String message;
  final String url;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.message,
    required this.url,
  });
}

/// Vérifie si une mise à jour est disponible via un document Firestore.
///
/// Le document attendu est `app_config/update` :
/// - `latest_version` (String) : version disponible, ex: "1.1.0"
/// - `update_message` (String) : message affiché à l'utilisateur
/// - `update_url` (String) : lien vers la boutique
/// - `enabled` (bool) : active ou désactive la notification
class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  static const String collection = 'app_config';
  static const String document = 'update';
  static const String defaultStoreUrl =
      'https://play.google.com/store/apps/details?id=com.leloeduk.trouvemoi';

  /// Compare deux versions sémantiques "x.y.z".
  ///
  /// Retourne `true` si [latestVersion] est strictement supérieure à
  /// [currentVersion].
  static bool isUpdateAvailable(String currentVersion, String latestVersion) {
    final current = _parseVersion(currentVersion);
    final latest = _parseVersion(latestVersion);
    if (current == null || latest == null) return false;

    for (var i = 0; i < 3; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    return false;
  }

  static List<int>? _parseVersion(String version) {
    final parts = version.trim().split('.').map(int.tryParse).toList();
    if (parts.any((part) => part == null)) return null;
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts.cast<int>();
  }

  /// Interroge Firestore et retourne une mise à jour si disponible,
  /// sinon `null` (y compris en cas d'erreur réseau ou de test).
  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final currentVersion = await _currentVersion();

      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(document)
          .get();

      final data = snapshot.data();
      if (data == null) return null;

      final enabled = data['enabled'] as bool? ?? true;
      final latestVersion = data['latest_version'] as String?;
      if (!enabled || latestVersion == null) return null;

      if (!isUpdateAvailable(currentVersion, latestVersion)) return null;

      return AppUpdateInfo(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        message: data['update_message'] as String? ??
            'Une nouvelle version est disponible avec des améliorations.',
        url: data['update_url'] as String? ?? defaultStoreUrl,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> _currentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '1.0.0';
    }
  }
}