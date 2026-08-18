import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.displayName,
    required super.email,
    super.photoUrl,
  });

  // Convertir Firebase User en UserModel
  factory UserModel.fromFirebaseUser({
    required String uid,
    required String displayName,
    required String email,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName.isEmpty ? 'Utilisateur' : displayName,
      email: email,
      photoUrl: photoUrl,
    );
  }

  // Convertir Entity en Model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      displayName: entity.displayName,
      email: entity.email,
      photoUrl: entity.photoUrl,
    );
  }

  // Convertir en Map (pour Firestore si besoin de sauvegarder le user)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
