import 'dart:io';

import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/package_type.dart';
import '../services/local_store.dart';

class ConfirmShipmentArgs {
  final String containerId;
  final String containerName;
  final String? photoPath;
  final String receiverName;
  final String phone;
  final String destination;
  final String? ocrWarning;

  const ConfirmShipmentArgs({
    required this.containerId,
    required this.containerName,
    this.photoPath,
    this.receiverName = '',
    this.phone = '',
    this.destination = '',
    this.ocrWarning,
  });
}

class ConfirmShipmentScreen extends StatefulWidget {
  const ConfirmShipmentScreen({super.key});

  static const routeName = '/confirm-shipment';

  @override
  State<ConfirmShipmentScreen> createState() => _ConfirmShipmentScreenState();
}

class _ConfirmShipmentScreenState extends State<ConfirmShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _destination;
  late final TextEditingController _cost;
  var _packageType = PackageType.box;
  var _saving = false;
  ConfirmShipmentArgs? _args;
  var _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ConfirmShipmentArgs) {
      _args = args;
      _name = TextEditingController(text: args.receiverName);
      _phone = TextEditingController(text: args.phone);
      _destination = TextEditingController(text: args.destination);
      _cost = TextEditingController();
    } else {
      _name = TextEditingController();
      _phone = TextEditingController();
      _destination = TextEditingController();
      _cost = TextEditingController();
    }
    _ready = true;
  }

  @override
  void dispose() {
    if (_ready) {
      _name.dispose();
      _phone.dispose();
      _destination.dispose();
      _cost.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final args = _args;
    if (args == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final item = Item(
      id: 'i-${DateTime.now().microsecondsSinceEpoch}',
      receiverName: _name.text.trim(),
      phone: _blankToNull(_phone.text),
      destination: _blankToNull(_destination.text),
      packageType: _packageType,
      cost: double.parse(_cost.text.trim()),
      photoUrl: args.photoPath,
      containerId: args.containerId,
    );
    try {
      await LocalStore.instance.insertItem(item);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save shipment: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm shipment')),
      body: args == null
          ? const Center(child: Text('Open this screen from Add shipment.'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Container: ${args.containerName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (args.ocrWarning != null) ...[
                    MaterialBanner(
                      content: Text(args.ocrWarning!),
                      leading: const Icon(Icons.info_outline),
                      backgroundColor: Colors.amber.shade50,
                      actions: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .hideCurrentMaterialBanner();
                          },
                          child: const Text('Dismiss'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  _PhotoPreview(path: args.photoPath),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Receiver name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
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
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cost,
                    decoration: const InputDecoration(
                      labelText: 'Cost',
                      border: OutlineInputBorder(),
                      prefixText: r'$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                            DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ),
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
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.check),
                    label: Text(_saving ? 'Saving…' : 'Save shipment'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final photo = path;
    if (photo == null || !File(photo).existsSync()) {
      return const Text('No photo attached. You can still save the shipment.');
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(photo),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
