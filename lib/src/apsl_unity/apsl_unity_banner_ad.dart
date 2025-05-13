import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class ApslUnityBannerAd extends ApslAdBase {
  final AdSize? adSize;

  ApslUnityBannerAd(
    super.adUnitId, {
    this.adSize,
  });

  bool _isAdLoaded = false;
  bool _isLoading = false;

  @override
  AdNetwork get adNetwork => AdNetwork.unity;

  @override
  AdUnitType get adUnitType => AdUnitType.banner;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  void dispose() {
    _isAdLoaded = false;
    _isLoading = false;
    // There's no explicit dispose for UnityBannerAd — it's widget based.
  }

  /// Unity doesn't expose a separate preload step for banners. This is a placeholder to maintain consistency.
  @override
  Future<void> load() async {
    if (_isAdLoaded || _isLoading) return;
    _isLoading = true;
    // Ad loads when the widget is built, so `show()` handles the actual loading.
  }

  @override
  Widget show() {
    final size = adSize == null
        ? BannerSize.standard
        : BannerSize(width: adSize!.width, height: adSize!.height);

    return Container(
      alignment: Alignment.center,
      height: size.height.toDouble(),
      child: UnityBannerAd(
        placementId: adUnitId,
        size: size,
        onLoad: _onBannerLoad,
        onFailed: _onBannerLoadFail,
        onClick: _onBannerClick,
      ),
    );
  }

  void _onBannerLoad(dynamic args) {
    _isAdLoaded = true;
    _isLoading = false;
    onAdLoaded?.call(adNetwork, adUnitType, args);
    onBannerAdReadyForSetState?.call(adNetwork, adUnitType, args);
    onAdShowed?.call(adNetwork, adUnitType, args);
  }

  void _onBannerLoadFail(
      String placementId, UnityAdsBannerError error, String errorMessage) {
    _isAdLoaded = false;
    _isLoading = false;
    onAdFailedToLoad?.call(
      adNetwork,
      adUnitType,
      error,
      errorMessage: 'Failed to load Unity banner [$placementId]: $errorMessage',
    );
  }

  void _onBannerClick(String placementId) {
    onAdClicked?.call(adNetwork, adUnitType, placementId);
  }
}
