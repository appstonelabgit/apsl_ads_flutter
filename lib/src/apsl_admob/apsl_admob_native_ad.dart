import 'package:flutter/material.dart';

import '../../apsl_ads_flutter.dart';

class ApslAdmobNativeAd extends ApslAdBase {
  final AdRequest _adRequest;
  final NativeTemplateStyle? nativeTemplateStyle;
  final TemplateType _templateType;

  ApslAdmobNativeAd(
    String adUnitId, {
    AdRequest? adRequest,
    this.nativeTemplateStyle,
    TemplateType? templateType,
  })  : _adRequest = adRequest ?? const AdRequest(),
        _templateType = templateType ?? TemplateType.medium,
        super(adUnitId);

  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  AdUnitType get adUnitType => AdUnitType.native;
  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  void dispose() {
    _isAdLoaded = false;
    _nativeAd?.dispose();
    _nativeAd = null;
  }

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  Future<void> load() async {
    await _nativeAd?.dispose();
    _nativeAd = null;
    _isAdLoaded = false;

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isAdLoaded = true;
          _nativeAd = ad as NativeAd?;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
          onNativeAdReadyForSetState?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (ad, error) {
          _isAdLoaded = false;
          _nativeAd = null;
          onAdFailedToLoad?.call(adNetwork, adUnitType, ad, error.toString());
          ad.dispose();
        },
      ),
      nativeTemplateStyle: nativeTemplateStyle ?? getTemplate(),
      request: _adRequest,
    )..load();
  }

  NativeTemplateStyle getTemplate() {
    return NativeTemplateStyle(
      // Required: Choose a template.
      templateType: _templateType,
      // Optional: Customize the ad's style.
      mainBackgroundColor: Colors.blue.withOpacity(0.1),
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
        // backgroundColor: Colors.white,
        style: NativeTemplateFontStyle.bold,
        size: 16.0,
      ),
      tertiaryTextStyle: NativeTemplateTextStyle(
        textColor: Colors.brown,
        backgroundColor: Colors.amber,
        style: NativeTemplateFontStyle.normal,
        size: 16.0,
      ),
    );
  }

  @override
  show() {
    if (_nativeAd == null && !_isAdLoaded) {
      load();
      return const SizedBox();
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 320,
        // minimum recommended height
        minHeight: _templateType == TemplateType.small ? 90 : 320,
        maxWidth: 400,
        // maximum recommended height
        maxHeight: _templateType == TemplateType.small ? 200 : 400,
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
