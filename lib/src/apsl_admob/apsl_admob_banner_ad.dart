import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ApslAdmobBannerAd extends ApslAdBase {
  final AdRequest _adRequest;
  final AdSize adSize;

  ApslAdmobBannerAd(
    super.adUnitId, {
    AdRequest? adRequest,
    this.adSize = AdSize.banner,
  }) : _adRequest = adRequest ?? const AdRequest();

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  @override
  AdUnitType get adUnitType => AdUnitType.banner;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  void dispose() {
    _isAdLoaded = false;
    _isLoading = false;
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  @override
  Future<void> load() async {
    if (_isLoading || _isAdLoaded) return;

    _isLoading = true;
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;

    _bannerAd = BannerAd(
      size: adSize,
      adUnitId: adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerAd = ad as BannerAd;
          _isAdLoaded = true;
          _isLoading = false;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
          onBannerAdReadyForSetState?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _isAdLoaded = false;
          _isLoading = false;
          onAdFailedToLoad?.call(
            adNetwork,
            adUnitType,
            ad,
            errorMessage: error.toString(),
          );
          ad.dispose();

          // Retry after delay (for transient errors)
          Future.delayed(const Duration(seconds: 5), () {
            if (!_isAdLoaded) load();
          });
        },
        onAdOpened: (Ad ad) => onAdClicked?.call(adNetwork, adUnitType, ad),
        onAdClosed: (Ad ad) => onAdDismissed?.call(adNetwork, adUnitType, ad),
        onAdImpression: (Ad ad) => onAdShowed?.call(adNetwork, adUnitType, ad),
      ),
      request: _adRequest,
    )..load();
  }

  @override
  Widget show() {
    if (_bannerAd == null || !_isAdLoaded) {
      load();
      return SizedBox(
        height: adSize.height.toDouble(),
        width: adSize.width.toDouble(),
      );
    }

    return Container(
      alignment: Alignment.center,
      height: adSize.height.toDouble(),
      width: adSize.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
