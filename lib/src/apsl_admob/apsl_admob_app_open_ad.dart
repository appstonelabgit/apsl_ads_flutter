import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

class ApslAdmobAppOpenAd extends ApslAdBase {
  final AdRequest _adRequest;
  final int _orientation;

  ApslAdmobAppOpenAd(super.adUnitId, this._adRequest, this._orientation);
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  // Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  // Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  AdUnitType get adUnitType => AdUnitType.appOpen;

  @override
  bool get isAdLoaded => _appOpenAd != null;

  @override
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }

  @override
  Future<void> load() => _load();

  Future<void> _load({bool showAdOnLoad = false}) {
    if (isAdLoaded) return Future.value();

    return AppOpenAd.load(
      adUnitId: adUnitId,
      request: _adRequest,
      orientation: _orientation,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          onAdLoaded?.call(adNetwork, adUnitType, ad);

          if (showAdOnLoad) {
            show();
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          _appOpenAd = null;
          onAdFailedToLoad?.call(
              adNetwork, adUnitType, error, error.toString());
        },
      ),
    );
  }

  @override
  show() async {
    if (!isAdLoaded) {
      onAdFailedToShow?.call(adNetwork, adUnitType, null,
          'Tried to show ad but no ad was loaded, now sent a call for loading and will show automatically');
      _load(showAdOnLoad: true);
      return;
    }

    if (_isShowingAd) {
      onAdFailedToShow?.call(adNetwork, adUnitType, null,
          'Tried to show ad while already showing an ad.');
      return;
    }

    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      onAdFailedToShow?.call(adNetwork, adUnitType, null,
          'Add was loaded before $maxCacheDuration, thats why sent a call for loading and will show automatically');
      _load(showAdOnLoad: true);
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = true;
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = false;
        onAdDismissed?.call(adNetwork, adUnitType, ad);
        ad.dispose();
        _appOpenAd = null;
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        _isShowingAd = false;
        onAdFailedToShow?.call(adNetwork, adUnitType, ad, error.toString());
        ad.dispose();
        _appOpenAd = null;
      },
    );

    _appOpenAd?.show();
    _appOpenAd = null;
    _isShowingAd = false;
  }
}
