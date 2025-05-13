import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

abstract class AdsIdManager {
  const AdsIdManager();

  List<AppAdIds> get appAdIds;

  /// Returns ad IDs for a given network, or throws if not found.
  AppAdIds getAppIds(AdNetwork adNetwork) {
    return appAdIds.firstWhere(
      (element) => element.adNetwork == adNetwork,
      orElse: () =>
          throw Exception('AdNetwork ${adNetwork.name} not configured'),
    );
  }
}

class AppAdIds {
  /// Always pass appId, if adnetwork doesn't require app id, pass an empty string
  final String appId;

  final String? appOpenId;
  final String? interstitialId;
  final String? rewardedId;
  final String? bannerId;
  final String? nativeId;

  /// Strongly typed enum for ad network
  final AdNetwork adNetwork;

  const AppAdIds({
    required this.appId,
    required this.adNetwork,
    this.appOpenId,
    this.interstitialId,
    this.rewardedId,
    this.bannerId,
    this.nativeId,
  });

  /// Factory for deserializing from JSON with string enum fallback
  factory AppAdIds.fromJson(Map<dynamic, dynamic> json) {
    return AppAdIds(
      appId: json['appId'] ?? '',
      adNetwork: getAdNetworkFromString(json['adNetwork'] ?? 'any'),
      appOpenId: json['appOpenId'],
      interstitialId: json['interstitialId'],
      rewardedId: json['rewardedId'],
      bannerId: json['bannerId'],
      nativeId: json['nativeId'],
    );
  }

  /// Helpful for debugging
  @override
  String toString() {
    return 'AppAdIds(adNetwork: ${adNetwork.name}, appId: $appId)';
  }

  /// Utility getters (optional)
  bool get hasInterstitial => interstitialId?.isNotEmpty == true;
  bool get hasRewarded => rewardedId?.isNotEmpty == true;
  bool get hasBanner => bannerId?.isNotEmpty == true;
  bool get hasAppOpen => appOpenId?.isNotEmpty == true;
  bool get hasNative => nativeId?.isNotEmpty == true;
}
