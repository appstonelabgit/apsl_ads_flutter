import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:easy_audience_network/easy_audience_network.dart';

class ApslFacebookFullScreenAd extends ApslAdBase {
  final AdUnitType _adUnitType;
  bool _isAdLoaded = false;
  bool _preLoadRewardedAds = false;

  ApslFacebookFullScreenAd({
    required String adUnitId,
    required AdUnitType adUnitType,
    bool preLoadRewardedAds = false,
  })  : assert(
            adUnitType == AdUnitType.interstitial ||
                adUnitType == AdUnitType.rewarded,
            'Ad Unit Type must be rewarded or interstitial'),
        _adUnitType = adUnitType,
        _preLoadRewardedAds = preLoadRewardedAds,
        super(adUnitId);

  @override
  AdNetwork get adNetwork => AdNetwork.facebook;

  @override
  AdUnitType get adUnitType => _adUnitType;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  void dispose() {
    _isAdLoaded = false;

    if (adUnitType == AdUnitType.interstitial) {
    } else {}
  }

  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;

    if (adUnitType == AdUnitType.interstitial) {
      interstitialAd = InterstitialAd(adUnitId);
      interstitialAd?.listener = _onInterstitialAdListener();
      interstitialAd?.load();
    } else {
      rewardedAd = RewardedAd(adUnitId);
      rewardedAd?.listener = _onRewardedAdListener();
      rewardedAd?.load();
    }
  }

  @override
  show() async {
    if (!_isAdLoaded) return;

    if (adUnitType == AdUnitType.interstitial) {
      if (interstitialAd == null) {
        load();
        return;
      }
      await interstitialAd?.show();
    } else {
      if (rewardedAd == null && _preLoadRewardedAds) {
        load();
        return;
      }
      await rewardedAd?.show();
    }
  }

  RewardedAdListener _onRewardedAdListener() {
    return RewardedAdListener(
      onError: (code, value) {
        _isAdLoaded = false;
        onAdFailedToLoad?.call(adNetwork, adUnitType, null,
            errorMessage: 'Error occurred while loading $code $value ad');
      },
      onLoaded: () {
        _isAdLoaded = true;
        onAdLoaded?.call(adNetwork, adUnitType, 'Loaded');
      },
      onClicked: () {
        onAdClicked?.call(adNetwork, adUnitType, 'Clicked');
      },
      onLoggingImpression: () {},
      onVideoComplete: () {
        onEarnedReward?.call(adNetwork, adUnitType, null, rewardAmount: null);
      },
      onVideoClosed: () {
        onAdDismissed?.call(adNetwork, adUnitType, 'Dismissed');
        _isAdLoaded = false;
        if (_preLoadRewardedAds) load();
      },
    );
  }

  InterstitialAdListener? _onInterstitialAdListener() {
    return InterstitialAdListener(
      onError: (code, value) {
        _isAdLoaded = false;
        onAdFailedToLoad?.call(adNetwork, adUnitType, null,
            errorMessage: 'Error occurred while loading $code $value ad');
      },
      onLoaded: () {
        _isAdLoaded = true;
        onAdLoaded?.call(adNetwork, adUnitType, 'Loaded');
      },
      onClicked: () {
        onAdClicked?.call(adNetwork, adUnitType, 'Clicked');
      },
      onDisplayed: () {
        onAdShowed?.call(adNetwork, adUnitType, 'Displayed');
      },
      onDismissed: () {
        onAdDismissed?.call(adNetwork, adUnitType, 'Dismissed');
        _isAdLoaded = false;
        load();
      },
      onLoggingImpression: () {},
    );
  }
}
