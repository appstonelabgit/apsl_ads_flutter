import 'dart:async';

import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:flutter/material.dart';

class ApslSmartBannerAd extends StatefulWidget {
  final List<AdNetwork> priorityAdNetworks;
  final AdSize adSize;
  const ApslSmartBannerAd(
      {Key? key,
      this.priorityAdNetworks = const [
        AdNetwork.admob,
        AdNetwork.facebook,
        AdNetwork.unity,
      ],
      this.adSize = AdSize.banner})
      : super(key: key);

  @override
  State<ApslSmartBannerAd> createState() => _ApslSmartBannerAdState();
}

class _ApslSmartBannerAdState extends State<ApslSmartBannerAd> {
  int _currentADNetworkIndex = 0;
  StreamSubscription? _streamSubscription;

  @override
  void dispose() {
    _cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.priorityAdNetworks.length;
    if (_currentADNetworkIndex >= length) {
      return const SizedBox();
    }

    while (_currentADNetworkIndex < length) {
      if (_isBannerIdAvailable(
          widget.priorityAdNetworks[_currentADNetworkIndex])) {
        return _showBannerAd(widget.priorityAdNetworks[_currentADNetworkIndex]);
      }

      _currentADNetworkIndex++;
    }
    return const SizedBox();
  }

  void _subscribeToAdEvent(AdNetwork priorityAdNetwork) {
    _cancelStream();
    _streamSubscription = ApslAds.instance.onEvent.listen((event) {
      if (event.adNetwork == priorityAdNetwork &&
          event.adUnitType == AdUnitType.banner &&
          (event.type == AdEventType.adFailedToLoad ||
              event.type == AdEventType.adFailedToShow)) {
        _cancelStream();
        _currentADNetworkIndex++;
        setState(() {});
      } else if (event.adNetwork == priorityAdNetwork &&
          event.adUnitType == AdUnitType.banner &&
          (event.type == AdEventType.adShowed ||
              event.type == AdEventType.adLoaded)) {
        _cancelStream();
      }
    });
  }

  bool _isBannerIdAvailable(AdNetwork adNetwork) {
    final adIdManager = ApslAds.instance.adIdManager;
    return adIdManager.appAdIds.any(
      (adIds) =>
          adIds.adNetwork == adNetwork.name &&
          adIds.bannerId != null &&
          adIds.bannerId!.isNotEmpty,
    );

    // adIdManager.appAdIds.
    // if (adNetwork == AdNetwork.admob &&
    //     adIdManager.admobAdIds?.bannerId != null) {
    //   return true;
    // } else if (adNetwork == AdNetwork.facebook &&
    //     adIdManager.fbAdIds?.bannerId != null) {
    //   return true;
    // } else if (adNetwork == AdNetwork.appLovin &&
    //     adIdManager.appLovinAdIds?.bannerId != null) {
    //   return true;
    // } else if (adNetwork == AdNetwork.unity &&
    //     adIdManager.unityAdIds?.bannerId != null) {
    //   return true;
    // } else {
    //   return false;
    // }
  }

  Widget _showBannerAd(AdNetwork priorityAdNetwork) {
    _subscribeToAdEvent(priorityAdNetwork);
    return ApslBannerAd(adNetwork: priorityAdNetwork, adSize: widget.adSize);
  }

  void _cancelStream() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}
