import 'dart:async';
import 'dart:io';

import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:flutter/material.dart';

import 'adlist_tile.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Using it to cancel the subscribed callbacks
  StreamSubscription? _streamSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Ads"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitleWidget(context, title: 'App Open'),
            AdListTile(
              networkName: 'Admob AppOpen',
              onTap: () => _showAd(AdNetwork.admob, AdUnitType.appOpen),
            ),
            const Divider(thickness: 2),
            _sectionTitleWidget(context, title: 'Interstitial'),
            AdListTile(
              networkName: 'Admob Interstitial',
              onTap: () => _showAd(AdNetwork.admob, AdUnitType.interstitial),
            ),
            AdListTile(
              networkName: 'Facebook Interstitial',
              onTap: () => _showAd(AdNetwork.facebook, AdUnitType.interstitial),
            ),
            AdListTile(
              networkName: 'Unity Interstitial',
              onTap: () => _showAd(AdNetwork.unity, AdUnitType.interstitial),
            ),
            AdListTile(
              networkName: 'Applovin Interstitial',
              onTap: () => _showAd(AdNetwork.appLovin, AdUnitType.interstitial),
            ),
            AdListTile(
              networkName: 'Available Interstitial',
              onTap: () => _showAvailableAd(AdUnitType.interstitial),
            ),
            const Divider(thickness: 2),
            _sectionTitleWidget(context, title: 'Rewarded'),
            AdListTile(
              networkName: 'Admob Rewarded',
              onTap: () => _showAd(AdNetwork.admob, AdUnitType.rewarded),
            ),
            AdListTile(
              networkName: 'Facebook Rewarded',
              onTap: () => _showAd(AdNetwork.facebook, AdUnitType.rewarded),
            ),
            AdListTile(
              networkName: 'Admob Rewarded',
              onTap: () => _showAd(AdNetwork.unity, AdUnitType.rewarded),
            ),
            AdListTile(
              networkName: 'Admob Rewarded',
              onTap: () => _showAd(AdNetwork.appLovin, AdUnitType.rewarded),
            ),
            AdListTile(
              networkName: 'Admob Rewarded',
              onTap: () => _showAvailableAd(AdUnitType.rewarded),
            ),
            const ApslSmartBannerAd(
              priorityAdNetworks: [
                AdNetwork.facebook,
                AdNetwork.admob,
                AdNetwork.unity,
                AdNetwork.appLovin,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitleWidget(BuildContext context, {String title = ""}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAd(AdNetwork adNetwork, AdUnitType adUnitType) {
    if (ApslAds.instance.showAd(adUnitType,
        adNetwork: adNetwork,
        shouldShowLoader: Platform.isAndroid,
        context: context,
        delayInSeconds: 1)) {
      // Canceling the last callback subscribed
      _streamSubscription?.cancel();
      // Listening to the callback from showRewardedAd()
      _streamSubscription = ApslAds.instance.onEvent.listen((event) {
        if (event.adUnitType == adUnitType) {
          _streamSubscription?.cancel();
          goToNextScreen(adNetwork: adNetwork);
        }
      });
    } else {
      goToNextScreen(adNetwork: adNetwork);
    }
  }

  void _showAvailableAd(AdUnitType adUnitType) {
    if (ApslAds.instance.showAd(adUnitType)) {
      // Canceling the last callback subscribed
      _streamSubscription?.cancel();
      // Listening to the callback from showRewardedAd()
      _streamSubscription = ApslAds.instance.onEvent.listen((event) {
        if (event.adUnitType == adUnitType) {
          _streamSubscription?.cancel();
          goToNextScreen();
        }
      });
    } else {
      goToNextScreen();
    }
  }

  void goToNextScreen({AdNetwork? adNetwork}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(adNetwork: adNetwork),
      ),
    );
  }
}
