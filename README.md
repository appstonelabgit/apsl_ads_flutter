# Apsl Ads Flutter

**Please show some ❤️ to the package, give it a 👍, and ⭐️ the repo to support the project!**

Simplify the integration of ads from various ad networks into your Flutter app effortlessly.

## Features

- Google Mobile Ads (banner, appOpen, interstitial, rewarded ad, native ad)
- Facebook Audience Network (banner, interstitial, rewarded ad, native ad (coming soon))
- Unity Ads (banner, interstitial, rewarded ad)

## Admob Mediation
- This plugin offers support for AdMob mediation. [See Details](https://developers.google.com/admob/flutter/mediation/get-started) for the AdMob Mediation Guide.
- Simply add the native platform settings for AdMob mediation.

## Platform Specific Setup

### iOS

#### Update your Info.plist

* The key for Google Ads and Applovin **are required** in Info.plist.

Update your app's `ios/Runner/Info.plist` file to add two keys:

```xml
<key>AppLovinSdkKey</key>
<string>YOUR_SDK_KEY</string>
<key>GADApplicationIdentifier</key>
<string>YOUR_SDK_KEY</string>
```

* You have to add `SKAdNetworkItems` for all networks provided by Apsl-ads-flutter [info.plist](https://github.com/appstonelabgit/apsl_ads_flutter/blob/main/example/ios/Runner/Info.plist) you can copy paste `SKAdNetworkItems` in  your own project.

### Android

#### Update AndroidManifest.xml

```xml
<manifest>
    <application>
        <meta-data android:name="applovin.sdk.key"
            android:value="YOUR_SDK_KEY"/>
        <!-- Sample AdMob App ID: ca-app-pub-3940256099942544~3347511713 -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
    </application>
</manifest>
```

## Initialize Ad Ids

```dart
import 'dart:io';

import 'ads_id_manager.dart';

class TestAdsIdManager extends AdsIdManager {
  const TestAdsIdManager();

  @override
  List<AppAdIds> get appAdIds => [
        AppAdIds(
          adNetwork: 'admob',
          appId: Platform.isAndroid
              ? 'ca-app-pub-3940256099942544~3347511713'
              : 'ca-app-pub-3940256099942544~1458002511',
          appOpenId: Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/3419835294'
              : 'ca-app-pub-3940256099942544/5662855259',
          bannerId: Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/6300978111'
              : 'ca-app-pub-3940256099942544/2934735716',
          interstitialId: Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/1033173712'
              : 'ca-app-pub-3940256099942544/4411468910',
          rewardedId: Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/5224354917'
              : 'ca-app-pub-3940256099942544/1712485313',
          nativeId: Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/2247696110'
              : 'ca-app-pub-3940256099942544/3986624511',
        ),
        AppAdIds(
          adNetwork: 'unity',
          appId: Platform.isAndroid ? '4374881' : '4374880',
          bannerId: Platform.isAndroid ? 'Banner_Android' : 'Banner_iOS',
          interstitialId:
              Platform.isAndroid ? 'Interstitial_Android' : 'Interstitial_iOS',
          rewardedId: Platform.isAndroid ? 'Rewarded_Android' : 'Rewarded_iOS',
        ),
        const AppAdIds(
          adNetwork: 'facebook',
          appId: '1579706379118402',
          interstitialId: 'VID_HD_16_9_15S_LINK#YOUR_PLACEMENT_ID',
          bannerId: 'IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID',
          rewardedId: 'VID_HD_16_9_46S_APP_INSTALL#YOUR_PLACEMENT_ID',
        ),
        AppAdIds(
          adNetwork: 'applovin',
          appId: 'YOUR_SDK_KEY',
          bannerId: Platform.isAndroid
              ? 'ANDROID_BANNER_AD_UNIT_ID'
              : 'IOS_BANNER_AD_UNIT_ID',
          interstitialId: Platform.isAndroid
              ? 'ANDROID_INTER_AD_UNIT_ID'
              : 'IOS_INTER_AD_UNIT_ID',
          rewardedId: Platform.isAndroid
              ? 'ANDROID_REWARDED_AD_UNIT_ID'
              : 'IOS_REWARDED_AD_UNIT_ID',
        ),
      ];
}

```

## Initialize the SDK

Before you start showing ads in your app, make sure to initialize the Mobile Ads SDK by calling `ApslAds.instance.initialize()`. This will initialize the SDK and return a `Future` that completes when the initialization is done (or after a 30-second timeout). You only need to do this once, preferably right before running your app.

```dart
import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:flutter/material.dart';

const IAdIdManager adIdManager = TestAdIdManager();

ApslAds.instance.initialize(
    adIdManager,
    adMobAdRequest: const AdRequest(),
    // Set this to true if you want to restrict ads for applovin (age below 16 years)
    isAgeRestrictedUserForApplovin:true,
    // To enable Facebook Test mode ads
    fbTestMode: true,
    admobConfiguration: RequestConfiguration(testDeviceIds: []),
  );
```

## Interstitial/Rewarded Ads

### Load an ad
Ad is automatically loaded after being displayed or first time when you call initialize.
As a safety measure, you can call this method to load both rewarded and interstitial ads.
If an ad is already loaded, it won't load again.
```dart
ApslAds.instance.loadAd();
```

### Show interstitial or rewarded ad
```dart
ApslAds.instance.showAd(AdUnitType.rewarded);
```

### Show appOpen ad
```dart
ApslAds.instance.showAd(AdUnitType.appOpen)
```

## Show Banner Ads

This is how you may show banner ad in widget-tree somewhere:

```dart
@override
Widget build(BuildContext context) {
  Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SomeWidget(),
      const Spacer(),
      ApslBannerAd(
          adNetwork: AdNetwork.admob, adSize: AdSize.mediumRectangle),
    ],
  );
}
```

## Show All Banner Ad one by one

Banners will attempt to load ad networks in the order you provided. If a network fails to load for any reason, it will automatically move on to the next one to prevent revenue loss.

To set the order for All Banner, simply pass the `orderOfAdNetworks` parameter in the `ApslAllBannerAd` constructor like this:

Other wise it will set by default as [admob, facebook, unity] and default AdSize is AdSize.banner,

This is how you may show banner ad in widget-tree somewhere:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('My App'),
    ),
    body: Column(
      children: [
        // Your other widgets...
        ApslAllBannerAd(
          orderOfAdNetworks: [
            AdNetwork.facebook,
            AdNetwork.admob,
            AdNetwork.unity,
            AdNetwork.applovin,
          ],
          adSize: AdSize.largeBanner,
          // Other parameters...
        ),
        // Your other widgets...
      ],
    ),
  );
}
```

## Listening to the callbacks
Declare this object in the class
```dart
  StreamSubscription? _streamSubscription;
```

The following code snippet demonstrates the process of displaying an interstitial ad and checking if it has been shown:
If `true`, we are canceling the subscribed callbacks, if any.
Then, we are listening to the Stream and accessing the particular event we need
```dart
if (ApslAds.instance.showInterstitialAd()) {
  // Canceling the last callback subscribed
  _streamSubscription?.cancel();
  // Listening to the callback from showInterstitialAd()
  _streamSubscription =
  ApslAds.instance.onEvent.listen((event) {
    if (event.adUnitType == AdUnitType.interstitial &&
        event.type == AdEventType.adDismissed) {
      _streamSubscription?.cancel();
      goToNextScreen(countryList[index]);
    }
  });
}
```
