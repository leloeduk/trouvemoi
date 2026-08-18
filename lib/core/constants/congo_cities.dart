class CongoCity {
  final String name;
  final String department;

  const CongoCity({required this.name, required this.department});

  @override
  String toString() => name;
}

class CongoCities {
  static const List<CongoCity> all = [
    CongoCity(name: 'Brazzaville', department: 'Brazzaville'),
    CongoCity(name: 'Pointe-Noire', department: 'Pointe-Noire'),
    CongoCity(name: 'Dolisie', department: 'Niari'),
    CongoCity(name: 'Nkayi', department: 'Bouenza'),
    CongoCity(name: 'Madingou', department: 'Bouenza'),
    CongoCity(name: 'Mouyondzi', department: 'Bouenza'),
    CongoCity(name: 'Sibiti', department: 'Lékoumou'),
    CongoCity(name: 'Mossendjo', department: 'Niari'),
    CongoCity(name: 'Ouesso', department: 'Sangha'),
    CongoCity(name: 'Impfondo', department: 'Likouala'),
    CongoCity(name: 'Gamboma', department: 'Nkéni-Alima'),
    CongoCity(name: 'Djambala', department: 'Plateaux'),
    CongoCity(name: 'Oyo', department: 'Cuvette'),
    CongoCity(name: 'Owando', department: 'Cuvette'),
    CongoCity(name: 'Makoua', department: 'Cuvette'),
    CongoCity(name: 'Ewo', department: 'Cuvette-Ouest'),
    CongoCity(name: 'Kinkala', department: 'Pool'),
    CongoCity(name: 'Mindouli', department: 'Pool'),
    CongoCity(name: 'Kindamba', department: 'Pool'),
    CongoCity(name: 'Boko', department: 'Pool'),
    CongoCity(name: 'Loudima', department: 'Bouenza'),
    CongoCity(name: 'Loutété', department: 'Bouenza'),
    CongoCity(name: 'Kibangou', department: 'Niari'),
    CongoCity(name: 'Madingou-Kayes', department: 'Bouenza'),
    CongoCity(name: 'Mouana-Nto', department: 'Niari'),
    CongoCity(name: 'Tchikabou', department: 'Kouilou'),
    CongoCity(name: 'Loango', department: 'Kouilou'),
    CongoCity(name: 'Hinda', department: 'Kouilou'),
    CongoCity(name: 'Nzambi', department: 'Kouilou'),
    CongoCity(name: 'Tchiamba-Nzassi', department: 'Pointe-Noire'),
    CongoCity(name: 'Kintélé', department: 'Brazzaville'),
    CongoCity(name: 'Ngabé', department: 'Pool'),
    CongoCity(name: 'Lekana', department: 'Plateaux'),
    CongoCity(name: 'Mbon', department: 'Plateaux'),
    CongoCity(name: 'Mpouya', department: 'Plateaux'),
    CongoCity(name: 'Mossaka', department: 'Congo-Oubangui'),
    CongoCity(name: 'Loukoléla', department: 'Congo-Oubangui'),
    CongoCity(name: 'Liranga', department: 'Congo-Oubangui'),
    CongoCity(name: 'Pokola', department: 'Sangha'),
    CongoCity(name: 'Sembé', department: 'Sangha'),
    CongoCity(name: 'Souanké', department: 'Sangha'),
    CongoCity(name: 'Mokéko', department: 'Sangha'),
    CongoCity(name: 'Bétou', department: 'Likouala'),
    CongoCity(name: 'Dongou', department: 'Likouala'),
    CongoCity(name: 'Epena', department: 'Likouala'),
    CongoCity(name: 'Bouansa', department: 'Bouenza'),
    CongoCity(name: 'Kingoué', department: 'Bouenza'),
    CongoCity(name: 'Mfouati', department: 'Bouenza'),
    CongoCity(name: 'Mabombo', department: 'Bouenza'),
    CongoCity(name: 'Autre', department: 'Congo-Brazzaville'),
  ];

  static List<CongoCity> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((city) =>
            city.name.toLowerCase().contains(q) ||
            city.department.toLowerCase().contains(q))
        .toList();
  }
}