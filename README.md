# Apsl Ads Flutter

Seamlessly integrate ads from multiple ad networks into your Flutter app using the `Apsl Ads Flutter` package. Monetize your Flutter applications effortlessly with our unified approach.

🌟 If this package benefits you, show your support by giving it a star on GitHub!

## 🚀 Features

- **Google Mobile Ads**:
  - Banner
  - AppOpen
  - Interstitial
  - Rewarded Ad
  - Native Ad
- **Facebook Audience Network**:
  - Banner
  - Interstitial
  - Rewarded Ad
  - *Native Ad (Coming Soon!)*
- **Unity Ads**:
  - Banner
  - Interstitial
  - Rewarded Ad

## 📱 AdMob Mediation

The plugin offers comprehensive AdMob mediation support. Delve deeper into mediation details:

- [AdMob Mediation Guide](https://developers.google.com/admob/flutter/mediation/get-started)
- Remember to configure the native platform settings for AdMob mediation.

## 🛠 Platform-Specific Setup

### iOS

#### 📝 Update your Info.plist

For both Google Ads and Applovin, certain keys are essential. Update your `ios/Runner/Info.plist`:

```xml

<key>GADApplicationIdentifier</key>
<string>YOUR_SDK_KEY</string>
```

Additionally, add `SKAdNetworkItems` for all networks provided by `Apsl-ads-flutter`. You can find and copy the `SKAdNetworkItems` from the provided [info.plist](https://github.com/appstonelabgit/apsl_ads_flutter/blob/main/example/ios/Runner/Info.plist) to your project.

### Android

#### 📝 Update AndroidManifest.xml

```xml
<manifest>
    <application>
        <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
    </application>
</manifest>
```

## 🧩 Initialize Ad IDs

This is how you can define and manage your ad IDs for different networks:

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
       
      ];
}

```

## 🚀 SDK Initialization

Before displaying ads, ensure you initialize the Mobile Ads SDK with `ApslAds.instance.initialize()`. It's a one-time setup, ideally done just before your app starts.

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

## 🎥 Interstitial/Rewarded Ads

### 🔋 Load an ad

By default, an ad loads after being displayed or when you call `initialize` for the first time.
As a precaution, use the following method to load both rewarded and interstitial ads:

```dart
ApslAds.instance.loadAd();
```

### 📺 Display Interstitial or Rewarded Ad

```dart
ApslAds.instance.showAd(AdUnitType.rewarded);
```

### 🎉 Display App Open Ad

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

## 🌐 Show All Banner Ads Sequentially

The banners will attempt to load ads from the networks in the sequence you specify. If one network fails, it will automatically switch to the next one, ensuring minimal revenue loss.

You can specify the order using the `orderOfAdNetworks` parameter in the `ApslAllBannerAd` constructor:

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

## 🔔 Callbacks

To monitor various ad events, use the callback mechanism:

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
