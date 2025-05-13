import 'dart:async';
import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:flutter/foundation.dart';

class ApslEventController {
  final bool debugLogging;

  ApslEventController({this.debugLogging = false});

  final _onEventController = StreamController<AdEvent>.broadcast();
  Stream<AdEvent> get onEvent => _onEventController.stream;

  void dispose() {
    _onEventController.close();
  }

  void fireNetworkInitializedEvent(AdNetwork adNetwork, bool status) {
    _addEvent(AdEvent(
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

  void _addEvent(AdEvent event) {
    if (!_onEventController.isClosed) {
      _onEventController.sink.add(event);
      if (debugLogging) {
        debugPrint(
            '[ApslEventController] => ${event.type} (${event.adNetwork})');
      }
    }
  }

  void _onAdLoadedMethod(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Object? data, {
    String? errorMessage,
    String? rewardType,
    num? rewardAmount,
  }) {
    _addEvent(AdEvent(
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
    _addEvent(AdEvent(
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
    _addEvent(AdEvent(
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
    _addEvent(AdEvent(
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
    _addEvent(AdEvent(
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
    _addEvent(AdEvent(
      type: AdEventType.earnedReward,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      data: {
        'rewardType': rewardType,
        'rewardAmount': rewardAmount,
      },
    ));
  }
}
