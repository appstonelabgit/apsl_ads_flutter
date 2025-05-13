import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:easy_audience_network/easy_audience_network.dart';

class ApslFacebookFullScreenAd extends ApslAdBase {
  final AdUnitType _adUnitType;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  final bool _preLoadRewardedAds;

  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;

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
    _isLoading = false;

    interstitialAd?.destroy();
    interstitialAd = null;

    rewardedAd?.destroy();
    rewardedAd = null;
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded || _isLoading) return;

    _isLoading = true;

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
  Future<void> show() async {
    if (!_isAdLoaded) {
      load(); // Try to load again if not loaded
      return;
    }

    if (adUnitType == AdUnitType.interstitial && interstitialAd != null) {
      await interstitialAd?.show();
    } else if (adUnitType == AdUnitType.rewarded && rewardedAd != null) {
      await rewardedAd?.show();
    }
  }

  RewardedAdListener _onRewardedAdListener() {
    return RewardedAdListener(
      onError: (code, value) {
        _isAdLoaded = false;
        _isLoading = false;
        onAdFailedToLoad?.call(adNetwork, adUnitType, null,
            errorMessage: 'Error occurred while loading $code: $value');

        Future.delayed(const Duration(seconds: 5), () {
          if (!_isAdLoaded) load();
        });
      },
      onLoaded: () {
        _isAdLoaded = true;
        _isLoading = false;
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

        if (_preLoadRewardedAds) {
          load(); // Preload next one
        }
      },
    );
  }

  InterstitialAdListener _onInterstitialAdListener() {
    return InterstitialAdListener(
      onError: (code, value) {
        _isAdLoaded = false;
        _isLoading = false;
        onAdFailedToLoad?.call(adNetwork, adUnitType, null,
            errorMessage: 'Error occurred while loading $code: $value');

        Future.delayed(const Duration(seconds: 5), () {
          if (!_isAdLoaded) load();
        });
      },
      onLoaded: () {
        _isAdLoaded = true;
        _isLoading = false;
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
        load(); // Load again after close
      },
      onLoggingImpression: () {},
    );
  }
}
