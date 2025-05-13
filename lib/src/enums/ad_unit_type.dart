enum AdUnitType {
  appOpen,
  banner,
  interstitial,
  rewarded,
  native,
}

extension AdUnitTypeExtension on AdUnitType {
  String get value => name;
}
