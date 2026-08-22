import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gère toutes les publicités AdMob de l'application.
///
/// Un singleton centralise le chargement et l'affichage des différents
/// formats : bannière, interstitielle, application ouverte et récompensée.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  // --- Identifiants des unités publicitaires AdMob ---
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static const String _realBannerAdUnitId =
      'ca-app-pub-3010995346645294/4769033911';
  static const String _realInterstitialAdUnitId =
      'ca-app-pub-3010995346645294/9115473033';
  static const String _realAppOpenAdUnitId =
      'ca-app-pub-3010995346645294/5125820232';
  static const String _realRewardedAdUnitId =
      'ca-app-pub-3010995346645294/4762858156';

  /// En développement (debug/profile) : publicités de test AdMob.
  /// En production (release) : les vraies publicités monétisées.
  static String get bannerAdUnitId =>
      kReleaseMode ? _realBannerAdUnitId : _testBannerAdUnitId;
  static String get interstitialAdUnitId =>
      kReleaseMode ? _realInterstitialAdUnitId : _testInterstitialAdUnitId;
  static String get appOpenAdUnitId =>
      kReleaseMode ? _realAppOpenAdUnitId : _testAppOpenAdUnitId;
  static String get rewardedAdUnitId =>
      kReleaseMode ? _realRewardedAdUnitId : _testRewardedAdUnitId;

  /// Indique si le SDK AdMob a été initialisé. Reste `false` en environnement
  /// de test (aucun plugin disponible), ce qui désactive les publicités.
  final ValueNotifier<bool> isInitialized = ValueNotifier(false);

  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  RewardedAd? _rewardedAd;

  int _detailViewCount = 0;

  /// Compte les ouvertures de la page de détail d'un document et affiche une
  /// publicité interstitielle une fois toutes les [frequency] ouvertures.
  void onDocumentDetailOpened({int frequency = 5}) {
    _detailViewCount++;
    if (_detailViewCount % frequency == 0) {
      unawaited(showInterstitial());
    }
  }

  /// Initialise le SDK AdMob et précharge les formats pleine écran.
  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      isInitialized.value = true;
      unawaited(_loadInterstitial());
      unawaited(_loadAppOpen());
      unawaited(_loadRewarded());
    } catch (_) {
      // SDK indisponible (ex: tests) : les publicités restent désactivées.
    }
  }

  Future<void> _loadInterstitial() async {
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (_) {
                _interstitialAd = null;
                unawaited(_loadInterstitial());
              },
              onAdFailedToShowFullScreenContent: (_, __) {
                _interstitialAd = null;
                unawaited(_loadInterstitial());
              },
            );
          },
          onAdFailedToLoad: (_) {
            _interstitialAd = null;
          },
        ),
      );
    } catch (_) {}
  }

  Future<void> _loadAppOpen() async {
    try {
      await AppOpenAd.load(
        adUnitId: appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (_) {
                _appOpenAd = null;
                unawaited(_loadAppOpen());
              },
              onAdFailedToShowFullScreenContent: (_, __) {
                _appOpenAd = null;
                unawaited(_loadAppOpen());
              },
            );
          },
          onAdFailedToLoad: (_) {
            _appOpenAd = null;
          },
        ),
      );
    } catch (_) {}
  }

  Future<void> _loadRewarded() async {
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (_) {
                _rewardedAd = null;
                unawaited(_loadRewarded());
              },
              onAdFailedToShowFullScreenContent: (_, __) {
                _rewardedAd = null;
                unawaited(_loadRewarded());
              },
            );
          },
          onAdFailedToLoad: (_) {
            _rewardedAd = null;
          },
        ),
      );
    } catch (_) {}
  }

  /// Affiche une publicité interstitielle si une est prête.
  Future<void> showInterstitial() async {
    if (!isInitialized.value) return;
    final ad = _interstitialAd;
    if (ad == null) {
      unawaited(_loadInterstitial());
      return;
    }
    _interstitialAd = null;
    try {
      await ad.show();
    } catch (_) {}
  }

  /// Affiche une publicité au lancement de l'application si une est prête.
  Future<void> showAppOpenAd() async {
    if (!isInitialized.value) return;
    final ad = _appOpenAd;
    if (ad == null) {
      unawaited(_loadAppOpen());
      return;
    }
    _appOpenAd = null;
    try {
      await ad.show();
    } catch (_) {}
  }

  /// Affiche une publicité récompensée. Retourne `true` si elle a été montrée.
  ///
  /// [onRewarded] est appelé lorsque l'utilisateur a gagné la récompense.
  Future<bool> showRewardedAd({required VoidCallback onRewarded}) async {
    if (!isInitialized.value) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      unawaited(_loadRewarded());
      return false;
    }
    _rewardedAd = null;
    try {
      await ad.show(onUserEarnedReward: (_, __) {
        onRewarded();
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}