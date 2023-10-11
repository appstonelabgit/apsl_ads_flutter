import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:apsl_ads_flutter/src/utils/badged_banner.dart';
import 'package:flutter/material.dart';

class ApslBannerAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final AdSize adSize;
  const ApslBannerAd({
    this.adNetwork = AdNetwork.admob,
    this.adSize = AdSize.banner,
    Key? key,
  }) : super(key: key);

  @override
  State<ApslBannerAd> createState() => _ApslBannerAdState();
}

class _ApslBannerAdState extends State<ApslBannerAd> {
  ApslAdBase? _bannerAd;

  @override
  Widget build(BuildContext context) {
    if (ApslAds.instance.showAdBadge) {
      return BadgedBanner(child: _bannerAd?.show(), adSize: widget.adSize);
    }

    return _bannerAd?.show() ??
        Container(height: widget.adSize.height.toDouble());
  }

  @override
  void didUpdateWidget(covariant ApslBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);

    createBanner();
    _bannerAd?.onBannerAdReadyForSetState = onBannerAdReadyForSetState;
  }

  void createBanner() {
    _bannerAd = ApslAds.instance
        .createBanner(adNetwork: widget.adNetwork, adSize: widget.adSize);
    _bannerAd?.load();
  }

  @override
  void initState() {
    super.initState();

    createBanner();

    _bannerAd?.onAdLoaded = onBannerAdReadyForSetState;
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  void onBannerAdReadyForSetState(
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
