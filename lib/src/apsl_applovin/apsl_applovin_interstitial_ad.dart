import 'package:applovin_max/applovin_max.dart';
import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

/// A wrapper class for the AppLovin MAX Interstitial Ad within the `apsl_ads_flutter` package.
class ApslApplovinInterstitialAd extends ApslAdBase {
  ApslApplovinInterstitialAd(String adUnitId) : super(adUnitId);

  // Tracks the loaded state of the ad.
  bool _isLoaded = false;

  @override
  AdNetwork get adNetwork => AdNetwork.appLovin;

  @override
  AdUnitType get adUnitType => AdUnitType.interstitial;

  @override
  bool get isAdLoaded => _isLoaded;

  @override
  void dispose() => _isLoaded = false;

  /// Loads the interstitial ad, if not already loaded.
  @override
  Future<void> load() async {
    if (_isLoaded) return;

    if (adUnitType == AdUnitType.interstitial) {
      AppLovinMAX.loadInterstitial(adUnitId);
      _isLoaded = await AppLovinMAX.isInterstitialReady(adUnitId) ?? false;
    }
    // Set up the ad event listeners.
    _onAppLovinAdListner();
  }

  /// Displays the interstitial ad if it's loaded.
  @override
  show() {
    if (!_isLoaded) return;

    if (adUnitType == AdUnitType.interstitial) {
      AppLovinMAX.showInterstitial(adUnitId);
    }
    _isLoaded = false;
  }

  /// Initializes the interstitial ad event listeners.
  void _onAppLovinAdListner() {
    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (_) {
          _isLoaded = true;
          onAdLoaded?.call(adNetwork, adUnitType, null);
        },
        onAdLoadFailedCallback: (_, __) {
          _isLoaded = false;
          onAdFailedToLoad?.call(
            adNetwork,
            adUnitType,
            null,
            errorMessage: 'Error occurred while loading $adNetwork ad',
          );
        },
        onAdDisplayedCallback: (_) {
          onAdShowed?.call(adNetwork, adUnitType, null);
        },
        onAdDisplayFailedCallback: (_, __) {
          onAdFailedToShow?.call(
            adNetwork,
            adUnitType,
            null,
            errorMessage: 'Error occurred while showing $adNetwork ad',
          );
        },
        onAdClickedCallback: (_) {
          onAdClicked?.call(adNetwork, adUnitType, null);
        },
        onAdHiddenCallback: (_) {
          onAdDismissed?.call(adNetwork, adUnitType, null);
        },
      ),
    );
  }
}
