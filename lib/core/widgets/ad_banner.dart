import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

/// Bannière AdMob réutilisable.
///
/// S'affiche uniquement après l'initialisation du SDK AdMob
/// (désactivée dans les tests ou si le SDK est indisponible).
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  ValueListenable<bool>? _initializedListenable;

  @override
  void initState() {
    super.initState();
    _initializedListenable = AdService.instance.isInitialized;
    _initializedListenable!.addListener(_onInitChanged);
    if (_initializedListenable!.value) {
      _loadBanner();
    }
  }

  @override
  void dispose() {
    _initializedListenable?.removeListener(_onInitChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onInitChanged() {
    if (_initializedListenable!.value && _bannerAd == null) {
      _loadBanner();
    }
  }

  void _loadBanner() {
    try {
      final banner = BannerAd(
        adUnitId: AdService.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _bannerAd = ad as BannerAd;
                _isLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      );
      banner.load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 60,
      color: Colors.white,
      child: Center(
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}