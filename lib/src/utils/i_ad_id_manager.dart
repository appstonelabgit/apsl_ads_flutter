import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';

abstract class IAdIdManager {
  const IAdIdManager();

  List<AppAdIds> get appAdIds;

  AppAdIds getAppIds(AdNetwork adNetwork) =>
      appAdIds.firstWhere((element) => element.adNetwork == adNetwork.name);
}

class AppAdIds {
  /// Always pass appId, if adnetwork don't have app id pass it as empty string
  final String appId;

  /// if id is null, it will not be implemented
  final String? appOpenId;
  final String? interstitialId;
  final String? rewardedId;
  final String? bannerId;
  final String? nativeId;

  /// Ad network type
  final String adNetwork;

  const AppAdIds({
    required this.appId,
    required this.adNetwork,
    this.appOpenId,
    this.interstitialId,
    this.rewardedId,
    this.bannerId,
    this.nativeId,
  });
}
