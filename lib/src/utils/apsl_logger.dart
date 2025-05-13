import 'dart:async';

import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as admob;
import 'package:logger/logger.dart';

/// [ApslLogger] listens to [ApslAds] events and logs ad lifecycle changes.
class ApslLogger {
  final Logger _logger = Logger();
  StreamSubscription<AdEvent>? streamSubscription;

  /// Enables or disables ad event logging.
  void enable(bool enabled) {
    streamSubscription?.cancel();
    if (enabled) {
      streamSubscription = ApslAds.instance.onEvent.listen(_onAdEvent);
    }
  }

  /// Call this to release stream resources (e.g., in dispose).
  void dispose() {
    streamSubscription?.cancel();
    streamSubscription = null;
  }

  void logInfo(String message) => _logger.i(message);

  void _onAdNetworkInitialized(AdEvent event) {
    final network = event.adNetwork.value;
    final status = event.data == true;
    _logger.log(
      status ? Level.info : Level.error,
      '$network has ${status ? "been initialized" : "failed to initialize"}.',
    );
  }

  void _onAdLoaded(AdEvent event) {
    String message =
        '${event.adUnitType?.value ?? "unknown"} ad loaded for ${event.adNetwork.value}.';

    if (event.adNetwork == AdNetwork.admob) {
      final ad = event.data as admob.Ad?;
      final adapter =
          ad?.responseInfo?.mediationAdapterClassName ?? "unknown adapter";
      message += ' Adapter: $adapter';
    }

    _logger.i(message);
  }

  void _onAdFailedToLoad(AdEvent event) {
    _logger.e(
        '${event.adUnitType?.value ?? "unknown"} ad failed to load for ${event.adNetwork.value}.\nError: ${event.error ?? "unknown"}');
  }

  void _onAdShowed(AdEvent event) {
    _logger.i(
        '${event.adUnitType?.value ?? "unknown"} ad shown for ${event.adNetwork.value}.');
  }

  void _onAdFailedShow(AdEvent event) {
    _logger.e(
        '${event.adUnitType?.value ?? "unknown"} ad failed to show for ${event.adNetwork.value}.\nError: ${event.error ?? "unknown"}');
  }

  void _onAdDismissed(AdEvent event) {
    _logger.i(
        '${event.adUnitType?.value ?? "unknown"} ad dismissed for ${event.adNetwork.value}.');
  }

  void _onEarnedReward(AdEvent event) {
    final rewardData =
        event.data is Map ? event.data as Map : <String, dynamic>{};
    final rewardType = rewardData['rewardType'] ?? "unknown";
    final rewardAmount = rewardData['rewardAmount'] ?? "unknown";

    _logger.i(
        'User earned $rewardAmount of "$rewardType" from ${event.adNetwork.value}.');
  }

  void _onAdEvent(AdEvent event) {
    switch (event.type) {
      case AdEventType.adNetworkInitialized:
        _onAdNetworkInitialized(event);
        break;
      case AdEventType.adLoaded:
        _onAdLoaded(event);
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
      case AdEventType.adDismissed:
        _onAdDismissed(event);
        break;
      case AdEventType.earnedReward:
        _onEarnedReward(event);
        break;
    }
  }
}
