import 'package:flutter/material.dart';

import '../models/shipping_container.dart';
import '../services/local_store.dart';

Future<ShippingContainer?> showCreateContainerDialog(BuildContext context) {
  return showDialog<ShippingContainer>(
    context: context,
    builder: (context) => const _CreateContainerDialog(),
  );
}

class _CreateContainerDialog extends StatefulWidget {
  const _CreateContainerDialog();

  @override
  State<_CreateContainerDialog> createState() => _CreateContainerDialogState();
}

class _CreateContainerDialogState extends State<_CreateContainerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _carrier = TextEditingController();
  final _tracking = TextEditingController();
  final _link = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _carrier.dispose();
    _tracking.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final container = ShippingContainer(
      id: 'c-${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      carrier: _emptyToNull(_carrier.text),
      trackingNumber: _emptyToNull(_tracking.text),
      trackingLink: _emptyToNull(_link.text),
    );
    try {
      await LocalStore.instance.insertContainer(container);
      if (!mounted) return;
      Navigator.of(context).pop(container);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save container: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New container'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _carrier,
                decoration: const InputDecoration(
                  labelText: 'Carrier / forwarder',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tracking,
                decoration: const InputDecoration(
                  labelText: 'Tracking number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _link,
                decoration: const InputDecoration(
                  labelText: 'Tracking link',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
