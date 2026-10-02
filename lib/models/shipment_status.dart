/// Status pipeline for containers and items.
enum ShipmentStatus {
  received,
  inContainer,
  inTransit,
  arrived,
  delivered;

  String get label {
    switch (this) {
      case ShipmentStatus.received:
        return 'received';
      case ShipmentStatus.inContainer:
        return 'in container';
      case ShipmentStatus.inTransit:
        return 'in transit';
      case ShipmentStatus.arrived:
        return 'arrived';
      case ShipmentStatus.delivered:
        return 'delivered';
    }
  }
}
