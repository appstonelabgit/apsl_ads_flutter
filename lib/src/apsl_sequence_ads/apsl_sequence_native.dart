import 'dart:async';

import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:flutter/material.dart';

class ApslSequenceNativeAd extends StatefulWidget {
  final List<AdNetwork> priorityAdNetworks;
  final NativeTemplateStyle? nativeTemplateStyle;
  final TemplateType? templateType;
  const ApslSequenceNativeAd({
    Key? key,
    this.nativeTemplateStyle,
    this.templateType,
    this.priorityAdNetworks = const [
      AdNetwork.admob,
      AdNetwork.facebook,
    ],
  }) : super(key: key);

  @override
  State<ApslSequenceNativeAd> createState() => _ApslSequenceNativeAdState();
}

class _ApslSequenceNativeAdState extends State<ApslSequenceNativeAd> {
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
      if (_isNativeIdAvailable(
          widget.priorityAdNetworks[_currentADNetworkIndex])) {
        return _showNativeAd(widget.priorityAdNetworks[_currentADNetworkIndex]);
      }

      _currentADNetworkIndex++;
    }
    return const SizedBox();
  }

  void _subscribeToAdEvent(AdNetwork priorityAdNetwork) {
    _cancelStream();
    _streamSubscription = ApslAds.instance.onEvent.listen((event) {
      if (event.adNetwork == priorityAdNetwork &&
          event.adUnitType == AdUnitType.native &&
          (event.type == AdEventType.adFailedToLoad ||
              event.type == AdEventType.adFailedToShow)) {
        _cancelStream();
        _currentADNetworkIndex++;
        setState(() {});
      } else if (event.adNetwork == priorityAdNetwork &&
          event.adUnitType == AdUnitType.native &&
          (event.type == AdEventType.adShowed ||
              event.type == AdEventType.adLoaded)) {
        _cancelStream();
      }
    });
  }

  bool _isNativeIdAvailable(AdNetwork adNetwork) {
    final adIdManager = ApslAds.instance.adIdManager;
    return adIdManager.appAdIds.any(
      (adIds) =>
          adIds.adNetwork == adNetwork.name &&
          adIds.nativeId != null &&
          adIds.nativeId!.isNotEmpty,
    );
  }

  Widget _showNativeAd(AdNetwork priorityAdNetwork) {
    _subscribeToAdEvent(priorityAdNetwork);
    return ApslNativeAd(
      adNetwork: priorityAdNetwork,
      nativeTemplateStyle: widget.nativeTemplateStyle,
      templateType: widget.templateType,
    );
  }

  void _cancelStream() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}
