class AppConstants {
  static const String appName = 'RetrouvePièce';
  static const String collectionDocuments = 'documents';

  static const String phoneExample = '06 635 24 55';
  static const String phoneExampleRaw = '066352455';

  /// UID Firestore des comptes administrateurs (attribués manuellement).
  /// Ajouter ici les UID des administrateurs (ex: 'ABCDE12345').
  static final List<String> adminUids = <String>[
    // 'UID_ADMIN_1',
    // 'UID_ADMIN_2',
  ];

  static bool isAdmin(String? uid) {
    if (uid == null || uid.isEmpty) return false;
    return adminUids.contains(uid);
  }

  static const List<String> documentTypes = [
    'Carte Nationale d\'Identité',
    'Passeport',
    'Permis de Conduire',
    'Carte d\'Étudiant',
    'Carte Professionnelle',
    'Titre de Séjour',
    'Carte Bancaire',
    'Enfant perdu',
    'Autre objet',
  ];
}
