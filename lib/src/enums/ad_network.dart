import 'package:flutter/foundation.dart';

enum AdNetwork { any, admob, appLovin, unity, facebook }

extension AdNetworkExtension on AdNetwork {
  String get value => describeEnum(this);
}

AdNetwork? getAdNetworkFromString(String providerName) {
  final placementName = providerName.toLowerCase();

  final AdNetwork provider = AdNetwork.values.firstWhere(
    (element) => element.toString().toLowerCase() == placementName,
    orElse: () => AdNetwork.any,
  );

  return provider;
}
