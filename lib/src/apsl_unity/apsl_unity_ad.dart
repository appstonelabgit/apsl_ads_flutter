import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class ApslUnityAd extends ApslAdBase {
  final AdUnitType _adUnitType;
  bool _isAdLoaded = false;
  bool _preLoadRewardedAds = false;

  ApslUnityAd({
    required String adUnitId,
    required AdUnitType adUnitType,
    bool? preLoadRewardedAds,
  })  : _preLoadRewardedAds = preLoadRewardedAds ?? false,
        _adUnitType = adUnitType,
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
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;

    UnityAds.load(
      placementId: adUnitId,
      onComplete: onCompleteLoadUnityAd,
      onFailed: onFailedToLoadUnityAd,
    );
  }

  @override
  show() async {
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

  void onCompleteLoadUnityAd(String s) {
    _isAdLoaded = true;
    onAdLoaded?.call(adNetwork, adUnitType, null);
  }

  void onFailedToLoadUnityAd(
      String placementId, UnityAdsLoadError error, String errorMessage) {
    _isAdLoaded = false;
    onAdFailedToLoad?.call(
      adNetwork,
      adUnitType,
      error,
      errorMessage: 'Error occurred while loading unity ad',
    );
  }

  void onStartUnityAd(String s) {
    _isAdLoaded = false;
    onAdShowed?.call(adNetwork, adUnitType, null);
  }

  void onClickUnityAd(String s) {
    onAdClicked?.call(adNetwork, adUnitType, null);
  }

  void onSkipUnityAd(String s) {
    onAdDismissed?.call(adNetwork, adUnitType, null);
  }

  void onCompleteUnityAd(String s) {
    _isAdLoaded = false;
    if (adUnitType == AdUnitType.rewarded) {
      onEarnedReward?.call(adNetwork, adUnitType, null, rewardAmount: null);
    } else {
      onAdDismissed?.call(adNetwork, adUnitType, null);
    }

    //dv removed preloading of rewarded ad
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
      errorMessage: 'Error occurred while loading unity ad',
    );
  }
}
