import 'package:flutter/material.dart';
import '../../apsl_ads_flutter.dart';

/// A class encapsulating the logic for AdMob's Native Ads.
class ApslAdmobNativeAd extends ApslAdBase {
  final AdRequest _adRequest;
  final NativeTemplateStyle? nativeTemplateStyle;
  final TemplateType _templateType;
  final bool useNativeTemplate = false;

  /// Constructor for creating an instance of ApslAdmobNativeAd.
  ApslAdmobNativeAd(
    super.adUnitId, {
    AdRequest? adRequest,
    this.nativeTemplateStyle,
    TemplateType? templateType,
  })  : _adRequest = adRequest ?? const AdRequest(),
        _templateType = templateType ?? TemplateType.medium;

  NativeAd? _nativeAd; // Reference to the loaded native ad
  bool _isAdLoaded = false; // Flag to check if the ad has been loaded

  // Overridden getters
  @override
  AdUnitType get adUnitType => AdUnitType.native;
  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  /// Disposes the native ad to release any resources.
  @override
  void dispose() {
    _isAdLoaded = false;
    _nativeAd?.dispose();
    _nativeAd = null;
  }

  @override
  bool get isAdLoaded => _isAdLoaded;

  /// Loads the native ad.
  @override
  Future<void> load() async {
    await _nativeAd?.dispose();
    _nativeAd = null;
    _isAdLoaded = false;

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      listener: NativeAdListener(
        // Callbacks to handle ad events
        onAdLoaded: (ad) {
          _isAdLoaded = true;
          _nativeAd = ad as NativeAd?;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
          onNativeAdReadyForSetState?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (ad, error) {
          _isAdLoaded = false;
          _nativeAd = null;
          onAdFailedToLoad?.call(
            adNetwork,
            adUnitType,
            ad,
            errorMessage: error.toString(),
          );
          ad.dispose();
        },
      ),
      nativeTemplateStyle: nativeTemplateStyle ?? getTemplate(),
      request: _adRequest,
    )..load();
  }

  /// Provides a default template style for the ad.
  NativeTemplateStyle getTemplate() {
    return NativeTemplateStyle(
      templateType: _templateType,
      mainBackgroundColor: Colors.transparent,
      cornerRadius: 10.0,
      callToActionTextStyle: NativeTemplateTextStyle(
        textColor: Colors.white,
        backgroundColor: Colors.blue,
        style: NativeTemplateFontStyle.normal,
        size: 16.0,
      ),
      primaryTextStyle: NativeTemplateTextStyle(
        textColor: Colors.blue,
        style: NativeTemplateFontStyle.normal,
        size: 16.0,
      ),
      secondaryTextStyle: NativeTemplateTextStyle(
        textColor: Colors.black,
        style: NativeTemplateFontStyle.bold,
        size: 16.0,
      ),
      tertiaryTextStyle: NativeTemplateTextStyle(
        textColor: Colors.brown,
        backgroundColor: Colors.transparent,
        style: NativeTemplateFontStyle.normal,
        size: 16.0,
      ),
    );
  }

  /// Displays the loaded native ad.
  @override
  show() {
    if (_nativeAd == null && !_isAdLoaded) {
      load();
      return const SizedBox();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 320,
        maxWidth: 400,
        minHeight: _templateType == TemplateType.small ? 90 : 320,
        maxHeight: _templateType == TemplateType.small ? 200 : 400,
      ),
      child: Center(child: AdWidget(ad: _nativeAd!)),
    );
  }
}
