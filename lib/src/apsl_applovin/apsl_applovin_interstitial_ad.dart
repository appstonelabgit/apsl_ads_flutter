import 'package:applovin_max/applovin_max.dart';
import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

class ApslApplovinInterstitialAd extends ApslAdBase {
  ApslApplovinInterstitialAd(String adUnitId) : super(adUnitId);

  bool _isLoaded = false;

  @override
  AdNetwork get adNetwork => AdNetwork.appLovin;

  @override
  AdUnitType get adUnitType => AdUnitType.interstitial;

  @override
  void dispose() => _isLoaded = false;

  @override
  bool get isAdLoaded => _isLoaded;

  @override
  Future<void> load() async {
    if (_isLoaded) return;
    if (adUnitType == AdUnitType.interstitial) {
      AppLovinMAX.loadInterstitial(adUnitId);
      _isLoaded = await AppLovinMAX.isInterstitialReady(adUnitId) ?? false;
    }
    _onAppLovinAdListner();
  }

  @override
  show() {
    if (!_isLoaded) return;
    if (adUnitType == AdUnitType.interstitial) {
      AppLovinMAX.showInterstitial(adUnitId);
    }
    _isLoaded = false;
  }

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
