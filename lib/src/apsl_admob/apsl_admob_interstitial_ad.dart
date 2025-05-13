import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A class that encapsulates the logic for AdMob's Interstitial Ads.
class ApslAdmobInterstitialAd extends ApslAdBase {
  final AdRequest _adRequest;
  final bool _immersiveModeEnabled;

  ApslAdmobInterstitialAd(
    super.adUnitId,
    this._adRequest,
    this._immersiveModeEnabled,
  );

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  AdUnitType get adUnitType => AdUnitType.interstitial;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  void dispose() {
    _isAdLoaded = false;
    _isLoading = false;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded || _isLoading) return;

    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: _adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd?.dispose(); // Clean up previous instance
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isLoading = false;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isAdLoaded = false;
          _isLoading = false;
          onAdFailedToLoad?.call(
            adNetwork,
            adUnitType,
            error,
            errorMessage: error.toString(),
          );

          // Retry after short delay
          Future.delayed(const Duration(seconds: 5), () {
            if (!_isAdLoaded) load();
          });
        },
      ),
    );
  }

  @override
  void show() {
    final ad = _interstitialAd;
    if (ad == null || !_isAdLoaded) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        onAdDismissed?.call(adNetwork, adUnitType, ad);
        _cleanAndReload(ad);
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        onAdFailedToShow?.call(
          adNetwork,
          adUnitType,
          ad,
          errorMessage: error.toString(),
        );
        _cleanAndReload(ad);
      },
    );

    ad.setImmersiveMode(_immersiveModeEnabled);
    ad.show();

    _interstitialAd = null;
    _isAdLoaded = false;
  }

  void _cleanAndReload(InterstitialAd ad) {
    ad.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _isLoading = false;
    load(); // Preload next ad
  }
}
