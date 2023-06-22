import 'dart:async';

import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:logger/logger.dart';

/// [ApslLogger] is used to listen to the callbacks in stream & show logs
class ApslLogger {
  /// [Logger] is used to show logs in console for EasyAds
  final _logger = Logger();
  StreamSubscription? streamSubscription;

  void enable(bool enabled) {
    streamSubscription?.cancel();
    if (enabled) {
      streamSubscription = ApslAds.instance.onEvent.listen(_onAdEvent);
    }
  }

  void logInfo(String message) => _logger.i(message);

  void _onAdNetworkInitialized(AdEvent event) {
    if (event.data == true) {
      _logger.i(
          "${event.adNetwork.value} has been initialized and is ready to use.");
    } else {
      _logger.e("${event.adNetwork.value} could not be initialized.");
    }
  }

  void _onAdLoaded(AdEvent event) {
    String message =
        "${event.adUnitType?.value} ads for ${event.adNetwork.value} have been loaded.";
    if (event.adNetwork == AdNetwork.admob) {
      final ad = event.data as Ad?;
      message +=
          ' adapter status: ${ad?.responseInfo?.mediationAdapterClassName}';
    }

    _logger.i(message);
  }

  void _onAdFailedToLoad(AdEvent event) {
    _logger.e(
        "${event.adUnitType?.value} ads for ${event.adNetwork.value} could not be loaded.\nERROR: ${event.error}");
  }

  void _onAdShowed(AdEvent event) {
    _logger.i(
        "${event.adUnitType?.value} ad for ${event.adNetwork.value} has been shown.");
  }

  void _onAdFailedShow(AdEvent event) {
    _logger.e(
        "${event.adUnitType?.value} ad for ${event.adNetwork.value} could not be showed.\nERROR: ${event.error}");
  }

  void _onAdDismissed(AdEvent event) {
    _logger.i(
        "${event.adUnitType?.value} ad for ${event.adNetwork.value} has been dismissed.");
  }

  void _onEarnedReward(AdEvent event) {
    final dataMap = event.data as Map<String, dynamic>?;
    _logger.i(
        "User has earned ${dataMap?['rewardAmount']} of ${dataMap?['rewardType']} from ${event.adNetwork.value}");
  }

  void _onAdEvent(AdEvent event) {
    switch (event.type) {
      case AdEventType.adNetworkInitialized:
        _onAdNetworkInitialized(event);
        break;
      case AdEventType.adLoaded:
        _onAdLoaded(event);
        break;
      case AdEventType.adDismissed:
        _onAdDismissed(event);
        break;
      case AdEventType.adShowed:
        _onAdShowed(event);
        break;
      case AdEventType.adFailedToLoad:
        _onAdFailedToLoad(event);
        break;
      case AdEventType.adFailedToShow:
        _onAdFailedShow(event);
        break;
      case AdEventType.earnedReward:
        _onEarnedReward(event);
        break;
    }
  }
}
