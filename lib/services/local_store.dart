import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item.dart';
import '../models/package_type.dart';
import '../models/shipment_status.dart';
import '../models/shipping_container.dart';

/// On-device ledger. Photos are file paths in [Item.photoUrl], not cloud URLs.
class LocalStore {
  LocalStore._();
  static final LocalStore instance = LocalStore._();

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;
    final docs = await getApplicationDocumentsDirectory();
    final opened = await openDatabase(
      p.join(docs.path, 'ledger.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE containers (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            carrier TEXT,
            tracking_number TEXT,
            tracking_link TEXT,
            status TEXT NOT NULL,
            cost_total REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE items (
            id TEXT PRIMARY KEY,
            receiver_name TEXT NOT NULL,
            phone TEXT,
            destination TEXT,
            package_type TEXT NOT NULL,
            cost REAL,
            notes TEXT,
            photo_path TEXT,
            video_path TEXT,
            status TEXT NOT NULL,
            container_id TEXT,
            tracking_number TEXT,
            tracking_link TEXT,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
    _db = opened;
    return opened;
  }

  Future<List<ContainerSummary>> listContainers() async {
    final db = await database;
    final rows = await db.query('containers', orderBy: 'name COLLATE NOCASE');
    final summaries = <ContainerSummary>[];
    for (final row in rows) {
      final container = _containerFromRow(row);
      final stats = await db.rawQuery(
        'SELECT COUNT(*) AS n, COALESCE(SUM(cost), 0) AS total FROM items WHERE container_id = ?',
        [container.id],
      );
      final stat = stats.first;
      summaries.add(
        ContainerSummary(
          container: container,
          itemCount: (stat['n'] as int?) ?? 0,
          costTotal: (stat['total'] as num?)?.toDouble() ?? 0,
        ),
      );
    }
    return summaries;
  }

  Future<ShippingContainer?> getContainer(String id) async {
    final db = await database;
    final rows = await db.query(
      'containers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _containerFromRow(rows.first);
  }

  Future<void> insertContainer(ShippingContainer container) async {
    final db = await database;
    await db.insert('containers', _containerToRow(container));
  }

  Future<List<Item>> itemsInContainer(String containerId) async {
    final db = await database;
    final rows = await db.query(
      'items',
      where: 'container_id = ?',
      whereArgs: [containerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(_itemFromRow).toList();
  }

  Future<Item?> getItem(String id) async {
    final db = await database;
    final rows = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _itemFromRow(rows.first);
  }

  Future<void> insertItem(Item item) async {
    final db = await database;
    await db.insert('items', {
      ..._itemToRow(item),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update(
      'items',
      _itemToRow(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<List<Item>> searchItems(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final like = '%${trimmed.replaceAll('%', '')}%';
    final db = await database;
    final rows = await db.query(
      'items',
      where:
          'receiver_name LIKE ? OR phone LIKE ? OR destination LIKE ? OR notes LIKE ?',
      whereArgs: [like, like, like, like],
      orderBy: 'created_at DESC',
      limit: 50,
    );
    return rows.map(_itemFromRow).toList();
  }

  Future<LedgerTotals> totals() async {
    final db = await database;
    final containerCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM containers'),
        ) ??
        0;
    final itemCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM items'),
        ) ??
        0;
    final costRows = await db.rawQuery(
      'SELECT COALESCE(SUM(cost), 0) AS total FROM items',
    );
    final cost = (costRows.first['total'] as num?)?.toDouble() ?? 0;
    final statusRows = await db.rawQuery(
      'SELECT status, COUNT(*) AS n FROM items GROUP BY status',
    );
    final byStatus = <ShipmentStatus, int>{
      for (final status in ShipmentStatus.values) status: 0,
    };
    for (final row in statusRows) {
      final status = shipmentStatusFromStorage(row['status'] as String?);
      byStatus[status] = (row['n'] as int?) ?? 0;
    }
    return LedgerTotals(
      containers: containerCount,
      items: itemCount,
      cost: cost,
      itemsByStatus: byStatus,
    );
  }
}

class ContainerSummary {
  final ShippingContainer container;
  final int itemCount;
  final double costTotal;

  const ContainerSummary({
    required this.container,
    required this.itemCount,
    required this.costTotal,
  });
}

class LedgerTotals {
  final int containers;
  final int items;
  final double cost;
  final Map<ShipmentStatus, int> itemsByStatus;

  const LedgerTotals({
    required this.containers,
    required this.items,
    required this.cost,
    required this.itemsByStatus,
  });
}

String formatMoney(double? value) {
  if (value == null) return '—';
  return '\$${value.toStringAsFixed(2)}';
}

ShipmentStatus shipmentStatusFromStorage(String? raw) {
  for (final status in ShipmentStatus.values) {
    if (status.name == raw || status.label == raw) return status;
  }
  return ShipmentStatus.received;
}

PackageType packageTypeFromStorage(String? raw) {
  for (final type in PackageType.values) {
    if (type.name == raw) return type;
  }
  return PackageType.box;
}

Map<String, Object?> _containerToRow(ShippingContainer container) {
  return {
    'id': container.id,
    'name': container.name,
    'carrier': container.carrier,
    'tracking_number': container.trackingNumber,
    'tracking_link': container.trackingLink,
    'status': container.status.name,
    'cost_total': container.costTotal,
  };
}

ShippingContainer _containerFromRow(Map<String, Object?> row) {
  return ShippingContainer(
    id: row['id']! as String,
    name: row['name']! as String,
    carrier: row['carrier'] as String?,
    trackingNumber: row['tracking_number'] as String?,
    trackingLink: row['tracking_link'] as String?,
    status: shipmentStatusFromStorage(row['status'] as String?),
    costTotal: (row['cost_total'] as num?)?.toDouble(),
  );
}

Map<String, Object?> _itemToRow(Item item) {
  return {
    'id': item.id,
    'receiver_name': item.receiverName,
    'phone': item.phone,
    'destination': item.destination,
    'package_type': item.packageType.name,
    'cost': item.cost,
    'notes': item.notes,
    'photo_path': item.photoUrl,
    'video_path': item.videoUrl,
    'status': item.status.name,
    'container_id': item.containerId,
    'tracking_number': item.trackingNumber,
    'tracking_link': item.trackingLink,
  };
}

Item _itemFromRow(Map<String, Object?> row) {
  return Item(
    id: row['id']! as String,
    receiverName: row['receiver_name']! as String,
    phone: row['phone'] as String?,
    destination: row['destination'] as String?,
    packageType: packageTypeFromStorage(row['package_type'] as String?),
    cost: (row['cost'] as num?)?.toDouble(),
    notes: row['notes'] as String?,
    photoUrl: row['photo_path'] as String?,
    videoUrl: row['video_path'] as String?,
    status: shipmentStatusFromStorage(row['status'] as String?),
    containerId: row['container_id'] as String?,
    trackingNumber: row['tracking_number'] as String?,
    trackingLink: row['tracking_link'] as String?,
  );
}
