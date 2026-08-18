import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/user_firebase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserFirebaseService _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Stream<UserEntity?> get authStateChanges {
    return _datasource.authStateChanges;
  }

  @override
  UserEntity? get currentUser => _datasource.currentUser;

  @override
  Future<UserEntity> signInWithGoogle() async {
    return await _datasource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await _datasource.signOut();
  }
}
