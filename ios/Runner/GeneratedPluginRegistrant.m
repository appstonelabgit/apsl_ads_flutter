//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<easy_audience_network/FacebookAudienceNetworkPlugin.h>)
#import <easy_audience_network/FacebookAudienceNetworkPlugin.h>
#else
@import easy_audience_network;
#endif

#if __has_include(<google_mobile_ads/FLTGoogleMobileAdsPlugin.h>)
#import <google_mobile_ads/FLTGoogleMobileAdsPlugin.h>
#else
@import google_mobile_ads;
#endif

#if __has_include(<unity_ads_plugin/UnityAdsPlugin.h>)
#import <unity_ads_plugin/UnityAdsPlugin.h>
#else
@import unity_ads_plugin;
#endif

#if __has_include(<webview_flutter_wkwebview/FLTWebViewFlutterPlugin.h>)
#import <webview_flutter_wkwebview/FLTWebViewFlutterPlugin.h>
#else
@import webview_flutter_wkwebview;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FacebookAudienceNetworkPlugin registerWithRegistrar:[registry registrarForPlugin:@"FacebookAudienceNetworkPlugin"]];
  [FLTGoogleMobileAdsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleMobileAdsPlugin"]];
  [UnityAdsPlugin registerWithRegistrar:[registry registrarForPlugin:@"UnityAdsPlugin"]];
  [FLTWebViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTWebViewFlutterPlugin"]];
}

@end
