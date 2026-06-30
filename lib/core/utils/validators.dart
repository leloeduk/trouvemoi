class Validators {
  static String? required(String? value, [String field = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) return '$field est requis';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le téléphone est requis';
    final regex = RegExp(r'^0[5-6]\d{7}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Numéro invalide (ex: 06 123 45 67)';
    }
    return null;
  }
}
