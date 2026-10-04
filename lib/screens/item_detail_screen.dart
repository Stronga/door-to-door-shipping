import 'dart:io';

import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/package_type.dart';
import '../models/shipment_status.dart';
import '../services/local_store.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key});

  static const routeName = '/item';

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _id;
  var _bound = false;
  Item? _item;
  var _loading = true;
  var _saving = false;
  String? _error;

  late final TextEditingController _name = TextEditingController();
  late final TextEditingController _phone = TextEditingController();
  late final TextEditingController _destination = TextEditingController();
  late final TextEditingController _cost = TextEditingController();
  late final TextEditingController _notes = TextEditingController();
  var _packageType = PackageType.box;
  var _status = ShipmentStatus.received;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    final id = args is String ? args : null;
    if (_bound && id == _id) return;
    _bound = true;
    _id = id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _destination.dispose();
    _cost.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = _id;
    if (id == null) {
      setState(() {
        _loading = false;
        _item = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final item = await LocalStore.instance.getItem(id);
      if (!mounted) return;
      if (item != null) _apply(item);
      setState(() {
        _item = item;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  void _apply(Item item) {
    _name.text = item.receiverName;
    _phone.text = item.phone ?? '';
    _destination.text = item.destination ?? '';
    _cost.text = item.cost == null ? '' : item.cost!.toString();
    _notes.text = item.notes ?? '';
    _packageType = item.packageType;
    _status = item.status;
  }

  Future<void> _save() async {
    final current = _item;
    if (current == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = Item(
      id: current.id,
      receiverName: _name.text.trim(),
      phone: _blank(_phone.text),
      destination: _blank(_destination.text),
      packageType: _packageType,
      cost: double.parse(_cost.text.trim()),
      notes: _blank(_notes.text),
      photoUrl: current.photoUrl,
      videoUrl: current.videoUrl,
      status: _status,
      containerId: current.containerId,
      trackingNumber: current.trackingNumber,
      trackingLink: current.trackingLink,
    );
    try {
      await LocalStore.instance.updateItem(updated);
      if (!mounted) return;
      setState(() {
        _item = updated;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shipment saved')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item detail')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_id == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Open a shipment from a container or from search.'),
        ),
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text('Could not load this shipment.\n$_error'));
    }
    final item = _item;
    if (item == null) return const Center(child: Text('Shipment not found.'));

    final photo = item.photoUrl;
    final hasPhoto = photo != null && File(photo).existsSync();

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (hasPhoto)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(photo),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            const ListTile(
              leading: Icon(Icons.photo_outlined),
              title: Text('Photo'),
              subtitle: Text('None saved on this device'),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Receiver name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter the receiver name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _destination,
            decoration: const InputDecoration(
              labelText: 'Destination',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cost,
            decoration: const InputDecoration(
              labelText: 'Cost',
              border: OutlineInputBorder(),
              prefixText: r'$ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final parsed = double.tryParse((value ?? '').trim());
              if (parsed == null || parsed < 0) {
                return 'Enter a cost (0 or more)';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Package type',
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PackageType>(
                isExpanded: true,
                value: _packageType,
                items: [
                  for (final type in PackageType.values)
                    DropdownMenuItem(value: type, child: Text(type.label)),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _packageType = value);
                      },
              ),
            ),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              helperText: 'received → in container → in transit → arrived → delivered',
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ShipmentStatus>(
                isExpanded: true,
                value: _status,
                items: [
                  for (final status in ShipmentStatus.values)
                    DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _status = value);
                      },
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notes,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save changes'),
          ),
        ],
      ),
    );
  }
}

String? _blank(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
