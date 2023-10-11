import 'dart:async';

import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

class ApslEventController {
  Stream<AdEvent> get onEvent => _onEventController.stream;
  final _onEventController = StreamController<AdEvent>.broadcast();

  void fireNetworkInitializedEvent(AdNetwork adNetwork, bool status) {
    _onEventController.add(AdEvent(
      type: AdEventType.adNetworkInitialized,
      adNetwork: adNetwork,
      data: status,
    ));
  }

  void setupEvents(ApslAdBase ad) {
    ad.onAdLoaded = _onAdLoadedMethod;
    ad.onAdFailedToLoad = _onAdFailedToLoadMethod;
    ad.onAdShowed = _onAdShowedMethod;
    ad.onAdFailedToShow = _onAdFailedToShowMethod;
    ad.onAdDismissed = _onAdDismissedMethod;
    ad.onEarnedReward = _onEarnedRewardMethod;
  }

  void _onAdLoadedMethod(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Object? data, {
    String? errorMessage,
    String? rewardType,
    num? rewardAmount,
  }) {
    _onEventController.add(AdEvent(
      type: AdEventType.adLoaded,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      data: data,
    ));
  }

  void _onAdShowedMethod(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Object? data, {
    String? errorMessage,
    String? rewardType,
    num? rewardAmount,
  }) {
    _onEventController.add(AdEvent(
      type: AdEventType.adShowed,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      data: data,
    ));
  }

  void _onAdFailedToLoadMethod(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Object? data, {
    String? errorMessage,
    String? rewardType,
    num? rewardAmount,
  }) {
    _onEventController.add(AdEvent(
      type: AdEventType.adFailedToLoad,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      data: data,
      error: errorMessage,
    ));
  }

  void _onAdFailedToShowMethod(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Object? data, {
    String? errorMessage,
    String? rewardType,
    num? rewardAmount,
  }) {
    _onEventController.add(AdEvent(
      type: AdEventType.adFailedToShow,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      data: data,
      error: errorMessage,
    ));
  }

  void _onAdDismissedMethod(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Object? data, {
    String? errorMessage,
    String? rewardType,
    num? rewardAmount,
  }) {
    _onEventController.add(AdEvent(
      type: AdEventType.adDismissed,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      data: data,
    ));
  }

  void _onEarnedRewardMethod(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Object? data, {
    String? rewardType,
    String? errorMessage,
    num? rewardAmount,
  }) {
    _onEventController.add(AdEvent(
      type: AdEventType.earnedReward,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      data: {'rewardType': rewardType, 'rewardAmount': rewardAmount},
    ));
  }
}
