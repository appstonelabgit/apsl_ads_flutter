abstract class IAdIdManager {
  const IAdIdManager();

  List<AppAdIds> get appAdIds;

  // /// Pass null if you wish not to implement unity ads
  // ///
  // /// AppAdIds? get unityAdIds => null;
  // AppAdIds? get unityAdIds;

  // /// Pass null if you wish not to implement admob ads
  // ///
  // /// AppAdIds? get admobAdIds => null;
  // AppAdIds? get admobAdIds;

  // /// Pass null if you wish not to implement appLovin ads
  // ///
  // /// AppAdIds? get appLovinAdIds => null;
  // AppAdIds? get appLovinAdIds;

  // /// Pass null if you wish not to implement facebook ads
  // ///
  // /// AppAdIds? get fbAdIds => null;
  // AppAdIds? get fbAdIds;
}

class AppAdIds {
  /// App Id should never be null, if there is no app id for a particular ad network, leave it empty
  final String appId;

  /// if id is null, it will not be implemented
  final String? appOpenId;

  /// if id is null, it will not be implemented
  final String? interstitialId;

  /// if id is null, it will not be implemented
  final String? rewardedId;

  /// if id is null, it will not be implemented
  final String? bannerId;

  /// if id is null, it will not be implemented
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
