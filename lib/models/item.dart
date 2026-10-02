import 'package_type.dart';
import 'shipment_status.dart';

/// Package / shipment inside a container.
class Item {
  final String id;
  final String receiverName;
  final String? phone;
  final String? destination;
  final PackageType packageType;
  final double? cost;
  final String? notes;
  final String? photoUrl;
  final String? videoUrl;
  final ShipmentStatus status;
  final String? containerId;
  final String? trackingNumber;
  final String? trackingLink;

  const Item({
    required this.id,
    required this.receiverName,
    this.phone,
    this.destination,
    this.packageType = PackageType.box,
    this.cost,
    this.notes,
    this.photoUrl,
    this.videoUrl,
    this.status = ShipmentStatus.received,
    this.containerId,
    this.trackingNumber,
    this.trackingLink,
  });
}
