import 'package:apsl_ads_flutter/src/apsl_ad_base.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A class that encapsulates the logic for AdMob's Interstitial Ads.
class ApslAdmobInterstitialAd extends ApslAdBase {
  final AdRequest _adRequest; // Ad request object
  final bool
      _immersiveModeEnabled; // To decide if immersive mode should be enabled for the ad

  /// Constructor for creating an instance of ApslAdmobInterstitialAd.
  ApslAdmobInterstitialAd(
    String adUnitId,
    this._adRequest,
    this._immersiveModeEnabled,
  ) : super(adUnitId);

  InterstitialAd? _interstitialAd; // Reference to the loaded interstitial ad
  bool _isAdLoaded = false; // Flag to check if the ad has been loaded

  // Overridden getters
  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  AdUnitType get adUnitType => AdUnitType.interstitial;

  @override
  bool get isAdLoaded => _isAdLoaded;

  /// Disposes the interstitial ad to release any resources.
  @override
  void dispose() {
    _isAdLoaded = false;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  /// Loads the interstitial ad.
  @override
  Future<void> load() async {
    if (_isAdLoaded)
      return; // If the ad is already loaded, don't attempt to reload

    // Load the interstitial ad
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: _adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        // Callbacks to handle ad events
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isAdLoaded = false;
          onAdFailedToLoad?.call(
            adNetwork,
            adUnitType,
            error,
            errorMessage: error.toString(),
          );
        },
      ),
    );
  }

  /// Show the loaded interstitial ad.
  @override
  show() {
    final ad = _interstitialAd;
    if (ad == null) return; // If ad isn't loaded, exit

    // Set the full-screen content callback for handling ad events
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        onAdDismissed?.call(adNetwork, adUnitType, ad);
        ad.dispose();
        load(); // Reload the ad after it's dismissed
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        onAdFailedToShow?.call(
          adNetwork,
          adUnitType,
          ad,
          errorMessage: error.toString(),
        );
        ad.dispose();
        load(); // Attempt to reload the ad if failed to show
      },
    );

    // Set immersive mode based on the flag and show the ad
    ad.setImmersiveMode(_immersiveModeEnabled);
    ad.show();

    _interstitialAd = null;
    _isAdLoaded = false; // Reset the loaded flag and reference after showing
  }
}
