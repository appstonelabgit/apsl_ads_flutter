import 'package:apsl_ads_flutter/src/apsl_admob/apsl_admob_native_ad.dart';
import 'package:apsl_ads_flutter/src/apsl_facebook/apsl_facebook_banner_ad.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

void main() {
  group('ApslAds', () {
    test('instance is singleton', () {
      expect(ApslAds.instance, equals(ApslAds.instance));
    });

    test('initialize sets correct properties', () async {
      const testManager = TestAdsIdManager();
      await ApslAds.instance.initialize(
        testManager,
        unityTestMode: true,
        fbTestMode: true,
        showAdBadge: true,
      );

      // Verify initialization properties
      expect(ApslAds.instance.showAdBadge, isTrue);
    });

    test('createBanner returns correct ad type for each network', () {
      // Test AdMob banner
      final admobBanner = ApslAds.instance.createBanner(
        adNetwork: AdNetwork.admob,
        adSize: AdSize.banner,
      );
      expect(admobBanner, isA<ApslAdmobBannerAd>());

      // Test Unity banner
      final unityBanner = ApslAds.instance.createBanner(
        adNetwork: AdNetwork.unity,
        adSize: AdSize.banner,
      );
      expect(unityBanner, isA<ApslUnityBannerAd>());

      // Test Facebook banner
      final facebookBanner = ApslAds.instance.createBanner(
        adNetwork: AdNetwork.facebook,
        adSize: AdSize.banner,
      );
      expect(facebookBanner, isA<ApslFacebookBannerAd>());
    });

    test('createNative returns correct ad type for AdMob', () {
      final nativeAd = ApslAds.instance.createNative(
        adNetwork: AdNetwork.admob,
        templateType: TemplateType.medium,
      );
      expect(nativeAd, isA<ApslAdmobNativeAd>());
    });
  });
}
