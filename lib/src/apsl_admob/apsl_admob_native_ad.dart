import 'package:flutter/material.dart';
import '../../apsl_ads_flutter.dart';

/// A class encapsulating the logic for AdMob's Native Ads.
class ApslAdmobNativeAd extends ApslAdBase {
  final AdRequest _adRequest;
  final NativeTemplateStyle? nativeTemplateStyle;
  final TemplateType _templateType;
  final bool useNativeTemplate = false;
  final Color? nativeAdBorderColor;
  final double? nativeAdBorderRadius;

  ApslAdmobNativeAd(
    super.adUnitId, {
    AdRequest? adRequest,
    this.nativeTemplateStyle,
    TemplateType? templateType,
    this.nativeAdBorderColor,
    this.nativeAdBorderRadius,
  })  : _adRequest = adRequest ?? const AdRequest(),
        _templateType = templateType ?? TemplateType.medium;

  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  AdUnitType get adUnitType => AdUnitType.native;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  void dispose() {
    _isAdLoaded = false;
    if (_nativeAd != null) {
      _nativeAd!.dispose();
      _nativeAd = null;
    }
  }

  /// Loads the native ad.
  @override
  Future<void> load() async {
    if (_nativeAd != null) {
      await _nativeAd!.dispose();
      _nativeAd = null;
    }
    _isAdLoaded = false;

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) async {
          // Optional short delay to ensure the ad view is fully ready
          await Future.delayed(const Duration(milliseconds: 300));
          _isAdLoaded = true;
          _nativeAd = ad as NativeAd?;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
          onNativeAdReadyForSetState?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (ad, error) {
          _isAdLoaded = false;
          _nativeAd = null;
          ad.dispose();
          onAdFailedToLoad?.call(
            adNetwork,
            adUnitType,
            ad,
            errorMessage: error.toString(),
          );

          // Retry after delay (basic backoff)
          Future.delayed(const Duration(seconds: 5), () {
            if (!_isAdLoaded) load();
          });
        },
      ),
      nativeTemplateStyle: nativeTemplateStyle ?? getTemplate(),
      request: _adRequest,
    )..load();
  }

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
  Widget show() {
    // If ad not ready, trigger load and show a placeholder
    if (_nativeAd == null || !_isAdLoaded) {
      load();
      return const SizedBox(); // Optional: Replace with shimmer or loader
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 320,
        maxWidth: 400,
        minHeight: _templateType == TemplateType.small ? 90 : 320,
        maxHeight: _templateType == TemplateType.small ? 200 : 400,
      ),
      child: Center(
        child: Stack(
          children: [
            if ((nativeAdBorderRadius ?? 0.0) > 0.0)
              ClipRRect(
                borderRadius: BorderRadius.circular(nativeAdBorderRadius!),
                child: AdWidget(ad: _nativeAd!),
              )
            else
              AdWidget(ad: _nativeAd!),
            if ((nativeAdBorderRadius ?? 0.0) > 0.0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(nativeAdBorderRadius!),
                    border: Border.all(
                      color: nativeAdBorderColor ?? Colors.transparent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
