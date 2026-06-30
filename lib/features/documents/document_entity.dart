import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentEntity {
  final String id;
  final String nom;
  final String prenom;
  final String numero;
  final String type;
  final String ville;
  final String lieu;
  final String telephone;
  final String? photo;
  final String description;
  final DateTime createdAt;
  final String status;
  final String? userId;

  const DocumentEntity({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.numero,
    required this.type,
    required this.ville,
    required this.lieu,
    required this.telephone,
    this.photo,
    required this.description,
    required this.createdAt,
    required this.status,
    this.userId,
  });

  factory DocumentEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentEntity(
      id: doc.id,
      nom: data['nom'] as String? ?? '',
      prenom: data['prenom'] as String? ?? '',
      numero: data['numero'] as String? ?? '',
      type: data['type'] as String? ?? '',
      ville: data['ville'] as String? ?? '',
      lieu: data['lieu'] as String? ?? '',
      telephone: data['telephone'] as String? ?? '',
      photo: data['photo'] as String?,
      description: data['description'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'perdue',
      userId: data['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'numero': numero,
        'type': type,
        'ville': ville,
        'lieu': lieu,
        'telephone': telephone,
        'photo': photo,
        'description': description,
        'createdAt': Timestamp.fromDate(createdAt),
        'status': status,
        'userId': userId,
      };

  DocumentEntity copyWith({String? photo}) => DocumentEntity(
        id: id,
        nom: nom,
        prenom: prenom,
        numero: numero,
        type: type,
        ville: ville,
        lieu: lieu,
        telephone: telephone,
        photo: photo ?? this.photo,
        description: description,
        createdAt: createdAt,
        status: status,
        userId: userId,
      );
}
