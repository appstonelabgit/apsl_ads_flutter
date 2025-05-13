import 'package:apsl_ads_flutter/src/enums/apsl_event_type.dart';
import 'package:apsl_ads_flutter/src/enums/ad_network.dart';
import 'package:apsl_ads_flutter/src/enums/ad_unit_type.dart';

/// [AdEvent] is used to represent ad-related events across the APSL Ads system.
class AdEvent {
  final AdEventType type;
  final AdNetwork adNetwork;
  final AdUnitType? adUnitType;

  /// Custom data attached to the event
  final Object? data;

  /// Error message if the event represents a failure
  final String? error;

  const AdEvent({
    required this.type,
    required this.adNetwork,
    this.adUnitType,
    this.data,
    this.error,
  });

  /// Named constructor for error events
  factory AdEvent.error({
    required AdEventType type,
    required AdNetwork adNetwork,
    AdUnitType? adUnitType,
    required String error,
    Object? data,
  }) {
    return AdEvent(
      type: type,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      error: error,
      data: data,
    );
  }

  @override
  String toString() {
    return 'AdEvent(type: $type, network: $adNetwork, unit: $adUnitType, data: $data, error: $error)';
  }
}
