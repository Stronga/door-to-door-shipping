import 'shipment_status.dart';

/// Yard shipping container (not Flutter's Container widget).
class ShippingContainer {
  final String id;
  final String name;
  final String? carrier;
  final String? trackingNumber;
  final String? trackingLink;
  final ShipmentStatus status;
  final double? costTotal;

  const ShippingContainer({
    required this.id,
    required this.name,
    this.carrier,
    this.trackingNumber,
    this.trackingLink,
    this.status = ShipmentStatus.received,
    this.costTotal,
  });
}
