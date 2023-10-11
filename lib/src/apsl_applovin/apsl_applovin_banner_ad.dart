import 'package:applovin_max/applovin_max.dart';
import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

class ApslApplovinBannerAd extends ApslAdBase {
  ApslApplovinBannerAd(String adUnitId) : super(adUnitId);

  bool _isLoaded = false;

  @override
  AdNetwork get adNetwork => AdNetwork.appLovin;

  @override
  AdUnitType get adUnitType => AdUnitType.banner;

  @override
  void dispose() => _isLoaded = false;

  @override
  bool get isAdLoaded => _isLoaded;

  @override
  Future<void> load() async {}

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
