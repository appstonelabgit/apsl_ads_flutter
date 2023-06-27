import 'dart:async';

import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:flutter/material.dart';

class ApslAllBannerAd extends StatefulWidget {
  final List<AdNetwork> priorityAdNetworks;
  final AdSize adSize;
  const ApslAllBannerAd(
      {Key? key,
      this.priorityAdNetworks = const [
        AdNetwork.admob,
        AdNetwork.facebook,
        AdNetwork.unity,
      ],
      this.adSize = AdSize.banner})
      : super(key: key);

  @override
  State<ApslAllBannerAd> createState() => _ApslAllBannerAdState();
}

class _ApslAllBannerAdState extends State<ApslAllBannerAd> {
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
      // return const SizedBox();
      _currentADNetworkIndex = 0;
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
