import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('retourne une erreur si la valeur est null', () {
      expect(Validators.required(null), 'Ce champ est requis');
    });

    test('retourne une erreur si la valeur est vide', () {
      expect(Validators.required(''), 'Ce champ est requis');
    });

    test('retourne une erreur si la valeur ne contient que des espaces', () {
      expect(Validators.required('   '), 'Ce champ est requis');
    });

    test('retourne null pour une valeur valide', () {
      expect(Validators.required('Passeport'), isNull);
    });

    test('utilise le nom de champ personnalisé', () {
      expect(
        Validators.required('', 'Le titre'),
        'Le titre est requis',
      );
    });
  });

  group('Validators.phone', () {
    test('retourne une erreur si le téléphone est null', () {
      expect(Validators.phone(null), 'Le téléphone est requis');
    });

    test('retourne une erreur si le téléphone est vide', () {
      expect(Validators.phone(''), 'Le téléphone est requis');
    });

    test('accepte un numéro congolais valide (06)', () {
      expect(Validators.phone('061234567'), isNull);
    });

    test('accepte un numéro congolais valide (05)', () {
      expect(Validators.phone('055123456'), isNull);
    });

    test('accepte un numéro congolais valide (04)', () {
      expect(Validators.phone('044123456'), isNull);
    });

    test('accepte un numéro avec des espaces', () {
      expect(Validators.phone('06 635 24 55'), isNull);
    });

    test('rejette un numéro avec le préfixe +242', () {
      expect(Validators.phone('+242 06 635 24 55'),
          'Numéro invalide (ex: 06 635 24 55)');
    });

    test('rejette un numéro trop court', () {
      expect(Validators.phone('06123'), 'Numéro invalide (ex: 06 635 24 55)');
    });

    test('rejette un numéro ne commençant pas par 04, 05 ou 06', () {
      expect(Validators.phone('071234567'),
          'Numéro invalide (ex: 06 635 24 55)');
    });

    test('rejette un numéro avec des lettres', () {
      expect(Validators.phone('06abcdefg'),
          'Numéro invalide (ex: 06 635 24 55)');
    });
  });
}
