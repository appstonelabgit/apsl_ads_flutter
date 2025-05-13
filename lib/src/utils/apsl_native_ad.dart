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
  late AdNetwork _currentNetwork;
  late TemplateType _currentTemplateType;

  @override
  void initState() {
    super.initState();
    _currentNetwork = widget.adNetwork;
    _currentTemplateType = widget.templateType ?? TemplateType.small;
    _initNative();
  }

  @override
  void didUpdateWidget(covariant ApslNativeAd oldWidget) {
    super.didUpdateWidget(oldWidget);

    final updatedTemplate = widget.templateType ?? TemplateType.small;

    if (widget.adNetwork != _currentNetwork ||
        updatedTemplate != _currentTemplateType) {
      _currentNetwork = widget.adNetwork;
      _currentTemplateType = updatedTemplate;
      _initNative();
    }
  }

  void _initNative() {
    _nativeAd?.dispose();

    _nativeAd = ApslAds.instance.createNative(
      adNetwork: _currentNetwork,
      nativeTemplateStyle: widget.nativeTemplateStyle,
      templateType: _currentTemplateType,
      nativeAdBorderColor: widget.nativeAdBorderColor,
      nativeAdBorderRadius: widget.nativeAdBorderRadius,
    );

    _nativeAd?.onAdLoaded = _onNativeAdReady;
    _nativeAd?.onNativeAdReadyForSetState = _onNativeAdReady;

    _nativeAd?.load();
  }

  void _onNativeAdReady(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Object? data, {
    String? errorMessage,
    String? rewardType,
    num? rewardAmount,
  }) {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _nativeAd?.show() ?? _fallbackContainer();
  }

  Widget _fallbackContainer() {
    final height = (_currentTemplateType == TemplateType.small) ? 90.0 : 200.0;
    return SizedBox(height: height);
  }
}
