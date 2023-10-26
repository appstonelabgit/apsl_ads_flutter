import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A class that encapsulates the logic for AdMob's Banner Ads.
class ApslAdmobBannerAd extends ApslAdBase {
  final AdRequest _adRequest;
  final AdSize adSize; // Size of the banner ad to be displayed

  /// Constructs an instance of ApslAdmobBannerAd.
  ///
  /// [adUnitId] is the ad unit identifier provided by AdMob.
  /// [adRequest] is an optional request object, defaulting to `AdRequest`.
  /// [adSize] is the desired size of the banner, defaulting to standard banner size.
  ApslAdmobBannerAd(
    String adUnitId, {
    AdRequest? adRequest,
    this.adSize = AdSize.banner,
  })  : _adRequest = adRequest ?? const AdRequest(),
        super(adUnitId);

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  AdUnitType get adUnitType => AdUnitType.banner;
  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  /// Disposes the banner ad to release any resources.
  @override
  void dispose() {
    _isAdLoaded = false;
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  @override
  bool get isAdLoaded => _isAdLoaded;

  /// Loads the banner ad.
  @override
  Future<void> load() async {
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;

    // Initializing the BannerAd with appropriate parameters.
    _bannerAd = BannerAd(
      size: adSize,
      adUnitId: adUnitId,
      listener: BannerAdListener(
        // Handling various ad events.
        onAdLoaded: (Ad ad) {
          _bannerAd = ad as BannerAd?;
          _isAdLoaded = true;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
          onBannerAdReadyForSetState?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _bannerAd = null;
          _isAdLoaded = false;
          onAdFailedToLoad?.call(
            adNetwork,
            adUnitType,
            ad,
            errorMessage: error.toString(),
          );
          ad.dispose();
        },
        onAdOpened: (Ad ad) => onAdClicked?.call(adNetwork, adUnitType, ad),
        onAdClosed: (Ad ad) => onAdDismissed?.call(adNetwork, adUnitType, ad),
        onAdImpression: (Ad ad) => onAdShowed?.call(adNetwork, adUnitType, ad),
      ),
      request: _adRequest,
    )..load();
  }

  /// Shows the loaded banner ad if available.
  ///
  /// Returns a widget that can be embedded in the UI.
  @override
  dynamic show() {
    // If the ad isn't loaded yet, initiate load and provide a placeholder.
    if (_bannerAd == null || !_isAdLoaded) {
      load();
      return SizedBox(
        height: adSize.height.toDouble(),
        width: adSize.width.toDouble(),
      );
    }

    // Return the banner ad widget.
    return Container(
      alignment: Alignment.center,
      height: adSize.height.toDouble(),
      width: adSize.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
