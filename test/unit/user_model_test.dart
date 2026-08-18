import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/features/auth/data/models/user_model.dart';

import '../helpers/fakes.dart';

void main() {
  group('UserModel.fromFirebaseUser', () {
    test('crée un modèle avec toutes les informations', () {
      final model = UserModel.fromFirebaseUser(
        uid: 'user-1',
        displayName: 'Jean Congo',
        email: 'jean@example.com',
        photoUrl: 'https://example.com/photo.jpg',
      );

      expect(model.uid, 'user-1');
      expect(model.displayName, 'Jean Congo');
      expect(model.email, 'jean@example.com');
      expect(model.photoUrl, 'https://example.com/photo.jpg');
    });

    test('remplace un displayName vide par "Utilisateur"', () {
      final model = UserModel.fromFirebaseUser(
        uid: 'user-1',
        displayName: '',
        email: 'jean@example.com',
      );

      expect(model.displayName, 'Utilisateur');
    });

    test('autorise photoUrl null', () {
      final model = UserModel.fromFirebaseUser(
        uid: 'user-1',
        displayName: 'Jean',
        email: 'jean@example.com',
      );

      expect(model.photoUrl, isNull);
    });
  });

  group('UserModel.fromEntity', () {
    test('copie toutes les propriétés', () {
      final entity = sampleUser();
      final model = UserModel.fromEntity(entity);

      expect(model.uid, entity.uid);
      expect(model.displayName, entity.displayName);
      expect(model.email, entity.email);
      expect(model.photoUrl, entity.photoUrl);
    });
  });

  group('UserModel.toMap', () {
    test('sérialise en Map pour Firestore', () {
      final model = UserModel.fromEntity(sampleUser());
      final map = model.toMap();

      expect(map['uid'], 'user-1');
      expect(map['displayName'], 'Jean Congo');
      expect(map['email'], 'jean@example.com');
      expect(map['photoUrl'], isNull);
    });
  });

  group('UserEntity equality', () {
    test('deux entités identiques sont égales', () {
      expect(sampleUser(), sampleUser());
    });

    test('deux entités différentes ne sont pas égales', () {
      expect(sampleUser(), isNot(sampleUser(uid: 'other')));
    });
  });
}
