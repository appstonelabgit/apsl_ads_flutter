import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

class ApslAdmobAppOpenAd extends ApslAdBase {
  final AdRequest adRequest;
  final Duration maxCacheDuration = const Duration(hours: 4);

  AppOpenAd? _appOpenAd;
  DateTime? _appOpenLoadTime;

  bool _isShowingAd = false;
  bool _isLoading = false;

  ApslAdmobAppOpenAd(super.adUnitId, this.adRequest);

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
    _isShowingAd = false;
    _isLoading = false;
  }

  @override
  Future<void> load() => _load(showAdOnLoad: true);

  Future<void> _load({bool showAdOnLoad = false}) async {
    if (isAdLoaded || forceStopToLoadAds || _isLoading) return;

    _isLoading = true;

    await AppOpenAd.load(
      adUnitId: adUnitId,
      request: adRequest,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd?.dispose();
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          _isLoading = false;
          onAdLoaded?.call(adNetwork, adUnitType, ad);

          if (showAdOnLoad) show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _appOpenAd = null;
          _isLoading = false;
          onAdFailedToLoad?.call(adNetwork, adUnitType, error,
              errorMessage: error.toString());

          // Retry after delay
          Future.delayed(const Duration(seconds: 10), () {
            if (!isAdLoaded) _load(showAdOnLoad: false);
          });
        },
      ),
    );
  }

  @override
  void show() {
    if (!isAdLoaded) {
      onAdFailedToShow?.call(
        adNetwork,
        adUnitType,
        null,
        errorMessage:
            'No ad loaded. Triggered load and will auto-show if successful.',
      );
      _load(showAdOnLoad: true);
      return;
    }

    if (_isShowingAd) {
      onAdFailedToShow?.call(
        adNetwork,
        adUnitType,
        null,
        errorMessage: 'Ad is already being shown.',
      );
      return;
    }

    if (_appOpenLoadTime != null &&
        DateTime.now().difference(_appOpenLoadTime!) > maxCacheDuration) {
      onAdFailedToShow?.call(
        adNetwork,
        adUnitType,
        null,
        errorMessage:
            'Cached ad expired. Loading new one and will show automatically.',
      );
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
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed?.call(adNetwork, adUnitType, ad);
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdFailedToShow?.call(
          adNetwork,
          adUnitType,
          ad,
          errorMessage: error.toString(),
        );
      },
    );

    _appOpenAd!.show();

    // Don't reset ad or _isShowingAd here — only inside callbacks
  }
}
