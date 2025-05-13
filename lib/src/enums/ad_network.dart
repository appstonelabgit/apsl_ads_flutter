/// Supported ad networks.
enum AdNetwork { any, admob, unity, facebook }

/// Extension to get string representation.
extension AdNetworkExtension on AdNetwork {
  String get value => name;
}

/// Converts a string to [AdNetwork] enum.
/// Returns [AdNetwork.any] if no match is found.
AdNetwork getAdNetworkFromString(String providerName) {
  final normalized = providerName.toLowerCase();

  return AdNetwork.values.firstWhere(
    (e) => e.name.toLowerCase() == normalized,
    orElse: () => AdNetwork.any,
  );
}
