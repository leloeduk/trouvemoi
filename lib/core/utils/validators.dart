class Validators {
  static String? required(String? value, [String field = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) return '$field est requis';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le téléphone est requis';
    final cleaned = value.trim().replaceAll(RegExp(r'[\s.-]'), '');
    final local = RegExp(r'^0[4-6]\d{7}$');
    if (!local.hasMatch(cleaned)) {
      return 'Numéro invalide (ex: 06 635 24 55)';
    }
    return null;
  }
}
