import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

/// A class that encapsulates the logic for AdMob's App Open Ads.
class ApslAdmobAppOpenAd extends ApslAdBase {
  final AdRequest _adRequest;
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Maximum time duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Timestamp to keep track when the ad was loaded.
  DateTime? _appOpenLoadTime;

  ApslAdmobAppOpenAd(super.adUnitId, this._adRequest);

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  AdUnitType get adUnitType => AdUnitType.appOpen;

  @override
  bool get isAdLoaded => _appOpenAd != null;

  /// Disposes off any active ad to free up resources.
  @override
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }

  /// Initiates the loading of the ad.
  @override
  Future<void> load() => _load(showAdOnLoad: true);

  /// Internal method to load an ad. If [showAdOnLoad] is true, it will show the ad immediately after loading.
  Future<void> _load({bool showAdOnLoad = false}) {
    if (isAdLoaded) return Future.value();

    return AppOpenAd.load(
      adUnitId: adUnitId,
      request: _adRequest,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
          if (showAdOnLoad) show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _appOpenAd = null;
          onAdFailedToLoad?.call(adNetwork, adUnitType, error,
              errorMessage: error.toString());
        },
      ),
    );
  }

  /// Shows the loaded ad if it is ready and not expired.
  @override
  show() async {
    // Handle cases where the ad is not loaded, already being displayed, or has expired.
    if (!isAdLoaded) {
      // If no ad is loaded, initiate load and plan to show it.
      onAdFailedToShow?.call(adNetwork, adUnitType, null,
          errorMessage:
              'Tried to show ad but no ad was loaded, now sent a call for loading and will show automatically');
      _load(showAdOnLoad: true);
      return;
    }
    if (_isShowingAd) {
      onAdFailedToShow?.call(adNetwork, adUnitType, null,
          errorMessage: 'Tried to show ad while already showing an ad.');
      return;
    }
    if (_appOpenLoadTime != null &&
        DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      // If ad is expired, initiate load and plan to show it.
      onAdFailedToShow?.call(adNetwork, adUnitType, null,
          errorMessage:
              'Ad was loaded before $maxCacheDuration, hence sent a call for loading and will show automatically');
      _load(showAdOnLoad: true);
      return;
    }

    // Define the full screen content callbacks for the ad.
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
        onAdFailedToShow?.call(adNetwork, adUnitType, ad,
            errorMessage: error.toString());
        ad.dispose();
        _appOpenAd = null;
      },
    );

    // Display the ad.
    _appOpenAd?.show();
    _appOpenAd = null;
    _isShowingAd = false;
  }
}
