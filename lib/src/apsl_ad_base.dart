import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';

abstract class ApslAdBase {
  final String adUnitId;

  /// This will be called for initialization when we don't have to wait for the initialization
  ApslAdBase(this.adUnitId);

  AdNetwork get adNetwork;
  AdUnitType get adUnitType;
  bool get isAdLoaded;

  void dispose();

  /// This will load ad, It will only load the ad if isAdLoaded is false
  Future<void> load();
  dynamic show();

  ApslAdCallback? onAdLoaded;
  ApslAdCallback? onAdShowed;
  ApslAdCallback? onAdClicked;
  ApslAdFailedCallback? onAdFailedToLoad;
  ApslAdFailedCallback? onAdFailedToShow;
  ApslAdCallback? onAdDismissed;
  ApslAdCallback? onBannerAdReadyForSetState;
  ApslAdCallback? onNativeAdReadyForSetState;
  ApslAdEarnedReward? onEarnedReward;
}

typedef EasyAdNetworkInitialized = void Function(
    AdNetwork adNetwork, bool isInitialized, Object? data);
typedef ApslAdFailedCallback = void Function(AdNetwork adNetwork,
    AdUnitType adUnitType, Object? data, String errorMessage);
typedef ApslAdCallback = void Function(
    AdNetwork adNetwork, AdUnitType adUnitType, Object? data);
typedef ApslAdEarnedReward = void Function(AdNetwork adNetwork,
    AdUnitType adUnitType, String? rewardType, num? rewardAmount);
