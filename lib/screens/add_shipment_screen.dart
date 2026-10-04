import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/shipping_container.dart';
import '../services/local_store.dart';
import '../services/ocr_service.dart';
import '../services/photo_store.dart';
import '../widgets/create_container_dialog.dart';
import 'confirm_shipment_screen.dart';

class AddShipmentScreen extends StatefulWidget {
  const AddShipmentScreen({super.key});

  static const routeName = '/add-shipment';

  @override
  State<AddShipmentScreen> createState() => _AddShipmentScreenState();
}

class _AddShipmentScreenState extends State<AddShipmentScreen> {
  final _picker = ImagePicker();
  final _ocr = const OcrService();

  List<ShippingContainer> _containers = const [];
  String? _selectedId;
  String? _presetId;
  var _loading = true;
  var _busy = false;
  var _readArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_readArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) _presetId = args;
    _readArgs = true;
    _load();
  }

  Future<void> _load() async {
    try {
      final summaries = await LocalStore.instance.listContainers();
      if (!mounted) return;
      final containers = [for (final s in summaries) s.container];
      setState(() {
        _containers = containers;
        _loading = false;
        _selectedId = _pickSelection(containers);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load containers: $error')),
      );
    }
  }

  String? _pickSelection(List<ShippingContainer> containers) {
    if (containers.isEmpty) return null;
    final preset = _presetId;
    if (preset != null && containers.any((c) => c.id == preset)) return preset;
    final current = _selectedId;
    if (current != null && containers.any((c) => c.id == current)) {
      return current;
    }
    return containers.first.id;
  }

  ShippingContainer? get _selected {
    for (final container in _containers) {
      if (container.id == _selectedId) return container;
    }
    return null;
  }

  Future<void> _createContainer() async {
    final created = await showCreateContainerDialog(context);
    if (created == null) return;
    _presetId = created.id;
    await _load();
  }

  Future<void> _capture(ImageSource source) async {
    final container = _selected;
    if (container == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a container first')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final shot = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (shot == null) return;
      final storedPath = await persistShipmentPhoto(shot.path);
      final outcome = await _ocr.readLabel(storedPath);
      if (!mounted) return;
      final saved = await Navigator.of(context).pushNamed(
        ConfirmShipmentScreen.routeName,
        arguments: ConfirmShipmentArgs(
          containerId: container.id,
          containerName: container.name,
          photoPath: storedPath,
          receiverName: outcome.label.receiverName ?? '',
          phone: outcome.label.phone ?? '',
          destination: outcome.label.destination ?? '',
          ocrWarning: outcome.warning,
        ),
      );
      if (saved == true && mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not capture a photo ($error). Use gallery or enter details manually.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _manual() async {
    final container = _selected;
    if (container == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a container first')),
      );
      return;
    }
    final saved = await Navigator.of(context).pushNamed(
      ConfirmShipmentScreen.routeName,
      arguments: ConfirmShipmentArgs(
        containerId: container.id,
        containerName: container.name,
        ocrWarning: 'No photo yet. Fill in the shipment by hand.',
      ),
    );
    if (saved == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add shipment')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Photo of the label, then confirm the fields.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                if (_containers.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Shipments belong to a container. Create one to continue.',
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _busy ? null : _createContainer,
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('Create a container'),
                      ),
                    ],
                  )
                else ...[
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Container',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedId,
                        items: [
                          for (final container in _containers)
                            DropdownMenuItem(
                              value: container.id,
                              child: Text(container.name),
                            ),
                        ],
                        onChanged: _busy
                            ? null
                            : (value) => setState(() => _selectedId = value),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _busy ? null : _createContainer,
                      icon: const Icon(Icons.add),
                      label: const Text('New container'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _capture(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Take label photo'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _capture(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose existing photo'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy ? null : _manual,
                    child: const Text('Enter details without a photo'),
                  ),
                  if (_busy) ...[
                    const SizedBox(height: 24),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 8),
                    const Center(child: Text('Reading the label…')),
                  ],
                ],
              ],
            ),
    );
  }
}
