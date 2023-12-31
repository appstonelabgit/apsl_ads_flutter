import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A class encapsulating the logic for AdMob's Rewarded Ads.
class ApslAdmobRewardedAd extends ApslAdBase {
  final AdRequest _adRequest;
  final bool _immersiveModeEnabled;
  final bool _preLoadRewardedAds;

  /// Constructor for creating an instance of ApslAdmobRewardedAd.
  ApslAdmobRewardedAd({
    required String adUnitId,
    required AdRequest adRequest,
    required bool immersiveModeEnabled,
    required bool preLoadRewardedAds,
  })  : _adRequest = adRequest,
        _immersiveModeEnabled = immersiveModeEnabled,
        _preLoadRewardedAds = preLoadRewardedAds,
        super(adUnitId);

  RewardedAd? _rewardedAd; // Reference to the loaded rewarded ad
  bool _isAdLoaded = false; // Flag to check if the ad has been loaded

  // Overridden getters
  @override
  AdNetwork get adNetwork => AdNetwork.admob;
  @override
  AdUnitType get adUnitType => AdUnitType.rewarded;
  @override
  bool get isAdLoaded => _isAdLoaded;

  /// Disposes the rewarded ad to release any resources.
  @override
  void dispose() {
    _isAdLoaded = false;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  /// Loads the rewarded ad.
  @override
  Future<void> load() async {
    if (_isAdLoaded) return;
    await RewardedAd.load(
        adUnitId: adUnitId,
        request: _adRequest,
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        }, onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isAdLoaded = false;
          onAdFailedToLoad?.call(
            adNetwork,
            adUnitType,
            error,
            errorMessage: error.toString(),
          );
        }));
  }

  /// Displays the loaded rewarded ad.
  @override
  dynamic show() {
    final ad = _rewardedAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        onAdDismissed?.call(adNetwork, adUnitType, ad);

        ad.dispose();
        if (_preLoadRewardedAds) load(); // Option to preload the next ad
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        onAdFailedToShow?.call(
          adNetwork,
          adUnitType,
          ad,
          errorMessage: error.toString(),
        );

        ad.dispose();
        if (_preLoadRewardedAds) load(); // Option to preload the next ad
      },
    );

    ad.setImmersiveMode(_immersiveModeEnabled);
    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onEarnedReward?.call(
        adNetwork,
        adUnitType,
        reward.type,
        rewardAmount: reward.amount,
      );
    });
    _rewardedAd = null;
    _isAdLoaded = false;
  }
}
