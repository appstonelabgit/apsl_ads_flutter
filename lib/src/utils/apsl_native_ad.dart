import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:flutter/material.dart';

class ApslNativeAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final NativeTemplateStyle? nativeTemplateStyle;
  final TemplateType? templateType;
  final Color? nativeAdBorderColor;
  final double? nativeAdBorderRadius;

  const ApslNativeAd({
    this.adNetwork = AdNetwork.admob,
    this.nativeTemplateStyle,
    this.templateType,
    this.nativeAdBorderColor,
    this.nativeAdBorderRadius,
    super.key,
  });

  @override
  State<ApslNativeAd> createState() => _ApslNativeAdState();
}

class _ApslNativeAdState extends State<ApslNativeAd> {
  ApslAdBase? _nativeAd;

  @override
  Widget build(BuildContext context) {
    return _nativeAd?.show() ??
        Container(
          height:
              (widget.templateType ?? TemplateType.small) == TemplateType.small
                  ? 90
                  : 200,
        );
  }

  @override
  void didUpdateWidget(covariant ApslNativeAd oldWidget) {
    super.didUpdateWidget(oldWidget);

    createNative();
    _nativeAd?.onNativeAdReadyForSetState = onNativeAdReadyForSetState;
  }

  void createNative() {
    _nativeAd = ApslAds.instance.createNative(
      adNetwork: widget.adNetwork,
      nativeTemplateStyle: widget.nativeTemplateStyle,
      templateType: widget.templateType,
      nativeAdBorderColor: widget.nativeAdBorderColor,
      nativeAdBorderRadius: widget.nativeAdBorderRadius,
    );
    _nativeAd?.load();
  }

  @override
  void initState() {
    super.initState();

    createNative();

    _nativeAd?.onAdLoaded = onNativeAdReadyForSetState;
  }

  @override
  void dispose() {
    super.dispose();
    _nativeAd?.dispose();
    _nativeAd = null;
  }

  void onNativeAdReadyForSetState(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Object? data, {
    String? errorMessage,
    String? rewardType,
    num? rewardAmount,
  }) {
    setState(() {});
  }
}
