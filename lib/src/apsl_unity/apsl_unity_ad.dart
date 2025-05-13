import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class ApslUnityAd extends ApslAdBase {
  final AdUnitType _adUnitType;
  final bool _preLoadRewardedAds;

  bool _isAdLoaded = false;
  bool _isLoading = false;

  ApslUnityAd({
    required String adUnitId,
    required AdUnitType adUnitType,
    bool? preLoadRewardedAds,
  })  : _adUnitType = adUnitType,
        _preLoadRewardedAds = preLoadRewardedAds ?? false,
        super(adUnitId);

  @override
  AdUnitType get adUnitType => _adUnitType;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  AdNetwork get adNetwork => AdNetwork.unity;

  @override
  void dispose() {
    _isAdLoaded = false;
    _isLoading = false;
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded || _isLoading) return;

    _isLoading = true;

    UnityAds.load(
      placementId: adUnitId,
      onComplete: onCompleteLoadUnityAd,
      onFailed: onFailedToLoadUnityAd,
    );
  }

  @override
  Future<void> show() async {
    if (!_isAdLoaded) {
      onAdFailedToShow?.call(adNetwork, adUnitType, null,
          errorMessage: 'Unity Ad not loaded yet');
      load(); // Attempt to load for future
      return;
    }

    await UnityAds.showVideoAd(
      placementId: adUnitId,
      onStart: onStartUnityAd,
      onClick: onClickUnityAd,
      onSkipped: onSkipUnityAd,
      onComplete: onCompleteUnityAd,
      onFailed: onFailedToShowUnityAd,
    );

    _isAdLoaded = false;
  }

  void onCompleteLoadUnityAd(String placementId) {
    _isAdLoaded = true;
    _isLoading = false;
    onAdLoaded?.call(adNetwork, adUnitType, placementId);
  }

  void onFailedToLoadUnityAd(
      String placementId, UnityAdsLoadError error, String errorMessage) {
    _isAdLoaded = false;
    _isLoading = false;

    onAdFailedToLoad?.call(
      adNetwork,
      adUnitType,
      error,
      errorMessage: 'UnityAd load failed [$error]: $errorMessage',
    );

    // Retry after short delay
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isAdLoaded) load();
    });
  }

  void onStartUnityAd(String placementId) {
    onAdShowed?.call(adNetwork, adUnitType, placementId);
  }

  void onClickUnityAd(String placementId) {
    onAdClicked?.call(adNetwork, adUnitType, placementId);
  }

  void onSkipUnityAd(String placementId) {
    onAdDismissed?.call(adNetwork, adUnitType, placementId);
    _isAdLoaded = false;

    if (_adUnitType == AdUnitType.interstitial ||
        (_adUnitType == AdUnitType.rewarded && _preLoadRewardedAds)) {
      load(); // Preload again
    }
  }

  void onCompleteUnityAd(String placementId) {
    _isAdLoaded = false;

    if (_adUnitType == AdUnitType.rewarded) {
      onEarnedReward?.call(adNetwork, adUnitType, null, rewardAmount: null);
    } else {
      onAdDismissed?.call(adNetwork, adUnitType, placementId);
    }

    if (_adUnitType == AdUnitType.interstitial ||
        (_adUnitType == AdUnitType.rewarded && _preLoadRewardedAds)) {
      load();
    }
  }

  void onFailedToShowUnityAd(
      String placementId, UnityAdsShowError error, String errorMessage) {
    _isAdLoaded = false;
    onAdFailedToShow?.call(
      adNetwork,
      adUnitType,
      error,
      errorMessage: 'UnityAd show failed [$error]: $errorMessage',
    );
  }
}
