import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/core/services/app_update_service.dart';

void main() {
  group('AppUpdateService.isUpdateAvailable', () {
    test('une version supérieure (mineur) est disponible', () {
      expect(
        AppUpdateService.isUpdateAvailable('1.0.0', '1.1.0'),
        isTrue,
      );
    });

    test('une version supérieure (patch) est disponible', () {
      expect(
        AppUpdateService.isUpdateAvailable('1.0.0', '1.0.1'),
        isTrue,
      );
    });

    test('une version majeure supérieure est disponible', () {
      expect(
        AppUpdateService.isUpdateAvailable('1.9.0', '2.0.0'),
        isTrue,
      );
    });

    test('la même version n\'est pas une mise à jour', () {
      expect(
        AppUpdateService.isUpdateAvailable('1.1.0', '1.1.0'),
        isFalse,
      );
    });

    test('une version inférieure n\'est pas une mise à jour', () {
      expect(
        AppUpdateService.isUpdateAvailable('1.2.0', '1.1.9'),
        isFalse,
      );
    });

    test('"1.1" vs "1.1.1" : la version à 3 segments est plus récente', () {
      expect(
        AppUpdateService.isUpdateAvailable('1.1', '1.1.1'),
        isTrue,
      );
    });

    test('une version invalide retourne false', () {
      expect(
        AppUpdateService.isUpdateAvailable('abc', '1.0.0'),
        isFalse,
      );
      expect(
        AppUpdateService.isUpdateAvailable('1.0.0', 'dernier'),
        isFalse,
      );
    });
  });
}