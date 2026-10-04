import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies a captured label photo into app documents so it survives
/// the image picker's temp file being cleaned up.
Future<String> persistShipmentPhoto(String sourcePath) async {
  final docs = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(docs.path, 'shipment_photos'));
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }
  final ext = p.extension(sourcePath);
  final safeExt = ext.isEmpty ? '.jpg' : ext;
  final destPath = p.join(
    folder.path,
    '${DateTime.now().microsecondsSinceEpoch}$safeExt',
  );
  await File(sourcePath).copy(destPath);
  return destPath;
}
