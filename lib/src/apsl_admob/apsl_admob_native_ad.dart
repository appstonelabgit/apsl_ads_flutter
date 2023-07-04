import 'package:flutter/material.dart';

import '../../apsl_ads_flutter.dart';

class ApslAdmobNativeAd extends ApslAdBase {
  final AdRequest _adRequest;
  final NativeTemplateStyle _nativeTemplateStyle;
  final TemplateType _templateType;

  ApslAdmobNativeAd(
    String adUnitId, {
    AdRequest? adRequest,
    NativeTemplateStyle? nativeTemplateStyle,
    TemplateType? templateType,
  })  : _adRequest = adRequest ?? const AdRequest(),
        _templateType = templateType ?? TemplateType.medium,
        _nativeTemplateStyle = nativeTemplateStyle ??
            NativeTemplateStyle(
                templateType: templateType ?? TemplateType.medium),
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
      nativeTemplateStyle: _nativeTemplateStyle,
      request: _adRequest,
    )..load();
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
        minHeight: _templateType == TemplateType.small
            ? 90
            : 320, // minimum recommended height
        maxWidth: 400,
        maxHeight: _templateType == TemplateType.small
            ? 200
            : 400, // maximum recommended height
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
