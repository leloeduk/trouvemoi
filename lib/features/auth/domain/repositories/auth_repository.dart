import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Stream pour écouter les changements d'état de connexion
  Stream<UserEntity?> get authStateChanges;

  // Récupérer l'utilisateur actuellement connecté
  UserEntity? get currentUser;

  // Se connecter avec Google
  Future<UserEntity> signInWithGoogle();

  // Se déconnecter
  Future<void> signOut();
}
