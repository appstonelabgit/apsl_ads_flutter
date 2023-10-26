import 'package:applovin_max/applovin_max.dart';
import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

/// A class encapsulating the logic for AppLovin MAX's Banner Ads.
class ApslApplovinBannerAd extends ApslAdBase {
  ApslApplovinBannerAd(String adUnitId) : super(adUnitId);

  bool _isLoaded = false; // Flag to check if the banner ad has been loaded

  // Overridden getters
  @override
  AdNetwork get adNetwork => AdNetwork.appLovin;
  @override
  AdUnitType get adUnitType => AdUnitType.banner;
  @override
  bool get isAdLoaded => _isLoaded;

  /// Updates the state of the ad to not loaded when disposed.
  @override
  void dispose() => _isLoaded = false;

  /// Currently, this method does not seem to have a load implementation.
  @override
  Future<void> load() async {}

  /// Shows or initializes the MaxAdView which is AppLovin's banner ad view.
  @override
  show() {
    return MaxAdView(
      adUnitId: adUnitId,
      adFormat: AdFormat.banner,
      customData: 'EasyApplovinBannerAd',
      listener: AdViewAdListener(
        onAdLoadedCallback: (ad) {
          _isLoaded = true;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
          onBannerAdReadyForSetState?.call(adNetwork, adUnitType, ad);
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          _isLoaded = false;
          onAdFailedToLoad?.call(
            adNetwork,
            adUnitType,
            null,
            errorMessage:
                'Error occurred while loading $adNetwork ad with ${error.code.toString()} and message:  ${error.message}',
          );
        },
        onAdClickedCallback: (_) {
          onAdClicked?.call(adNetwork, adUnitType, null);
        },
        onAdExpandedCallback: (ad) {
          onAdShowed?.call(adNetwork, adUnitType, ad);
        },
        onAdCollapsedCallback: (ad) {
          onAdDismissed?.call(adNetwork, adUnitType, ad);
        },
      ),
    );
  }
}
