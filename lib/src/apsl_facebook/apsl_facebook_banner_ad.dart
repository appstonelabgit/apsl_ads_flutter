import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:easy_audience_network/ad/banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as admob;

/// A wrapper class for Facebook Audience Network Banner Ads.
class ApslFacebookBannerAd extends ApslAdBase {
  final admob.AdSize? adSize;

  ApslFacebookBannerAd(
    super.adUnitId, {
    this.adSize = admob.AdSize.banner,
  });

  bool _isAdLoaded = false;
  bool _isLoading = false;

  BannerAd? _currentBannerAd;
  BannerSize get _bannerSize => adSize == null
      ? BannerSize.STANDARD
      : BannerSize(width: adSize!.width, height: adSize!.height);

  @override
  AdUnitType get adUnitType => AdUnitType.banner;

  @override
  AdNetwork get adNetwork => AdNetwork.facebook;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  void dispose() {
    _isAdLoaded = false;
    _isLoading = false;
    _currentBannerAd = null;
  }

  /// Preloads the ad by assigning it to `_currentBannerAd`
  @override
  Future<void> load() async {
    if (_isAdLoaded || _isLoading) return;

    _isLoading = true;

    _currentBannerAd = BannerAd(
      placementId: adUnitId,
      bannerSize: _bannerSize,
      listener: _onAdListener(),
    );

    // Note: `BannerAd` doesn't require `load()` like AdMob's version
    // It builds itself during widget build, so we just create and track state
  }

  @override
  Widget show() {
    // Show placeholder if ad isn't loaded
    if (!_isAdLoaded) {
      load();
      return SizedBox(
        height: _bannerSize.height.toDouble(),
        width: _bannerSize.width.toDouble(),
      );
    }

    return Container(
      height: _bannerSize.height.toDouble(),
      alignment: Alignment.center,
      child: _currentBannerAd ??
          BannerAd(
            placementId: adUnitId,
            bannerSize: _bannerSize,
            listener: _onAdListener(),
          ),
    );
  }

  /// Listener for ad events
  BannerAdListener _onAdListener() {
    return BannerAdListener(
      onLoaded: () {
        _isAdLoaded = true;
        _isLoading = false;
        onAdLoaded?.call(adNetwork, adUnitType, 'Loaded');
        onBannerAdReadyForSetState?.call(adNetwork, adUnitType, 'Loaded');
      },
      onClicked: () {
        onAdClicked?.call(adNetwork, adUnitType, 'Clicked');
      },
      onError: (code, message) {
        _isAdLoaded = false;
        _isLoading = false;
        onAdFailedToLoad?.call(
          adNetwork,
          adUnitType,
          null,
          errorMessage: 'Error occurred while loading $code $message',
        );

        // Retry after a delay
        Future.delayed(const Duration(seconds: 5), () {
          if (!_isAdLoaded) load();
        });
      },
      onLoggingImpression: () {},
    );
  }
}
