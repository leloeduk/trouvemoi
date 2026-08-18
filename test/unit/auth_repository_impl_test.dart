import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trouvemoi/features/auth/data/models/user_model.dart';
import 'package:trouvemoi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:trouvemoi/features/auth/data/services/user_firebase_service.dart';

import '../helpers/fakes.dart';

class MockUserFirebaseService extends Mock implements UserFirebaseService {}

void main() {
  late MockUserFirebaseService service;
  late AuthRepositoryImpl repository;

  final userModel = UserModel.fromEntity(sampleUser());

  setUp(() {
    service = MockUserFirebaseService();
    repository = AuthRepositoryImpl(service);
  });

  group('AuthRepositoryImpl.authStateChanges', () {
    test('délègue au service', () {
      final stream = Stream<UserModel?>.value(null);
      when(() => service.authStateChanges).thenAnswer((_) => stream);

      expect(repository.authStateChanges, same(stream));
    });
  });

  group('AuthRepositoryImpl.currentUser', () {
    test('retourne null si aucun utilisateur', () {
      when(() => service.currentUser).thenReturn(null);

      expect(repository.currentUser, isNull);
    });

    test('retourne lutilisateur courant', () {
      when(() => service.currentUser).thenReturn(userModel);

      expect(repository.currentUser, userModel);
    });
  });

  group('AuthRepositoryImpl.signInWithGoogle', () {
    test('délègue au service et retourne lutilisateur', () async {
      when(() => service.signInWithGoogle()).thenAnswer((_) async => userModel);

      final result = await repository.signInWithGoogle();

      expect(result, userModel);
      verify(() => service.signInWithGoogle()).called(1);
    });
  });

  group('AuthRepositoryImpl.signOut', () {
    test('délègue au service', () async {
      when(() => service.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => service.signOut()).called(1);
    });
  });
}
