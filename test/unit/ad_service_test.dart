import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/core/services/ad_service.dart';

void main() {
  group('AdService - identifiants publicitaires', () {
    test('utilise les publicités de TEST en développement', () {
      expect(
        AdService.bannerAdUnitId,
        'ca-app-pub-3940256099942544/6300978111',
      );
      expect(
        AdService.interstitialAdUnitId,
        'ca-app-pub-3940256099942544/1033173712',
      );
      expect(
        AdService.appOpenAdUnitId,
        'ca-app-pub-3940256099942544/9257395921',
      );
      expect(
        AdService.rewardedAdUnitId,
        'ca-app-pub-3940256099942544/5224354917',
      );
    });

    test('le SDK n\'est pas initialisé au départ', () {
      expect(AdService.instance.isInitialized.value, isFalse);
    });

    test('les publicités sont désactivées tant que le SDK n\'est pas initialisé',
        () async {
      await AdService.instance.showInterstitial();
      await AdService.instance.showAppOpenAd();
      final shown =
          await AdService.instance.showRewardedAd(onRewarded: () {});
      expect(shown, isFalse);
    });
  });
}