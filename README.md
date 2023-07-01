# Apsl Ads Flutter

**Show some 💙, 👍 the package & ⭐️ the repo to support the project**

To easily integrate ads from different ad networks into your flutter app.

## Features

- Google Mobile Ads (banner, appOpen, interstitial, rewarded ad, native ad)
- Facebook Audience Network (banner, interstitial, rewarded ad, native ad (coming soon))
- Unity Ads (banner, interstitial, rewarded ad)

## Admob Mediation
- This plugin supports admob mediation [See Details](https://developers.google.com/admob/flutter/mediation/get-started) to see Admob Mediation Guide.
- You just need to add the naative plaatform setting for admob mediation.

## Platform Specific Setup

### iOS

#### Update your Info.plist

* The key for Google Ads **are required** in Info.plist.

Update your app's `ios/Runner/Info.plist` file to add two keys:

```xml
<key>GADApplicationIdentifier</key>
<string>YOUR_SDK_KEY</string>
```

* You have to add `SKAdNetworkItems` for all networks provided by Apsl-ads-flutter [info.plist](https://github.com/nooralibutt/Apsl-ads/blob/master/example/ios/Runner/Info.plist) you can copy paste `SKAdNetworkItems` in  your own project.

### Android

#### Update AndroidManifest.xml

```xml
<manifest>
    <application>
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

import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TestAdIdManager extends IAdIdManager {
  const TestAdIdManager();

  @override
  AppAdIds? get admobAdIds => AppAdIds(
    appId: Platform.isAndroid
        ? 'ca-app-pub-3940256099942544~3347511713'
        : 'ca-app-pub-3940256099942544~1458002511',
    appOpenId: Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/3419835294'
        : 'ca-app-pub-3940256099942544/5662855259',
    bannerId: 'ca-app-pub-3940256099942544/6300978111',
    interstitialId: 'ca-app-pub-3940256099942544/1033173712',
    rewardedId: 'ca-app-pub-3940256099942544/5224354917',
  );

  @override
  AppAdIds? get unityAdIds => AppAdIds(
    appId: Platform.isAndroid ? '4374881' : '4374880',
    bannerId: Platform.isAndroid ? 'Banner_Android' : 'Banner_iOS',
    interstitialId:
    Platform.isAndroid ? 'Interstitial_Android' : 'Interstitial_iOS',
    rewardedId: Platform.isAndroid ? 'Rewarded_Android' : 'Rewarded_iOS',
  );

  @override
  AppAdIds? get fbAdIds => AppAdIds(
    appId: 'YOUR_APP_ID',
    interstitialId: 'VID_HD_16_9_15S_LINK#YOUR_PLACEMENT_ID',
    bannerId: 'IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID',
    rewardedId: 'VID_HD_16_9_46S_APP_INSTALL#YOUR_PLACEMENT_ID',
  );
}
```

## Initialize the SDK

Before loading ads, have your app initialize the Mobile Ads SDK by calling `ApslAds.instance.initialize()` which initializes the SDK and returns a `Future` that finishes once initialization is complete (or after a 30-second timeout). This needs to be done only once, ideally right before running the app.

```dart
import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:flutter/material.dart';

const IAdIdManager adIdManager = TestAdIdManager();

ApslAds.instance.initialize(
    adIdManager,
    adMobAdRequest: const AdRequest(),
    // To enable Facebook Test mode ads
    fbTestMode: true,
    admobConfiguration: RequestConfiguration(testDeviceIds: []),
  );
```

## Interstitial/Rewarded Ads

### Load an ad
Ad is automatically loaded after being displayed or first time when you call initialize.
But on safe side, you can call this method. This will load both rewarded and interstitial ads.
If a particular ad is already loaded, it will not load it again.
```dart
ApslAds.instance.loadAd();
```

### Show interstitial or rewarded ad
```dart
ApslAds.instance.showAd(AdUnitType.rewarded);
```

### Show random interstitial ad
```dart
ApslAds.instance.showRandomAd(AdUnitType.interstitial)
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

## Show Smart Banner Ad

Smart Banner will check one by one the priority ad networks provided by you, if any of the priority network failed to load by some reason then it will automatically jump and try to load the next one so we can prevent revenue loss. 

If you want to set the priority for Smart Banner, just pass the priorityAdNetworks in ApslSmartBannerAd constructor just like below.
Other wise it will set by default as [admob, facebook, unity] and default AdSize is AdSize.banner,

This is how you may show banner ad in widget-tree somewhere:

```dart
@override
Widget build(BuildContext context) {
  Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SomeWidget(),
      const Spacer(),
      const ApslSmartBannerAd(
        priorityAdNetworks: [
          AdNetwork.facebook,
          AdNetwork.admob,
          AdNetwork.unity,
        ],
        adSize: AdSize.largeBanner,
      ),
    ],
  );
}
```

## Listening to the callbacks
Declare this object in the class
```dart
  StreamSubscription? _streamSubscription;
```

We are showing InterstitialAd here and also checking if ad has been shown.
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
