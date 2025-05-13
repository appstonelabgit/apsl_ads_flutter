import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:apsl_ads_flutter/src/utils/badged_banner.dart';
import 'package:flutter/material.dart';

class ApslBannerAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final AdSize adSize;

  const ApslBannerAd({
    this.adNetwork = AdNetwork.admob,
    this.adSize = AdSize.banner,
    super.key,
  });

  @override
  State<ApslBannerAd> createState() => _ApslBannerAdState();
}

class _ApslBannerAdState extends State<ApslBannerAd> {
  ApslAdBase? _bannerAd;
  late AdNetwork _currentNetwork;
  late AdSize _currentSize;

  @override
  void initState() {
    super.initState();
    _currentNetwork = widget.adNetwork;
    _currentSize = widget.adSize;
    _initBanner();
  }

  @override
  void didUpdateWidget(covariant ApslBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.adNetwork != _currentNetwork || widget.adSize != _currentSize) {
      _currentNetwork = widget.adNetwork;
      _currentSize = widget.adSize;
      _initBanner();
    }
  }

  void _initBanner() {
    _bannerAd?.dispose();
    _bannerAd = ApslAds.instance.createBanner(
      adNetwork: _currentNetwork,
      adSize: _currentSize,
    );

    _bannerAd?.onAdLoaded = _onBannerAdReady;
    _bannerAd?.onBannerAdReadyForSetState = _onBannerAdReady;

    _bannerAd?.load();
  }

  void _onBannerAdReady(
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
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adWidget = _bannerAd?.show();

    if (ApslAds.instance.showAdBadge) {
      return BadgedBanner(child: adWidget, adSize: widget.adSize);
    }

    return adWidget ??
        SizedBox(
            height: widget.adSize.height.toDouble()); // Prevent layout shift
  }
}
