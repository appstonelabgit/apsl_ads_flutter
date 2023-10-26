import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:easy_audience_network/ad/banner_ad.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as admob;

/// A wrapper class for the Facebook Audience Network Banner Ad within the `apsl_ads_flutter` package.
class ApslFacebookBannerAd extends ApslAdBase {
  /// The size of the AdMob ad.
  final admob.AdSize? adSize;

  ApslFacebookBannerAd(
    String adUnitId, {
    this.adSize = admob.AdSize.banner,
  }) : super(adUnitId);

  // Tracks the loaded state of the ad.
  bool _isAdLoaded = false;

  @override
  AdUnitType get adUnitType => AdUnitType.banner;

  @override
  AdNetwork get adNetwork => AdNetwork.facebook;

  @override
  void dispose() {
    _isAdLoaded = false;
  }

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  Future<void> load() async {}

  /// Displays the Facebook Banner ad wrapped in a container.
  @override
  dynamic show() {
    final bannerSize = adSize == null
        ? BannerSize.STANDARD
        : BannerSize(width: adSize!.width, height: adSize!.height);

    return Container(
      height: bannerSize.height.toDouble(),
      alignment: Alignment.center,
      child: BannerAd(
        placementId: adUnitId,
        bannerSize: bannerSize,
        listener: _onAdListener(),
      ),
    );
  }

  /// Handles the ad events like loading, clicking, and errors.
  BannerAdListener? _onAdListener() {
    return BannerAdListener(
      onLoggingImpression: () {},
      onLoaded: () {
        _isAdLoaded = true;
        onAdLoaded?.call(adNetwork, adUnitType, 'Loaded');
        onBannerAdReadyForSetState?.call(adNetwork, adUnitType, 'Loaded');
      },
      onClicked: () {
        onAdClicked?.call(adNetwork, adUnitType, 'Clicked');
      },
      onError: (code, value) {
        _isAdLoaded = false;
        onAdFailedToLoad?.call(adNetwork, adUnitType, null,
            errorMessage: 'Error occurred while loading $code $value ad');
      },
    );
  }
}
